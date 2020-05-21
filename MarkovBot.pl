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

sub wordsin {
  my $str = shift;
  return scalar(split(" ", $str));
}

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
      my $ret = $subs{$bare}->(\@command, $msg->{"channel"});
      $self->say( channel => $msg->{"channel"}, body => decode("UTF-8", $ret) ) unless $ret eq "___null___";
    }

    return;

  }

  # Cheap autocomplete system
  if ($msg->{body} =~ m/^(wew|lad)$/i) {
    my $ret;
    my @o = split("", $msg->{"body"});
    my @r = split("", ($msg->{body} =~ m/wew/i) ? "lad" : "wew");
    for my $i (0..2) {
      if ($o[$i] eq uc $o[$i]) {
        $ret .= uc $r[$i];
      } else {
        $ret .= lc $r[$i];
      }
    }
    $self->say(
      channel => $msg->{"channel"},
      body => $ret,
    );
  }
  if ($msg->{body} =~ m/^ayy+$/i) {
    $self->say(
      channel => $msg->{"channel"},
      body => "lmao",
    );
  }

  my $chattiness = $redis->get("$redis_prefix:".config("irc_server").":$msg->{channel}:chattiness");
  my $rand = rand 100;
  if ($rand < $chattiness || (config("respond_on_highlight") eq "true" && $msg->{address})) {
    # generate a shitpost
    my @line = split " ", $msg->{body};
    return unless scalar(@line) >= 2;

    # Generate the best shitpost we can
    my $resp;
    for (1..20) {
      my $start = int rand $#line;
      my $post = markov( [$line[$start], $line[$start+1]] );
      $post = "" if !$post;
      $resp = $post if !$resp;
      last if wordsin($post) >= config("target_words");
      $resp = $post if wordsin($post) > wordsin($resp);
    }

    if (rand() * 100 < config("insult_chance") && !$resp) {
      $resp = config("insult");
    }

    $self->say(
      channel => $msg->{"channel"},
      body => $resp,
    ) if $resp;
  }

  # Learn
  learn $msg->{body};

}

# Set base chattiness value on first run
# Chattiness is stored per channel like this:
# prefix:irc.foo.bar:#baz:chattiness
my $redis = redis();
my $p = config("redis_prefix");
for my $chan ( @{config("irc_channels")} ) {
  if (!$redis->get("$p:".config("irc_server").":$chan:chattiness")) {
    $redis->set("$p:".config("irc_server").":$chan:chattiness", 10);
  }
}

MarkovBot->new(

  server => config("irc_server"),
  port => config("irc_port"),
  channels => config("irc_channels"),
  password => config("irc_password") ? config("irc_password") : undef,

  nick => config("irc_nickname"),
  alt_nicks => [config("irc_nickname2")],
  username => config("irc_nickname"),
  name => config("irc_nickname"),

  ssl => config("irc_ssl") eq "true" ? 1 : 0,

)->run();
