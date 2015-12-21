use strict;
use warnings;

use Test::More;
use Mango;

use lib 't/lib';

plan skip_all => 'set TEST_ONLINE to enable this test' unless $ENV{TEST_ONLINE};

use_ok 'Mango::Migrations';

my $mango = Mango->new($ENV{TEST_ONLINE});

# Cleanup
$mango->db->command({dropDatabase => 1});
is $mango->db->collection('migrations')->options, undef, 'Right collection status';

my $migrations = Mango::Migrations->new(db => $mango->db, namespace => 'MyMigrations');
is $migrations->active, 0, 'Right active version';

$migrations->migrate;

is $migrations->active, 1, 'Right active version';

done_testing;
