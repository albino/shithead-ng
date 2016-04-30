package MarkovBot::Redis;
use base qw(Exporter);

our @EXPORT = qw(redis);

use Redis;

sub redis() {
  # Returns a redis object
  # This is fairly useless but in the future could be used to
  # pass specific options to redis.

  return Redis->new();
}

1;
