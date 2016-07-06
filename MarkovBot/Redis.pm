package MarkovBot::Redis;
use base qw(Exporter);
use 5.010;
use strict;
use warnings;

our @EXPORT = qw(redis);

use Redis;
use FindBin qw($Bin);
use lib $Bin;
use MarkovBot::Config;

sub redis() {
  # Returns a redis object
  # This is fairly useless but in the future could be used to
  # pass specific options to redis.
  #
  # TODO: support connection to redis via a socket

  return new Redis (
    server => config("redis_server"),
    password => (config("redis_usepass") eq "true") ? config("redis_password") : undef,
  );
}

1;
