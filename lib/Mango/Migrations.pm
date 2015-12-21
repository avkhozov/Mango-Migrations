package Mango::Migrations;
use Mojo::Base -base;

use Carp 'croak';
use Guard;
use Mango::BSON ':bson';
use Mojo::Loader qw/find_modules load_class/;
use Sys::Hostname 'hostname';

use constant DEBUG => $ENV{MANGO_MIGRATIONS_DEBUG} || 0;

our $VERSION = '0.01';

has 'db';
has 'namespace';
has id   => 'v1';
has name => 'migrations';

sub new {
  my $self = shift->SUPER::new(@_);

  $self->{c} = $self->db->collection($self->name);
  $self->{c}->find_and_modify(
    {query => {_id => $self->id}, update => {'$setOnInsert' => {version => 0}}, upsert => bson_true});

  return $self;
}

sub active {
  my $self = shift;
  return $self->{c}->find_one({_id => $self->id})->{version};
}

sub migrate {
  my $self = shift;

  my $c = $self->{c};

  # Try to get exclusive lock
  my $lock = {host => hostname(), pid => $$, ts => bson_time};
  my $migration = $c->find_and_modify(
    { query => {_id => $self->id, lock => {'$exists' => bson_false}},
      update => {'$set' => {lock => $lock}},
      new    => bson_false
    }
  );

  if (my $lock = $migration->{lock}) {
    croak "Document locked by $lock->{host}:$lock->{pid} at $lock->{ts}";
  }

  # Cleanup lock
  my $guard = guard {
    $c->update({_id => $self->id}, {'$set' => {version => $migration->{version}}, '$unset' => {lock => ''}});
  };

  my @migrations =
    sort { $a->version <=> $b->version }
    grep { $_->version > $migration->{version} }
    grep { $_ && $_->isa('Mango::Migrations::Migration') }
    map { my $e = load_class $_; ref $e ? undef : $_->new } find_modules $self->namespace;
  for my $m (@migrations) {
    my $version = $m->version;
    warn "Migrate to $version" if DEBUG;

    eval { $m->new->migrate($self->db) };
    croak "Error while migrate to $version: $@" if $@;

    $migration->{version} = $m->version;
  }
}

1;

__END__

=encoding utf8

=head1 NAME

Mango::Migrations - Migrations for Mango

=head1 SYNOPSIS

  use Mango::Migrations;

  my $mango = Mango->new;
  my $migrations =
    Mango::Migrations->new(db => $mango->db, catalog => './migrations');

  $migrations->migrate();

=head1 DESCRIPTION

Mango::Migrations.

=head1 LICENSE

Copyright (C) Andrey Khozov.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=head1 AUTHOR

Andrey Khozov E<lt>avkhozov@gmail.comE<gt>

=cut
