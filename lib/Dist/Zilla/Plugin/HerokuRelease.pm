package Dist::Zilla::Plugin::HerokuRelease;

use strict;
use warnings;

use Moose;
use Git::Wrapper;
use MooseX::Types::Moose qw{ ArrayRef Str };
 
with 'Dist::Zilla::Role::Releaser';
with 'Dist::Zilla::Role::Git::Repo';
 
has remote => (
  is => 'ro',
  isa => 'Str',
  default => 'heroku',
);

has branch => (
  is => 'ro',
  isa => 'Str',
  default => 'heroku_release/master',
);

has stack => (
  is => 'ro',
  isa => 'Str',
  default => 'cedar',
);

has account => (
  is => 'ro',
  isa => 'Str',
  predicate => 'has_account',
);
 
has push_to => (
  is   => 'ro',
  isa  => 'ArrayRef[Str]',
  lazy => 1,
  default => sub { [ qw(heroku) ] },
);
 
 
sub release {
  my $self = shift;
  my $git  = Git::Wrapper->new( $self->repo_root );

  for my $remote ( @{ $self->push_to } ) { 
    $self->log("pushing to $remote");
    my @remote = split(/\s+/,$remote);
    $self->log_debug($_) for $git->push( @remote );
  }
}

1;
