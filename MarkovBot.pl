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
use MarkovBot::MarkovChain;
use MarkovBot::Redis;
use Encode qw(encode decode);
use if (config("rng") eq "mt"), "Math::Random::MT::Perl" => qw(rand);

sub said {
  my $self = shift;
  my $msg = shift;
  my $command_char = quotemeta config "command_character";
  my $redis = redis();
  my $redis_prefix = config("redis_prefix");

  # Ignore PMs and ignored users
  return if $msg->{channel} eq 'msg';
  return if isIgnored($msg->{who});

  # Intercept commands
  if ($msg->{body} =~ m/^$command_char.+/) {
    
    my $command = encode("UTF-8", $msg->{body});
    my @command = split(" ", $command);
    my $bare = $command[0];
    $bare =~ s/^$command_char//;

    my %subs = %{getCommandSubs()};

    if (defined $subs{$bare}) {
      my $ret = $subs{$bare}->(\@command);
      $self->say( channel => config("irc_channel"), body => decode("UTF-8", $ret) ) unless $ret eq "___null___";
    }

    return;

  }
  if ($msg->{body} eq 'wew') {
    $self->say(channel => config("irc_channel"), body => "lad");
  }
  my $chattiness = $redis->get("$redis_prefix:chattiness");
  if (rand 100 < $chattiness) {
    # generate a shitpost
    my @line = split " ", $msg->{body};
    return unless scalar(@line) > 1;
    my $start = int rand $#line;
    my $resp = markov( [$line[$start], $line[$start+1]] );
    $resp = config("insult") unless $resp;

    $self->say(
      channel => config("irc_channel"),
      body => $resp,
    );
  }

  # Learn
  learn $msg->{body};

}

# Set base chattiness value on first run
my $redis = redis();
my $p = config("redis_prefix");
if (!$redis->get("$p:chattiness")) {
  $redis->set("$p:chattiness", 10);
}

MarkovBot->new(

  server => config("irc_server"),
  port => config("irc_port"),
  channels => [config("irc_channel")],

  nick => config("irc_nickname"),
  alt_nicks => [config("irc_nickname2")],
  username => config("irc_nickname"),
  name => config("irc_nickname"),

  ssl => config("irc_ssl") eq "true" ? 1 : 0,

)->run();
