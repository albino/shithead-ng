# shithead-ng

next generation markov chain irc shitposting bot

### The problem
The original shithead uses far too much ram and is badly implemented.

### The solution
Let's reimplement it and get redis to do all the heavy lifting.

## Getting Started
First, set up dependencies. You need a redis server running locally (currently, AUTH and remote servers are not supported, this will be supported in the future) and the necessary perl modules:

```bash
# install cpanminus with your package manager of choice (preferred), or install it through cpan:
cpan App::cpanminus
# clone the git repo if you haven't already, then install the perl modules
git clone https://neetco.de/albino/shithead-ng
cpanm --installdeps shithead-ng
# or, to avoid setting up local::lib:
cpanm --sudo --installdeps shithead-ng
```

Next, you need a brainfile. A brainfile is simply an irc log with all joins, parts, timestamps and nicknames stripped. In other words, it contains only what was said.

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

## Exporting the brainfile

```bash
perl export-brain.pl > brain
```

This produces a shithead-ng brainfile which cannot (currently) be read by other programs. This is because the redis database does not contain enough information to reconstruct the brainfile it was created from. This file can, however, be read by shithead-ng's import-brain.pl.
