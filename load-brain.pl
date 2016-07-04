#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use Redis;
use FindBin qw($Bin);

use lib $Bin;

use MarkovBot::Learning;

my $brain_file = $ARGV[0];
open BRAIN, $brain_file or die $!;
learn $_ while <BRAIN>;
close BRAIN;
