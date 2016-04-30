package MarkovBot::Commands;
use base qw(Exporter);

our @EXPORT = qw(getCommandSubs);

use FindBin qw($Bin);
use lib $Bin;
use MarkovBot::Ignore;

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

sub getCommandSubs() {
  return {
    "ping" => \&commandPing,
    "ignore" => \&commandIgnore,
    "unignore" => \&commandUnignore,
  };
}

1;
