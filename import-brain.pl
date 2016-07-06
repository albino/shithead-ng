#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use FindBin qw($Bin);
use lib $Bin;
use MarkovBot::Learning;
use MarkovBot::Redis;
use MarkovBot::Config;

my $brain_file = $ARGV[0];
# read off first line
open BRAIN, $brain_file or die $!;
my $line = <BRAIN>;
close BRAIN;
# open it again from the top
open BRAIN, $brain_file or die $!;

if ($line =~ m/^shithead-ng\ file\ \(version\ .+\)$/) {
  # shithead-ng specific file
  while (<BRAIN>) {
    next unless $_ =~ m/^\x1c/;
    $_ =~ s/^\x1c//;
    chomp;
    my @words = split "\x1f", $_;
    @words = map { $_ eq "\x1d" ? "___end___" : $_ } @words;

    # Write to redis
    my $p = config("redis_prefix");
    my $redis = redis();
    $redis->lpush("$p:chains:".shift(@words).",".shift(@words), @words);
  }
} else {
  # generic irc log file
  learn $_ while <BRAIN>;
}

close BRAIN;
