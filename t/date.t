use strict;
use warnings;

use DateTime;

use Test::More;

BEGIN {use_ok('Genealogy::Gedcom::Reader::Lexer::Date');}

my($locale) = 'en_AU';

# Candidate value => Result hashref.

my(%duration) =
(
en_AU =>
{
		'From 0 BC' =>
		{
		first             => DateTime -> new(year => 1000, locale => $locale),
		first_ambiguous   => 1,
		first_bc          => 1,
		#first_offset      => 1,
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		#second_offset     => 0,
		},
		'From 1 Jan 2001 to 2 Feb 2002' =>
		{
		first             => DateTime -> new(year => 2001, month => 1, day => 1, locale => $locale),
		first_ambiguous   => 0,
		first_bc          => 0,
		#first_offset      => 0,
		second            => DateTime -> new(year => 2002, month => 2, day => 2, locale => $locale),
		second_ambiguous  => 0,
		second_bc         => 0,
		#second_offset     => 0,
		},
		'From 2011' =>
		{
		first             => DateTime -> new(year => 2011, locale => $locale),
		first_ambiguous   => 1,
		first_bc          => 0,
		#first_offset      => 0,
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		#second_offset     => 0,
		},
		'From 21 Jun 6004BC.' =>
		{
		first             => DateTime -> new(year => 7004, month => 6, day => 21, locale => $locale),
		first_ambiguous   => 0,
		first_bc          => 1,
		#first_offset      => 0,
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		#second_offset     => 0,
		},
		'From 500B.C.' =>
		{
		first             => DateTime -> new(year => 1500, locale => $locale),
		first_ambiguous   => 1,
		first_bc          => 1,
		#first_offset      => 1,
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		#second_offset     => 0,
		},
		'From 500BC' =>
		{
		first             => DateTime -> new(year => 1500, locale => $locale),
		first_ambiguous   => 1,
		first_bc          => 1,
		#first_offset      => 1,
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		#second_offset     => 0,
		},
		'From 500BC.' =>
		{
		first             => DateTime -> new(year => 1500, locale => $locale),
		first_ambiguous   => 1,
		first_bc          => 1,
		#first_offset      => 1,
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		#second_offset     => 0,
		},
		'From @#DGREGORIAN@ 1 Jan 2000' =>
		{
		first             => DateTime -> new(year => 2000, month => 1, day => 1, locale => $locale),
		first_ambiguous   => 0,
		first_bc          => 0,
		#first_offset      => 0,
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		#second_offset     => 0,
		},
		'To 2011' =>
		{
		first             => DateTime -> new(year => 2011, locale => $locale),
		first_ambiguous   => 1,
		first_bc          => 0,
		#first_offset      => 0,
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		#second_offset     => 0,
		},
		'To 500 BC' =>
		{
		first             => DateTime -> new(year => 1500, locale => $locale),
		first_ambiguous   => 1,
		first_bc          => 1,
		#first_offset      => 1,
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		#second_offset     => 0,
		},
}
);

my($parser) = Genealogy::Gedcom::Reader::Lexer::Date -> new(locale => $locale);

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

		if ($ENV{AUTHOR_TEST})
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
		first           => '-inf',
		first_ambiguous => 0,
		first_bc        => 0,
		infix           => '',
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		phrase          => 'unknown date',
		prefix          => '',
		},
		'2011' =>
		{
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 2011, locale => $locale),
		first_ambiguous => 1,
		first_bc        => 0,
		infix           => '',
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'0 BC' =>
		{
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 1000, locale => $locale),
		first_ambiguous => 1,
		first_bc        => 1,
		infix           => '',
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'500 BC' =>
		{
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 1500, locale => $locale),
		first_ambiguous => 1,
		first_bc        => 1,
		infix           => '',
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'500B.C.' =>
		{
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 1500, locale => $locale),
		first_ambiguous => 1,
		first_bc        => 1,
		infix           => '',
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'500BC' =>
		{
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 1500, locale => $locale),
		first_ambiguous => 1,
		first_bc        => 1,
		infix           => '',
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'500BC.' =>
		{
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 1500, locale => $locale),
		first_ambiguous => 1,
		first_bc        => 1,
		infix           => '',
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'21 Jun 6004BC.' =>
		{
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 7004, month => 6, day => 21, locale => $locale),
		first_ambiguous => 0,
		first_bc        => 1,
		infix           => '',
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'@#DGREGORIAN@ 1 Jan 2000' =>
		{
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 2000, month => 1, day => 1, locale => $locale),
		first_ambiguous => 0,
		first_bc        => 0,
		infix           => '',
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		phrase          => '',
		prefix          => '',
		},
		'Abt 1999 (Unsure of date)' =>
		{
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 1999, locale => $locale),
		first_ambiguous => 1,
		first_bc        => 0,
		infix           => '',
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		phrase          => 'unsure of date',
		prefix          => 'about',
		},
		'Bef 3 Mar 2003' =>
		{
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 2003, month => 3, day => 3, locale => $locale),
		first_ambiguous => 0,
		first_bc        => 0,
		infix           => '',
		second            => 'inf',
		second_ambiguous  => 0,
		second_bc         => 0,
		phrase          => '',
		prefix          => 'before',
		},
		'Bet 4 Apr 2004 and 5 May 2005' =>
		{
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 2004, month => 4, day => 4, locale => $locale),
		first_ambiguous => 0,
		first_bc        => 0,
		infix           => 'and',
		second            => DateTime -> new(year => 2005, month => 5, day => 5, locale => $locale),
		second_ambiguous  => 0,
		second_bc         => 0,
		phrase          => '',
		prefix          => 'between',
		},
		'From 1 Jan 2001 to 2 Feb 2002' =>
		{
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 2001, month => 1, day => 1, locale => $locale),
		first_ambiguous => 0,
		first_bc        => 0,
		infix           => 'to',
		second            => DateTime -> new(year => 2002, month => 2, day => 2, locale => $locale),
		second_ambiguous  => 0,
		second_bc         => 0,
		phrase          => '',
		prefix          => 'from',
		},
}
);

done_testing;
