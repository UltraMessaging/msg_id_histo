#!/usr/bin/env perl
# skeleton.pl - https://github.com/UltraMessaging/msg_id_histo
#
# All of the documentation and software included in this and any
# other Informatica Ultra Messaging GitHub repository
# Copyright (C) Informatica. All rights reserved.
#
# Permission is granted to licensees to use
# or alter this software for any purpose, including commercial applications,
# according to the terms laid out in the Software License Agreement.
#
# This source code example is provided by Informatica for educational
# and evaluation purposes only.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND INFORMATICA DISCLAIMS ALL WARRANTIES
# EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY IMPLIED WARRANTIES OF
# NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A PARTICULAR
# PURPOSE.  INFORMATICA DOES NOT WARRANT THAT USE OF THE SOFTWARE WILL BE
# UNINTERRUPTED OR ERROR-FREE.  INFORMATICA SHALL NOT, UNDER ANY CIRCUMSTANCES,
# BE LIABLE TO LICENSEE FOR LOST PROFITS, CONSEQUENTIAL, INCIDENTAL, SPECIAL OR
# INDIRECT DAMAGES ARISING OUT OF OR RELATED TO THIS AGREEMENT OR THE
# TRANSACTIONS CONTEMPLATED HEREUNDER, EVEN IF INFORMATICA HAS BEEN APPRISED OF
# THE LIKELIHOOD OF SUCH DAMAGES.

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
  if (/\]:*\s+([A-za-z]+-\d+-\d+:)\s+(.*)$/) {
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
