use strict;
use warnings;

use DateTime;

use Test::More;

BEGIN {use_ok('Genealogy::Gedcom::Reader::Lexer::Date');}

my($locale) = 'en_AU';
my($parser) = Genealogy::Gedcom::Reader::Lexer::Date -> new(locale => $locale, logger => '');

isa_ok($parser, 'Genealogy::Gedcom::Reader::Lexer::Date');

# Candidate value => Result hashref.

my(%candidate) =
(
en_AU =>
{
		'(Unknown date)' =>
		{
		century         => 1900,
		escape          => 'dgregorian',
		first           => '-inf',
		first_ambiguous => 0,
		first_bc        => 0,
		infix           => '',
		last            => 'inf',
		last_ambiguous  => 0,
		last_bc         => 0,
		locale          => 'en_AU',
		phrase          => 'unknown date',
		prefix          => '',
		},
		'2011' =>
		{
		century         => 1900,
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 2011, locale => $locale),
		first_ambiguous => 1,
		first_bc        => 0,
		infix           => '',
		last            => 'inf',
		last_ambiguous  => 0,
		last_bc         => 0,
		locale          => 'en_AU',
		phrase          => '',
		prefix          => '',
		},
		'0 BC' =>
		{
		century         => 1900,
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 1000, locale => $locale),
		first_ambiguous => 1,
		first_bc        => 1,
		infix           => '',
		last            => 'inf',
		last_ambiguous  => 0,
		last_bc         => 0,
		locale          => 'en_AU',
		phrase          => '',
		prefix          => '',
		},
		'500 BC' =>
		{
		century         => 1900,
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 1500, locale => $locale),
		first_ambiguous => 1,
		first_bc        => 1,
		infix           => '',
		last            => 'inf',
		last_ambiguous  => 0,
		last_bc         => 0,
		locale          => 'en_AU',
		phrase          => '',
		prefix          => '',
		},
		'500B.C.' =>
		{
		century         => 1900,
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 1500, locale => $locale),
		first_ambiguous => 1,
		first_bc        => 1,
		infix           => '',
		last            => 'inf',
		last_ambiguous  => 0,
		last_bc         => 0,
		locale          => 'en_AU',
		phrase          => '',
		prefix          => '',
		},
		'500BC' =>
		{
		century         => 1900,
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 1500, locale => $locale),
		first_ambiguous => 1,
		first_bc        => 1,
		infix           => '',
		last            => 'inf',
		last_ambiguous  => 0,
		last_bc         => 0,
		locale          => 'en_AU',
		phrase          => '',
		prefix          => '',
		},
		'500BC.' =>
		{
		century         => 1900,
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 1500, locale => $locale),
		first_ambiguous => 1,
		first_bc        => 1,
		infix           => '',
		last            => 'inf',
		last_ambiguous  => 0,
		last_bc         => 0,
		locale          => 'en_AU',
		phrase          => '',
		prefix          => '',
		},
		'21 Jun 6004BC.' =>
		{
		century         => 1900,
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 7004, month => 6, day => 21, locale => $locale),
		first_ambiguous => 0,
		first_bc        => 1,
		infix           => '',
		last            => 'inf',
		last_ambiguous  => 0,
		last_bc         => 0,
		locale          => 'en_AU',
		phrase          => '',
		prefix          => '',
		},
		'@#DGREGORIAN@ 1 Jan 2000' =>
		{
		century         => 1900,
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 2000, month => 1, day => 1, locale => $locale),
		first_ambiguous => 0,
		first_bc        => 0,
		infix           => '',
		last            => 'inf',
		last_ambiguous  => 0,
		last_bc         => 0,
		locale          => 'en_AU',
		phrase          => '',
		prefix          => '',
		},
		'Abt 1999 (Unsure of date)' =>
		{
		century         => 1900,
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 1999, locale => $locale),
		first_ambiguous => 1,
		first_bc        => 0,
		infix           => '',
		last            => 'inf',
		last_ambiguous  => 0,
		last_bc         => 0,
		locale          => 'en_AU',
		phrase          => 'unsure of date',
		prefix          => 'about',
		},
		'Bef 3 Mar 2003' =>
		{
		century         => 1900,
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 2003, month => 3, day => 3, locale => $locale),
		first_ambiguous => 0,
		first_bc        => 0,
		infix           => '',
		last            => 'inf',
		last_ambiguous  => 0,
		last_bc         => 0,
		locale          => 'en_AU',
		phrase          => '',
		prefix          => 'before',
		},
		'Bet 4 Apr 2004 and 5 May 2005' =>
		{
		century         => 1900,
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 2004, month => 4, day => 4, locale => $locale),
		first_ambiguous => 0,
		first_bc        => 0,
		infix           => 'and',
		last            => DateTime -> new(year => 2005, month => 5, day => 5, locale => $locale),
		last_ambiguous  => 0,
		last_bc         => 0,
		locale          => 'en_AU',
		phrase          => '',
		prefix          => 'between',
		},
		'From 1 Jan 2001 to 2 Feb 2002' =>
		{
		century         => 1900,
		escape          => 'dgregorian',
		first           => DateTime -> new(year => 2001, month => 1, day => 1, locale => $locale),
		first_ambiguous => 0,
		first_bc        => 0,
		infix           => 'to',
		last            => DateTime -> new(year => 2002, month => 2, day => 2, locale => $locale),
		last_ambiguous  => 0,
		last_bc         => 0,
		locale          => 'en_AU',
		phrase          => '',
		prefix          => 'from',
		},
}
);

my($date);
my($in_string);
my($out_string);

for my $candidate (sort keys %{$candidate{$locale} })
{
		$date       = $parser -> parse(candidate => $candidate);
		$in_string  = join(', ', map{"$_ => '$candidate{$locale}{$candidate}{$_}'"} sort keys %{$candidate{$locale}{$candidate} });
		$out_string = join(', ', map{"$_ => '$$date{$_}'"} sort keys %$date);

		ok($in_string eq $out_string, "Testing: $candidate");

		if ($ENV{AUTHOR_TEST})
		{
				diag "In:  $in_string.";
				diag "Out: $out_string";
				diag "##########################################";
		}
}

done_testing;
