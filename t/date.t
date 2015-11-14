use strict;
use warnings;

use Test::More;

BEGIN {use_ok('Genealogy::Gedcom::Date');}

my($parser) = Genealogy::Gedcom::Date -> new;

isa_ok($parser, 'Genealogy::Gedcom::Date');

my($date);
my($in_string);
my($out_string);

# Candidate value => Result hashref.

diag 'Start testing parse(...)';

my(%datetime) =
(
	'15 Jul 1954' => {},
);

for my $candidate (sort keys %datetime)
{
	$date    = $parser -> parse(date => $candidate);
	$expect  = $datetime{$candidate};

	ok($got eq $expect, "Testing: $candidate");
}

done_testing;
