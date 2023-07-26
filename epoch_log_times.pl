#!/usr/bin/env perl
# epoch_log_times.pl - tool to read each log message from a UM Store or DRO
#   and write the line preceided by "@" and the epoch time (seconds after the
#   system's epoch).
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
use vars qw($opt_h);
getopts('h') || mycroak("getopts failure");

if (defined($opt_h)) {
  help();
}

while (<>) {
  chomp;  # remove trailing \n

  my ($mon, $day, $hour, $min, $sec, $year);
  my $epoch_time;
  if (/^\w\w\w (\w\w\w) +(\d+) (\d\d):(\d\d):(\d\d) (\d\d\d\d)\b/) {  # Store time format.
    ($mon, $day, $hour, $min, $sec, $year) = (asc2mon($1), $2, $3, $4, $5, $6);
    # Get seconds past the system's epoch.
    $epoch_time = timegm($sec, $min, $hour, $day, $mon-1, $year);

    print "@" . "$epoch_time $_\n";
  }
  elsif (/^\[(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)\D/) {  # DRO time format.
    ($year, $mon, $day, $hour, $min, $sec) = ($1, $2, $3, $4, $5, $6);
    # Get seconds past the system's epoch.
    $epoch_time = timegm($sec, $min, $hour, $day, $mon-1, $year);

    print "@" . "$epoch_time $_\n";
  }
  else {  # unrecognized; print as-is.
    print "$_\n";
  }

} continue {  # This continue clause makes "$." give line number within file.
  close ARGV if eof;
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
    file ... - zero or more input files.  If omitted, inputs from stdin.

__EOF__

  exit(0);
}  # help
