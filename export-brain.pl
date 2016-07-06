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

print "# shithead-ng file (version 0)\n# this file cannot be used by other markov chain programs, without modification.\n# do not remove the first line, as it is used by the import script to determine whether the file is a standard irc log or a shithead-ng specific file.\n\x1c";

for (@keys) {
  my $prefix = quotemeta $p;
  my $k = $_;
  $k =~ s/$prefix:chains://;

  my @words = split ",", $k;
  push @words, @{ $redis->lrange($_, 0, -1) };
  @words = map { $_ eq '___end___' ? "\x1d" : $_ } @words;
  print join("\x1f", @words), "\n\x1c";
}
