[![Build Status](https://travis-ci.org/avkhozov/Mango-Migrations.svg?branch=master)](https://travis-ci.org/avkhozov/Mango-Migrations)
# NAME

Mango::Migrations - Migrations for Mango

# SYNOPSIS

    use Mango::Migrations;

    my $mango = Mango->new;
    my $migrations =
      Mango::Migrations->new(db => $mango->db, catalog => './migrations');

    $migrations->migrate();

# DESCRIPTION

Mango::Migrations.

# LICENSE

Copyright (C) Andrey Khozov.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

# AUTHOR

Andrey Khozov &lt;avkhozov@gmail.com>
