package MyMigrations::V1;
use Mojo::Base 'Mango::Migrations::Migration';

has version => 1;

sub migrate {
  my ($self, $db) = @_;

  $db->collection('from_migrations')->insert({a => 1, b => 'test'});
}

1;
