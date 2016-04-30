package MarkovBot::Config;
use base qw(Exporter);

our @EXPORT = qw(config);

use FindBin qw($Bin);
use YAML::Tiny;

sub config( $ ) {
  # config(var)
  # returns config value
  
  my $var = shift;
  
  my $yaml = YAML::Tiny->read( "$Bin/config.yml" );
  return $yaml->[0]->{$var};
}

1;
