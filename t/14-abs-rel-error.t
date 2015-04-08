#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use Statistics::Descriptive::LogScale;

my $stat = Statistics::Descriptive::LogScale->new(
	absolute_error => 0.5, relative_error => 0.01
);

note "Real abs/rel error: ", $stat->absolute_error, " ", $stat->relative_error;
cmp_ok( $stat->absolute_error, ">", 0, "abs greater than zero" );
cmp_ok( $stat->absolute_error, "<=", 0.5000000000001,
	"abs error is less than requested");
cmp_ok( $stat->relative_error, ">", 0, "rel greater than zero");
cmp_ok( $stat->relative_error, "<=", 0.01000000000001,
	"rel error is less than requested");
# OK, this is an ugly rounding hack. I found no better.

# Now try to add some data and see whether our class can distinguish
# between points.
$stat->add_data(-50..50);
my $raw = $stat->get_data_hash;
my @duplicate = grep { $raw->{$_} > 1 } sort { $a <=> $b } keys %$raw;
is (scalar @duplicate, 0, "No duplicates in raw bucket data")
	or diag "Duplicated entries: @duplicate";
note "The hash was: ", explain($raw);

$stat->clear;

# Now try to add log data, let's see if that makes different points

$stat->add_data(map { 100 * 1.0201 ** $_ } 1..500 ); # be careful - 1.02 fails
$raw = $stat->get_data_hash;
@duplicate = grep { $raw->{$_} > 1 } sort { $a <=> $b } keys %$raw;
is (scalar @duplicate, 0, "No duplicates in raw bucket data")
	or diag "Duplicated entries: @duplicate";
# note "The hash was: ", explain($raw);


done_testing;

