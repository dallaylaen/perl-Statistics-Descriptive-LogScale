#!/usr/bin/perl -w

# This is a simple script that reads numbers from STDIN
# and prints out a summary at EOF.

use strict;
use Statistics::Descriptive::LogScale;

my $can_size = eval { require Devel::Size; 1; };
# use Statistics::Descriptive;

my $base;
my $floor;

# Don't require module just in case
if ( eval { require Getopt::Long; 1; } ) {
	Getopt::Long->import;
	GetOptions (
		'base=s' => \$base,
		'floor=s' => \$floor,
		'help' => sub {
			print "Usage: $0 [--base <1+small o> --floor <nnn>]\n";
			print "Read numbers from STDIN, output stat summary\n";
			exit 2;
		},
	);
} else {
	@ARGV and die "Options given, but no Getopt::Long support";
};

my $stat = Statistics::Descriptive::LogScale->new(
	base => $base, zero_thresh => $floor);
# my $stat = Statistics::Descriptive::Full->new();

while (<STDIN>) {
	$stat->add_data(/(-?\d+(?:\.\d*)?)/g);
};

print_result();

if ($can_size) {
	print "Memory usage: ".Devel::Size::total_size($stat)."\n";
};

sub print_result {
	printf "Count: %u\nAverage: %f +- %f\nRange: %f .. %f\n",
		$stat->count, $stat->mean, $stat->standard_deviation,
		$stat->min, $stat->max;
	printf "Percentiles:\n";
	foreach (0.5, 1, 5, 10, 25, 50, 75, 90, 95, 99, 99.5) {
		my $x = $stat->percentile($_);
		$x = "-inf" unless defined $x;
		printf "%4.1f: %f\n", $_, $x;
	};
};

