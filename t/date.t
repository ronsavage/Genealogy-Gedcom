use strict;
use warnings;

use Test::More;

BEGIN {use_ok('Genealogy::Gedcom::Reader::Lexer::Date');}

my($locale) = 'en';
my($parser) = Genealogy::Gedcom::Reader::Lexer::Date -> new(locale => $locale, logger => '');

isa_ok($parser, 'Genealogy::Gedcom::Reader::Lexer::Date');

# Candidate value => Result hashref.

my(%candidate) =
(
en =>
{
		'@#DGREGORIAN@ 1 Jan 2000' =>
		{
		escape          => lc 'DGREGORIAN',
		first           => '',
		first_ambiguous => 0,
		infix           => '',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => '',
		prefix          => '',
		},
		'(Unknown date)' =>
		{
		escape          => 'dgregorian',
		first           => '',
		first_ambiguous => 0,
		infix           => '',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => lc 'Unknown date',
		prefix          => '',
		},
		'Abt 1999 (Unsure of date)' =>
		{
		escape          => 'dgregorian',
		first           => '',
		first_ambiguous => 0,
		infix           => '',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => lc 'Unsure of date',
		prefix          => lc 'About',
		},
		'Bef 3 Mar 2003' =>
		{
		escape          => 'dgregorian',
		first           => '',
		first_ambiguous => 0,
		infix           => '',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => '',
		prefix          => lc 'Before',
		},
		'Bet 4 Apr 2004 and 5 May 2005' =>
		{
		escape          => 'dgregorian',
		first           => '',
		first_ambiguous => 0,
		infix           => 'and',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => '',
		prefix          => lc 'Between',
		},
		'From 1 Jan 2001 to 2 Feb 2002' =>
		{
		escape          => 'dgregorian',
		first           => '',
		first_ambiguous => 0,
		infix           => 'to',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => '',
		prefix          => lc 'From',
		},
}
);

my($date);
my($in_string);
my($out_string);

for my $candidate (sort keys %{$candidate{$locale} })
{
		diag "Testing: $candidate";

		$date       = $parser -> parse(candidate => $candidate);
		$in_string  = join(', ', map{"$_ => '$candidate{$locale}{$candidate}{$_}'"} sort keys %{$candidate{$locale}{$candidate} });
		$out_string = join(', ', map{"$_ => '$$date{$_}'"} sort keys %$date);

		ok($in_string eq $out_string, "Testing: $candidate");
		diag "In:  $in_string.";
		diag "Out: $out_string";
}

done_testing;
