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
my $tool = basename($0);

# process options.
use vars qw($opt_h $opt_t);
getopts('ho:t') || mycroak("getopts failure");

if (defined($opt_h)) {
  help();
}

my %msg_id_hist;
my %msg_text_hist;
my $prev_throttled_msg_id = "";

# Main loop; read each line in each file.
while (<>) {
  chomp;  # remove trailing \n

  if (/^\s*$/) { next; }
  if (/^\s+/) { next; }  # Ignore lines that start with whitespace.

  # The Gwd-6033-618: message is unfortunate in that it combines many different messages.
  # Differentiate them by the constant parts of the message text.
  if (/Gwd-6033-618: (.*)$/) {
    my $m = $1;
    while ($m =~ s/\[[^\]]*\]/x/) { }  # Eliminate all "[...]"
    while ($m =~ s/\([^\)]*\)/x/) { }  # Eliminate all "(...)"
    my $msg_id = "Gwd-6033-618: $m";    # Expand message ID to include constant text.
    if (!defined($msg_id_hist{$msg_id})) { $msg_id_hist{$msg_id} = 0; $msg_text_hist{$msg_id} = ""; }
    $msg_id_hist{$msg_id} ++;
    next;
  }

  if (/previous THROTTLED MSG repeated (\d+) times/) {
    if (!$opt_t) {
      if ($prev_throttled_msg_id ne "") {
        $msg_id_hist{$prev_throttled_msg_id} += $1;
      }
      else { mycroak("ERROR, no previous throttled for $_"); }
    }
    next;
  }
  my $throttled = s/ THROTTLED MSG: / /;

  if (/\]:*\s+([A-Za-z]+-\d+-\d+:)\s+(.*)$/) {
    my $msg_id = $1;
    if (!defined($msg_id_hist{$msg_id})) { $msg_id_hist{$msg_id} = 0; $msg_text_hist{$msg_id} = $2; }
    $msg_id_hist{$msg_id} ++;
    if ($throttled) { $prev_throttled_msg_id = $msg_id; }
  }
else { print "$_\n"; }
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
Usage: $tool [-h] -t [file ...]
Where:
    -h - help
    -t - don't count omitted throttled logs.
    file ... - zero or more input files.  If omitted, inputs from stdin.

See https://github.com/UltraMessaging/msg_id_histo for code and doc.
__EOF__

  exit(0);
}  # help
