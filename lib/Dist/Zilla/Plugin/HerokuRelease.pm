package Dist::Zilla::Plugin::HerokuRelease;

use strict;
use warnings;

use Moose;
use Git::Wrapper;
use MooseX::Types::Moose qw{ ArrayRef Str };
 
with 'Dist::Zilla::Role::Releaser';
with 'Dist::Zilla::Role::Git::Repo';
 
sub mvp_multivalue_args { qw(push_to) }
 
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
