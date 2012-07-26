package Dist::Zilla::PluginBundle::Heroku;
# ABSTRACT: the basic plugins to release an application on Heroku
use Moose;
with 'Dist::Zilla::Role::PluginBundle::Easy';

use namespace::autoclean;

sub configure {
  my ($self) = @_;

  $self->add_plugins(qw(
    Git
    CPANFile
    HerokuInit
    HerokuRelease
  ));
}

__PACKAGE__->meta->make_immutable;
1;
