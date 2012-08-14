package Dist::Zilla::Plugin::Heroku::Init;

use strict;
use warnings;
use Moose;
use Try::Tiny;

with 'Dist::Zilla::Role::BeforeRelease';

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

has buildpack => (
  is => 'ro',
  isa => 'Str',
);

has account => (
  is => 'ro',
  isa => 'Str',
  predicate => 'has_account',
);


1;
