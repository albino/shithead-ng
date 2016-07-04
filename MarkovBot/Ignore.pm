package MarkovBot::Ignore;
use base qw(Exporter);
use 5.010;
use strict;
use warnings;

our @EXPORT = qw(ignore unignore isIgnored);

use FindBin qw($Bin);
use lib $Bin;

use MarkovBot::Config;
use MarkovBot::Redis;

sub ignore( $ ) {
  # ignore($user)

  my $user = shift;
  my $redis = redis();
  my $redis_prefix = config("redis_prefix");

  $redis->sadd("$redis_prefix:ignore", $user);
}

sub unignore( $ ) {
  # unignore($user)
  
  my $user = shift;
  my $redis = redis();
  my $redis_prefix = config("redis_prefix");

  $redis->srem("$redis_prefix:ignore", $user);
}

sub isIgnored( $ ) {
  # isIngored($user)
  # returns 0 or 1

  my $user = shift;
  my $redis = redis();
  my $redis_prefix = config("redis_prefix");

  return $redis->sismember("$redis_prefix:ignore", $user);
}

1;
