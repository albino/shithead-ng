#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use Redis;
use FindBin qw($Bin);

use lib $Bin;

use MarkovBot::Config;

# Load Configuration

my $redis_prefix = config("redis_prefix");
my $brain_file = $ARGV[0];

my $redis = Redis->new();

open BRAIN, $brain_file or die $!;

while (<BRAIN>) {

  # Apply preprocessing to the line
  $_ = $_ . "___end___";
  $_ = lc $_;
  $_ =~ y/\,\.\!\?\(\)//d;

  # Split it into individual words
  my @words = split(' ', $_);

  # Disregard short sentences
  next if scalar(@words < 4);

  for (my $i = 0; $i <= $#words-2; $i++) {
    # $words[$i] $words[$i+1] => $words[$i+2]
    $redis->rpush("$redis_prefix:chains:$words[$i],$words[$i+1]", $words[$i+2]);
  }

}

close BRAIN;
