#!/usr/bin/env perl
# reroute_runs.pl - tool to scan a Store log and identifying the "runs" of
#   re-route messages.
#   See https://github.com/UltraMessaging/msg_id_histo for full doc.
#
# This code and its documentation is Copyright 2011-2021 Informatica
# and licensed "public domain" style under Creative Commons "CC0":
#   http://creativecommons.org/publicdomain/zero/1.0/
# To the extent possible under law, the contributors to this project have
# waived all copyright and related or neighboring rights to this work.
# In other words, you can use this code for any purpose without any
# restrictions.  This work is published from: United States.  The project home
# is https://github.com/UltraMessaging/msg_id_histo

use strict;
use warnings;
use Getopt::Std;
use File::Basename;
use Carp;
use Time::Local qw(timegm);

my %asc_to_mon = (
  Jan => 1,  Feb => 2,  Mar => 3,  Apr => 4,
  May => 5,  Jun => 6,  Jul => 7,  Aug => 8,
  Sep => 9,  Oct => 10, Nov => 11, Dec => 12);

# globals
my $tool = basename($0);

# process options.
use vars qw($opt_h $opt_d $opt_n $opt_t);
getopts('hd:n:t:') || mycroak("getopts failure");

if (defined($opt_h)) {
  help();
}

my $duration_min_report = 10;
if (defined($opt_d)) {
  $duration_min_report = $opt_d;
}

my $num_min_report = 10;
if (defined($opt_n)) {
  $num_min_report = $opt_n;
}

my $threshold = 60; # default.
if (defined($opt_t)) {
  $threshold = $opt_t;
}

my $run_count = 0;
my $start_of_run = -1;
my $prev_time;

while (<>) {
  chomp;  # remove trailing \n

  my ($mon, $day, $hour, $min, $sec, $year);
  my $epoch_time;
  if (/\b[MTWFS]\w\w (\w\w\w) +(\d+) (\d\d):(\d\d):(\d\d) (\d\d\d\d)\b/) {  # Store time format.
    ($mon, $day, $hour, $min, $sec, $year) = (asc2mon($1), $2, $3, $4, $5, $6);
    # Get seconds past the system's epoch.
    $epoch_time = timegm($sec, $min, $hour, $day, $mon-1, $year);
  }
  elsif (/\[(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)\D/) {  # DRO time format
    ($year, $mon, $day, $hour, $min, $sec) = ($1, $2, $3, $4, $5, $6);
    next;  # DRO log line; ignore
  }
  elsif (/^\@(\d+).*\b[MTWFS]\w\w (\w\w\w) (\d\d) (\d\d):(\d\d):(\d\d) (\d\d\d\d)\b/) {  # Store epoch time format.
    # Get seconds past the system's epoch.
    $epoch_time = $1;
  }
  else {
    next;  # Line without a timestamp. Ignore.
  }

  ###print "epoch_time=$epoch_time, gmtime='" . scalar gmtime($epoch_time) . "'\n";

  if (/Core-6259-1:/) {  # Re-routing log.
    if ($start_of_run == -1) {
      # Very first ocurrence of "Core-6259-1:".
      $start_of_run = $epoch_time;
      $prev_time = $start_of_run;
      $run_count = 1;
    }
    else {
      if (($epoch_time - $prev_time) > $threshold) {
        my $run_duration = $prev_time - $start_of_run;
        if ($run_count >= $num_min_report && $run_duration >= $duration_min_report) {
          print "$run_count re-route events " . scalar gmtime($start_of_run) .
                " to " . scalar gmtime($prev_time) . " ($run_duration sec)\n";
        }

        # Threshold exceeded; start of new run.
        $start_of_run = $epoch_time;
        $prev_time = $start_of_run;
        $run_count = 1;
      }
      else {
        # Next item in run. Check if single event (same second).
        if ($prev_time == $epoch_time) {
          # Part of single event; don't count it.
        }
        else { # New event in run; count it.
          $prev_time = $epoch_time;
          $run_count++;
        }
      }
    }
  }

} continue {  # This continue clause makes "$." give line number within file.
  close ARGV if eof;
}

# Finish off final run (if any).
if ($start_of_run != -1) {
  my $run_duration = $prev_time - $start_of_run;
  if ($run_count >= $num_min_report && $run_duration >= $duration_min_report) {
    print "$run_count re-route events " . scalar gmtime($start_of_run) .
          " to " . scalar gmtime($prev_time) . " ($run_duration sec)\n";
  }
}

# All done.
exit(0);


# End of main program, start subroutines.

sub asc2mon {
  my ($asc_mon) = @_;

  if (defined($asc_to_mon{$asc_mon})) {
    return $asc_to_mon{$asc_mon};
  }

  mycroak("bad month string: $asc_mon");
}  # asc2mon


sub mycroak {
  my ($msg) = @_;

  if (defined($ARGV)) {
    # Print input file name and line number.
    croak("Error (use -h for help): input_file:line=$ARGV:$., $msg");
  } else {
    croak("Error (use -h for help): $msg");
  }
}  # mycroak


sub assrt {
  my ($assertion, $msg) = @_;

  if (! ($assertion)) {
    if (defined($msg)) {
      mycroak("Assertion failed, $msg");
    } else {
      mycroak("Assertion failed");
    }
  }
}  # assrt


sub help {
  my($err_str) = @_;

  if (defined $err_str) {
    print "$tool: $err_str\n\n";
  }
  print <<__EOF__;
Usage: $tool [-h] [-o out_file] [file ...]
Where ('R' indicates required option):
    -h - help
    -d duration_min_report - minimum duration of run to report. [10]
    -n num_min_report - minimum number of events in run to report. [10]
    -t threshold - number of seconds gap separating runs. [60]
    file ... - zero or more input files.  If omitted, inputs from stdin.

__EOF__

  exit(0);
}  # help
