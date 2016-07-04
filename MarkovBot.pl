#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use FindBin qw($Bin);

use lib $Bin;

package MarkovBot;
use base qw/Bot::BasicBot/;

use MarkovBot::Config;
use MarkovBot::Learning;
use MarkovBot::Ignore;
use MarkovBot::Commands;

sub said {
  my $self = shift;
  my $msg = shift;
  my $command_char = config "command_character";

  # Ignore PMs and ignored users
  return if $msg->{channel} eq 'msg';
  return if isIgnored($msg->{who});

  # Intercept commands
  if ($msg->{body} =~ m/^$command_char.+/) {
    
    my $command = $msg->{body};
    my @command = split(" ", $command);
    my $bare = $command[0];
    $bare =~ s/^$command_char//;

    my %subs = %{getCommandSubs()};

    if (defined $subs{$bare}) {
      my $ret = $subs{$bare}->(\@command);
      $self->say( channel => config("irc_channel"), body => $ret ) unless $ret eq "___null___";
    }

  }

  # Learn
  learn $msg->{body};

}

MarkovBot->new(

  server => config("irc_server"),
  port => config("irc_port"),
  channels => [config("irc_channel")],

  nick => config("irc_nickname"),
  alt_nicks => [config("irc_nickname2")],
  username => config("irc_nickname"),
  name => config("irc_nickname"),

)->run();
