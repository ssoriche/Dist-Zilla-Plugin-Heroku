package Dist::Zilla::Plugin::HerokuInit;

use strict;
use warnings;
use Moose;
use Try::Tiny;

with 'Dist::Zilla::Role::BeforeRelease';

has config_entries => (
  is   => 'ro',
  isa  => 'ArrayRef[Str]',
  default => sub { [] },
);

sub mvp_multivalue_args { qw(config_entries remotes) }
sub mvp_aliases { return { config => 'config_entries', remote => 'remotes' } }

sub before_release {
  my $self = shift;
  my ($opts) = @_;
  my $git = Git::Wrapper->new($opts->{mint_root});
  # Make sure there is a git repository

  try {
    $git->status;
  }
  catch {
    my $error = $_;
  };
  # Make sure there isn't a remote called Heroku (or configed to a different name)
  # Create a new remote for Heroku
  # Use the buildpack specified in the config to set up Heroku
    $self->log("Initializing a new git repository in " . $opts->{mint_root});
    $git->init;

    foreach my $configSpec (@{ $self->config_entries }) {
      my ($option, $value) = split ' ', _format_string($configSpec, $self), 2;
      $self->log_debug("Configuring $option $value");
      $git->config($option, $value);
    }

    $git->add($opts->{mint_root});
    $git->commit({message => _format_string($self->commit_message, $self)});
    foreach my $remoteSpec (@{ $self->remotes }) {
      my ($remote, $url) = split ' ', _format_string($remoteSpec, $self), 2;
      $self->log_debug("Adding remote $remote as $url");
      $git->remote(add => $remote, $url);
    }
}

1;
