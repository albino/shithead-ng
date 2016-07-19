package MarkovBot::MarkovChain;
use base qw(Exporter);
use 5.010;
use strict;
use warnings;

our @EXPORT = qw(markov);

use FindBin qw($Bin);
use lib $Bin;

use MarkovBot::Config;
use MarkovBot::Redis;
use Encode qw(decode encode);
use if (config("rng") eq "mt"), "Math::Random::MT::Perl" => qw(rand);

sub markov( $ ) {
  # markov - given two starting words, returns a markov chain result

  my $redis = redis;
  my $p = config "redis_prefix";

  my $s = shift;
  my @s = @{$s};
  @s = map {encode("UTF-8", $_)} @s;

  if (!$redis->llen("$p:chains:$s[0],$s[1]")) {
    # Phrase is not known
    return undef;
  }

  while (1) {
    # get next word
    my $len = $redis->llen("$p:chains:$s[$#s-1],$s[$#s]");
    my $pos = int(rand($len));
    push @s, $redis->lrange("$p:chains:$s[$#s-1],$s[$#s]", $pos, $pos);
    last if $s[$#s] eq "___end___";
  }

  pop @s;
  @s = map {decode("UTF-8", $_)} @s;
  return join " ", @s;
}

1;
