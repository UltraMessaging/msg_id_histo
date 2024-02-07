#!/usr/bin/env perl
# msg_id_histo.pl - tool to count log messages of each type and
#   print the totals.
#   See https://github.com/UltraMessaging/msg_id_histo for full doc.
#
# This code and its documentation is Copyright 2023 Informatica
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

# globals
my $tool = "msg_id_histo.pl";
my $vers = "1.8";

# process options.
use vars qw($opt_h $opt_p $opt_t);
$opt_p = ".";  # default: match anything.
getopts('hp:t') || mycroak("getopts failure");

if (defined($opt_h)) {
  help();
}

my %msg_id_hist;
my %msg_text_hist;
my $prev_throttled_msg_id = "";
my $prev_throttled_msg_text = "";

# Main loop; read each line in each file.
while (<>) {
  chomp;  # remove trailing \n

  if (/^\s*$/) { next; }
  if (/^\s+/) { next; }  # Ignore lines that start with whitespace.

  # The Gwd-6033-618: message is unfortunate in that it combines many different messages.
  # Differentiate them by the constant parts of the message text.
  if (/Gwd-6033-618: (.*)$/) {
    my $m = $1;
    if (/$opt_p/) {  # If matches pattern.
      while ($m =~ s/\[[^\]]*\]/x/) { }  # Eliminate varying text in square brackets "[...]"
      while ($m =~ s/\([^\)]*\)/x/) { }  # Eliminate varying text in parentheses "(...)"
      my $msg_id = "Gwd-6033-618: $m";    # Expand message ID to include constant text.
      # Make sure historgram bucket is defined.
      if (!defined($msg_id_hist{$msg_id})) { $msg_id_hist{$msg_id} = 0; $msg_text_hist{$msg_id} = ""; }
      $msg_id_hist{$msg_id} ++;
    }
    next;
  }

  if (/previous THROTTLED MSG repeated (\d+) times/) {
    my $throttle_count = $1;
    if (!$opt_t) {
      if (/$opt_p/) {
        if ($prev_throttled_msg_id ne "") {
          # Make sure historgram bucket is defined.
          if (!defined($msg_id_hist{$prev_throttled_msg_id})) {
            $msg_id_hist{$prev_throttled_msg_id} = 0;
            $msg_text_hist{$prev_throttled_msg_id} = $prev_throttled_msg_text;
          }
          $msg_id_hist{$prev_throttled_msg_id} += $throttle_count;
        }
        else {  # Previous throttled message not found.
          my $unknown = "unknown_0:";
          # Make sure historgram bucket is defined.
          if (! defined($msg_id_hist{"$unknown"})) {
            $msg_id_hist{"$unknown"} = 0;
            $msg_text_hist{"$unknown"} = "found a 'previous THROTTLED MSG' without a prior 'THROTTLED MSG'";
          }
          $msg_id_hist{"$unknown"} += $throttle_count;
        }
      }  # if opt_p
    }  # if opt_t
    next;
  }

  my $throttled = s/ THROTTLED MSG: / /;
  if (/\]:*\s+([A-Za-z]+-\d+-\d+:)\s+(.*)$/) {
    my $msg_id = $1;
    my $msg_text = $2;
    if ($throttled) {
      $prev_throttled_msg_id = $msg_id;
      $prev_throttled_msg_text = $msg_text;
    }

    if (/$opt_p/) {
      if (!defined($msg_id_hist{$msg_id})) { $msg_id_hist{$msg_id} = 0; $msg_text_hist{$msg_id} = $msg_text; }
      $msg_id_hist{$msg_id} ++;
    }
  }
  else {
    if (/$opt_p/) {
      print "$_\n";
    }
  }
} continue {  # This continue clause makes "$." give line number within file.
  close ARGV if eof;
}

foreach my $msg_id (sort(keys(%msg_id_hist))) {
  print "$msg_id_hist{$msg_id} - $msg_id $msg_text_hist{$msg_id}\n";
}

# All done.
exit(0);


# End of main program, start subroutines.


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
$tool version $vers
Usage: $tool [-h] -t [file ...]
Where:
    -h - help
    -p pattern - Only count records that match regular pattern.
    -t - don't count omitted throttled logs.
    file ... - zero or more input files.  If omitted, inputs from stdin.

See https://github.com/UltraMessaging/msg_id_histo for code and doc.
__EOF__

  exit(0);
}  # help
