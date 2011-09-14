use strict;
use warnings;

use DateTime;
use DateTime::Infinite;

use Test::More;

BEGIN {use_ok('DateTime::Format::Gedcom');}

my($locale) = 'en_AU';

DateTime -> DefaultLocale($locale);

my($parser) = DateTime::Format::Gedcom -> new(debug => 0);

isa_ok($parser, 'DateTime::Format::Gedcom');

my($date);
my($in_string);
my($out_string);

# Candidate value => Result hashref.

diag 'Start testing parse_datetime(...)';

my(%datetime) =
(
en_AU =>
{
		'15 Jul 1954' =>
		{
		one           => DateTime -> new(year => 1954, month => 7, day => 15),
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 1954, month => 7, day => 15),
		phrase        => '',
		prefix        => '',
		two           => DateTime::Infinite::Future -> new,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime::Infinite::Future -> new,
		},
}
);

for my $candidate (sort keys %{$datetime{$locale} })
{
		$date = $parser -> parse_datetime($candidate);

		$in_string  = join(', ', map{"$_ => '$datetime{$locale}{$candidate}{$_}'"} sort keys %{$datetime{$locale}{$candidate} });
		$out_string = join(', ', map{"$_ => '$$date{$_}'"} sort keys %$date);

		if ($parser -> debug)
		{
				diag "In:  $in_string.";
				diag "Out: $out_string";
		}

		ok($in_string eq $out_string, "Testing: $candidate");
}

done_testing;
