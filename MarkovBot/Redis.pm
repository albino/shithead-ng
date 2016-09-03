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
  # TODO: support connection to redis via a socket

  return new Redis (
    server => config("redis_server"),
    password => (config("redis_usepass") eq "true") ? config("redis_password") : undef,
  );
}

1;
