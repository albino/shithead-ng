package MarkovBot::Learning;
use base qw(Exporter);
use 5.010;
use strict;
use warnings;

our @EXPORT = qw(learn);

use FindBin qw($Bin);
use lib $Bin;

use MarkovBot::Config;
use MarkovBot::Redis;
use Encode qw(encode);

sub learn( $ ) {
  # input - line to be learned
  # returns - nothing
  
  my $redis = redis();
  my $redis_prefix = config("redis_prefix");

  $_ = encode("UTF-8", shift);

  # learn - add a line of text to the brain
  $_ = $_." ___end___";
  $_ = lc $_;
  $_ =~ y/\,\.\!\?\(\)//d;

  # Split it into individual words
  my @words = split(' ', $_);

  # Disregard short sentences
  return if scalar(@words < 4);

  for (my $i = 0; $i <= $#words-2; $i++) {
    # $words[$i] $words[$i+1] => $words[$i+2]
    $redis->rpush("$redis_prefix:chains:$words[$i],$words[$i+1]", $words[$i+2]);
  }
}

1;
