use strict;
use warnings;

use DateTime;
use DateTime::Infinite;

use Test::More;

BEGIN {use_ok('Genealogy::Gedcom::Reader::Lexer::Date');}

my($locale) = 'en_AU';

DateTime -> DefaultLocale($locale);

# Candidate value => Result hashref.

my(%duration) =
(
en_AU =>
{
		'From 0' =>
		{
		one           => '0000-01-01T00:00:00',
		one_ambiguous => 1,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 1000),
		two           => DateTime::Infinite::Future -> new,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime::Infinite::Future -> new,
		},
		'From 0 BC' =>
		{
		one           => '0000-01-01T00:00:00',
		one_ambiguous => 1,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 1000),
		two           => DateTime::Infinite::Future -> new,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime::Infinite::Future -> new,
		},
		'From 0 to 99' =>
		{
		one           => '0000-01-01T00:00:00',
		one_ambiguous => 1,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 1000),
		two           => '0099-01-01T00:00:00',
		two_ambiguous => 1,
		two_bc        => 0,
		two_date      => DateTime -> new(year => 1099),
		},
		'From 1 Jan 2001 to 25 Dec 2002' =>
		{
		one           => DateTime -> new(year => 2001, month => 1, day => 1),
		one_ambiguous => 1,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2001, month => 1,  day => 1),
		two           => DateTime -> new(year => 2002, month => 12, day => 25),
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime -> new(year => 2002, month => 12, day => 25),
		},
		'From 25 Dec 2002 to 1 Jan 2001' => # A retrograde example.
		{
		one           => DateTime -> new(year => 2002, month => 12, day => 25),
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2002, month => 12, day => 25),
		two           => DateTime -> new(year => 2001, month => 1, day => 1),
		two_ambiguous => 1,
		two_bc        => 0,
		two_date      => DateTime -> new(year => 2001, month => 1, day => 1),
		},
		'From 2011' =>
		{
		one           => DateTime -> new(year => 2011),
		one_ambiguous => 1,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2011),
		two           => DateTime::Infinite::Future -> new,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime::Infinite::Future -> new,
		},
		'From 21 Jun 6004BC.' =>
		{
		one           => DateTime -> new(year => 6004, month => 6, day => 21),
		one_ambiguous => 0,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 6004, month => 6, day => 21),
		two           => DateTime::Infinite::Future -> new,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime::Infinite::Future -> new,
		},
		'From 500B.C.' =>
		{
		one           => '0500-01-01T00:00:00',
		one_ambiguous => 1,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 1500),
		two           => DateTime::Infinite::Future -> new,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime::Infinite::Future -> new,
		},
		'From 500BC' =>
		{
		one           => '0500-01-01T00:00:00',
		one_ambiguous => 1,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 1500),
		two           => DateTime::Infinite::Future -> new,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime::Infinite::Future -> new,
		},
		'From 500BC.' =>
		{
		one           => '0500-01-01T00:00:00',
		one_ambiguous => 1,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 1500),
		two           => DateTime::Infinite::Future -> new,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime::Infinite::Future -> new,
		},
		'From 500BC to 400' =>
		{
		one           => '0500-01-01T00:00:00',
		one_ambiguous => 1,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 1500),
		two           => '0400-01-01T00:00:00',
		two_ambiguous => 1,
		two_bc        => 0,
		two_date      => DateTime -> new(year => 1400),
		},
		'From 500BC to 400BC' =>
		{
		one           => '0500-01-01T00:00:00',
		one_ambiguous => 1,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 1500),
		two           => '0400-01-01T00:00:00',
		two_ambiguous => 1,
		two_bc        => 1,
		two_date      => DateTime -> new(year => 1400),
		},
		'From @#DGREGORIAN@ 1 Jan 2000' =>
		{
		one           => DateTime -> new(year => 2000, month => 1, day => 1),
		one_ambiguous => 1,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2000),
		two           => DateTime::Infinite::Future -> new,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime::Infinite::Future -> new,
		},
		'To 2011' =>
		{
		one           => DateTime::Infinite::Past -> new,
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime::Infinite::Past -> new,
		two           => DateTime -> new(year => 2011),
		two_ambiguous => 1,
		two_bc        => 0,
		two_date      => DateTime -> new(year => 2011),
		},
		'To 500 BC' =>
		{
		one           => DateTime::Infinite::Past -> new,
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime::Infinite::Past -> new,
		two           => '0500-01-01T00:00:00',
		two_ambiguous => 1,
		two_bc        => 1,
		two_date      => DateTime -> new(year => 1500),
		},
}
);

my($parser) = Genealogy::Gedcom::Reader::Lexer::Date -> new(debug => 1);

isa_ok($parser, 'Genealogy::Gedcom::Reader::Lexer::Date');

my($date);
my($in_string);
my($out_string);

for my $duration (sort keys %{$duration{$locale} })
{
		$date       = $parser -> parse_duration(period => $duration);
		$in_string  = join(', ', map{"$_ => '$duration{$locale}{$duration}{$_}'"} sort keys %{$duration{$locale}{$duration} });
		$out_string = join(', ', map{"$_ => '$$date{$_}'"} sort keys %$date);

		ok($in_string eq $out_string, "Testing: $duration");

		if ($parser -> debug)
		{
				diag "In:  $in_string.";
				diag "Out: $out_string";
				diag "##########################################";
		}
}

my(%period) =
(
en_AU =>
{
		'(Unknown date)' =>
		{
		escape          => 'dgregorian',
		one           => '-inf',
		one_ambiguous => 0,
		one_bc        => 0,
		infix           => '',
		two            => 'inf',
		two_ambiguous  => 0,
		two_bc         => 0,
		phrase          => 'unknown date',
		prefix          => '',
		},
		'2011' =>
		{
		escape          => 'dgregorian',
		one           => DateTime -> new(year => 2011),
		one_ambiguous => 1,
		one_bc        => 0,
		infix           => '',
		two            => 'inf',
		two_ambiguous  => 0,
		two_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'0 BC' =>
		{
		escape          => 'dgregorian',
		one           => DateTime -> new(year => 1000),
		one_ambiguous => 1,
		one_bc        => 1,
		infix           => '',
		two            => 'inf',
		two_ambiguous  => 0,
		two_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'500 BC' =>
		{
		escape          => 'dgregorian',
		one           => DateTime -> new(year => 1500),
		one_ambiguous => 1,
		one_bc        => 1,
		infix           => '',
		two            => 'inf',
		two_ambiguous  => 0,
		two_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'500B.C.' =>
		{
		escape          => 'dgregorian',
		one           => DateTime -> new(year => 1500),
		one_ambiguous => 1,
		one_bc        => 1,
		infix           => '',
		two            => 'inf',
		two_ambiguous  => 0,
		two_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'500BC' =>
		{
		escape          => 'dgregorian',
		one           => DateTime -> new(year => 1500),
		one_ambiguous => 1,
		one_bc        => 1,
		infix           => '',
		two            => 'inf',
		two_ambiguous  => 0,
		two_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'500BC.' =>
		{
		escape          => 'dgregorian',
		one           => DateTime -> new(year => 1500),
		one_ambiguous => 1,
		one_bc        => 1,
		infix           => '',
		two            => 'inf',
		two_ambiguous  => 0,
		two_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'21 Jun 6004BC.' =>
		{
		escape          => 'dgregorian',
		one           => DateTime -> new(year => 7004, month => 6, day => 21),
		one_ambiguous => 0,
		one_bc        => 1,
		infix           => '',
		two            => 'inf',
		two_ambiguous  => 0,
		two_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'@#DGREGORIAN@ 1 Jan 2000' =>
		{
		escape          => 'dgregorian',
		one           => DateTime -> new(year => 2000, month => 1, day => 1),
		one_ambiguous => 0,
		one_bc        => 0,
		infix           => '',
		two            => 'inf',
		two_ambiguous  => 0,
		two_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'Abt 1999 (Unsure of date)' =>
		{
		escape          => 'dgregorian',
		one           => DateTime -> new(year => 1999),
		one_ambiguous => 1,
		one_bc        => 0,
		infix           => '',
		two            => 'inf',
		two_ambiguous  => 0,
		two_bc         => 0,
		phrase          => 'unsure of date',
		prefix          => 'about',
		},
		'Bef 3 Mar 2003' =>
		{
		escape          => 'dgregorian',
		one           => DateTime -> new(year => 2003, month => 3, day => 3),
		one_ambiguous => 0,
		one_bc        => 0,
		infix           => '',
		two            => 'inf',
		two_ambiguous  => 0,
		two_bc         => 0,
		phrase          => '',
		prefix          => 'before',
		},
		'Bet 4 Apr 2004 and 5 May 2005' =>
		{
		escape          => 'dgregorian',
		one           => DateTime -> new(year => 2004, month => 4, day => 4),
		one_ambiguous => 0,
		one_bc        => 0,
		infix           => 'and',
		two            => DateTime -> new(year => 2005, month => 5, day => 5),
		two_ambiguous  => 0,
		two_bc         => 0,
		phrase          => '',
		prefix          => 'between',
		},
		'From 1 Jan 2001 to 2 Feb 2002' =>
		{
		escape          => 'dgregorian',
		one           => DateTime -> new(year => 2001, month => 1, day => 1),
		one_ambiguous => 0,
		one_bc        => 0,
		infix           => 'to',
		two            => DateTime -> new(year => 2002, month => 2, day => 2),
		two_ambiguous  => 0,
		two_bc         => 0,
		phrase          => '',
		prefix          => 'from',
		},
}
);

done_testing;
