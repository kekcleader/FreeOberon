#!perl -w
use strict;
use warnings;

my ($fn) = @ARGV;

open MOD,$fn // die "Could not open $fn.";
while (<MOD>) {
  if (/^(.*)ASSERT\((.*?)(, +[0-9]+)\)(.*$)/) {
    print $1, "ASSERT($2, $.)", $4, "\n";
  } else {
    print $_;
  }
}

close MOD;
