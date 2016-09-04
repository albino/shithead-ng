package MarkovBot::Commands;
use base qw(Exporter);
use 5.010;
use strict;
use warnings;

our @EXPORT = qw(getCommandSubs);

use FindBin qw($Bin);
use lib $Bin;
use MarkovBot::Ignore;
use MarkovBot::Config;
use MarkovBot::Redis;
use Scalar::Util qw(looks_like_number);

sub commandPing() {
  return "Pong!";
}

sub commandIgnore() {
  my $command = shift;

  if (scalar( @{$command} ) != 2) {
    return "Usage: .ignore <user>";
  }

  ignore($command->[1]);
  return "Now ignoring ".$command->[1].".";
}

sub commandUnignore() {
  my $command = shift;

  if (scalar( @{$command} ) != 2) {
    return "Usage: .unignore <user>";
  }

  unignore($command->[1]);
  return "No longer ignoring ".$command->[1].".";
}

sub commandShitposting() {
  my $command = shift;
  my $chan = shift;

  if (scalar( @{$command} ) != 2 || !looks_like_number $command->[1]
      || $command->[1] > 100 || $command->[1] < 0) {
    return "Usage: .shitposting <level>";
  }

  my $redis = redis();
  my $p = config("redis_prefix");
  $redis->set("$p:".config("irc_server").":$chan:chattiness", $command->[1]);
}

sub getCommandSubs() {
  return {
    "ping" => \&commandPing,
    "ignore" => \&commandIgnore,
    "unignore" => \&commandUnignore,
    "shitposting" => \&commandShitposting,
  };
}

1;
