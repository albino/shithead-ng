# shithead-ng

next generation markov chain irc shitposting bot

### The problem
The original shithead uses far too much ram and is badly implemented.

### The solution
Let's reimplement it and get redis to do all the heavy lifting.

## Getting Started
A brainfile is simply an irc log with all joins, parts, timestamps and nicknames stripped. In other words, it contains only what was said.

```bash
# if you have an old brainfile, import it into redis
perl import-brain.pl /home/you/brainfile
# this can take a long time (about ten minutes for me), so be patient
```

```bash
# now, you need a config file
cp config.default.yml config.yml
# edit the values in config.yml to your choosing
```

Now, just run `perl MarkovBot.pl`.

## Commands

* .shitposting - controls the % of messages the bot will reply to
```
< user> .shitposting 1.5
< shithead-ng> OK
```

* .ignore - make the bot totally ignore a user (useful for bots)
```
< user> .ignore bot
< shithead-ng> Now ignoring bot.
```

* .unignore - removes a user from the ignore list
```
< user> .unignore bot
< shithead-ng> No longer ignoring bot.
```

* .ping - check that shithead-ng is still alive
```
< user> .ping
< shithead-ng> Pong!
```
