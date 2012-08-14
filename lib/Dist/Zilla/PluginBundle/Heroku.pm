package Dist::Zilla::PluginBundle::Heroku;
# ABSTRACT: the basic plugins to release an application on Heroku
use Moose;
with 'Dist::Zilla::Role::PluginBundle::Easy';

use namespace::autoclean;

my @names = qw{ Init Release };

sub configure {
  my ($self) = @_;

  $self->add_plugins(qw(
    Git
    CPANFile
    Heroku::Init
    Heroku::Release
  ));
}

sub bundle_config {
  my ( $self, $section ) = @_;
  my $arg = $section->{payload};

  my @config;

  for my $name (@names) {
    my $class = "Dist::Zilla::Plugin::Heroku::$name";
    my %payload;
    foreach my $k ( keys %$arg ) {
      $payload{$k} = $arg->{$k} if $class->can($k);
    }
    push @config, [ "$section->{name}/$name" => $class => \%payload ];
  }

  return @config;
}

__PACKAGE__->meta->make_immutable;
1;
