#!/usr/bin/env perl
#
# Export brain script
#
# This script will block redis for a little bit
# It outputs a specific shithead-ng brain file, which cannot be used
# by other (unmodified) markov chain bots.
#
use 5.010;
use strict;
use warnings;
use FindBin qw($Bin);
use lib $Bin;
use MarkovBot::Redis;
use MarkovBot::Config;

my $redis = redis();
my $p = config("redis_prefix");
my @keys = $redis->keys("$p:chains:*");

say "shithead-ng file (version 0)\nthis file cannot be used by other markov chain programs, without modification.\ndo not remove the first line, as it is used by the import script to determine whether the file is a standard irc log or a shithead-ng specific file.";

for (@keys) {
  # mark the beginning of the record
  print "\n\x1c";

  my $prefix = quotemeta $p;
  my $k = $_;
  $k =~ s/$prefix:chains://;

  my @words = split ",", $k;
  push @words, @{ $redis->lrange($_, 0, -1) };
  @words = map { $_ eq '___end___' ? "\x1d" : $_ } @words;
  print join "\x1f", @words;
}
