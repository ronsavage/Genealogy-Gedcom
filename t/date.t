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
		bc              => 0,
		error           => 0,
		escape          => 'dgregorian',
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
		bc              => 0,
		error           => 0,
		escape          => 'dgregorian',
		first           => '',
		first_ambiguous => 0,
		infix           => '',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => 'unknown date',
		prefix          => '',
		},
		'Abt 1999 (Unsure of date)' =>
		{
		bc              => 0,
		error           => 0,
		escape          => 'dgregorian',
		first           => '1999-01-01',
		first_ambiguous => 1,
		infix           => '',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => 'unsure of date',
		prefix          => 'about',
		},
		'Bef 3 Mar 2003' =>
		{
		bc              => 0,
		error           => 0,
		escape          => 'dgregorian',
		first           => '',
		first_ambiguous => 0,
		infix           => '',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => '',
		prefix          => 'before',
		},
		'Bet 4 Apr 2004 and 5 May 2005' =>
		{
		bc              => 0,
		error           => 0,
		escape          => 'dgregorian',
		first           => '',
		first_ambiguous => 0,
		infix           => 'and',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => '',
		prefix          => 'between',
		},
		'From 1 Jan 2001 to 2 Feb 2002' =>
		{
		bc              => 0,
		error           => 0,
		escape          => 'dgregorian',
		first           => '',
		first_ambiguous => 0,
		infix           => 'to',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => '',
		prefix          => 'from',
		},
		'500B.C.' =>
		{
		bc              => 1,
		error           => 0,
		escape          => 'dgregorian',
		first           => '500-01-01',
		first_ambiguous => 0,
		infix           => '',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => '',
		prefix          => '',
		},
		'500BC.' =>
		{
		bc              => 1,
		error           => 0,
		escape          => 'dgregorian',
		first           => '500-01-01',
		first_ambiguous => 0,
		infix           => '',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => '',
		prefix          => '',
		},
		'500BC' =>
		{
		bc              => 1,
		error           => 0,
		escape          => 'dgregorian',
		first           => '500-01-01',
		first_ambiguous => 0,
		infix           => '',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => '',
		prefix          => '',
		},
		'500 BC' =>
		{
		bc              => 1,
		error           => 0,
		escape          => 'dgregorian',
		first           => '500-01-01',
		first_ambiguous => 0,
		infix           => '',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => '',
		prefix          => '',
		},
		'2011' =>
		{
		bc              => 0,
		error           => 0,
		escape          => 'dgregorian',
		first           => '2011-01-01',
		first_ambiguous => 1,
		infix           => '',
		last            => '',
		last_ambiguous  => 0,
		locale          => 'en',
		phrase          => '',
		prefix          => '',
		},
}
);

my($date);
my($in_string);
my($out_string);

for my $candidate (sort keys %{$candidate{$locale} })
{
		diag "Testing $candidate";

		$date       = $parser -> parse(candidate => $candidate);
		$in_string  = join(', ', map{"$_ => '$candidate{$locale}{$candidate}{$_}'"} sort keys %{$candidate{$locale}{$candidate} });
		$out_string = join(', ', map{"$_ => '$$date{$_}'"} sort keys %$date);

		ok($in_string eq $out_string, "Testing: $candidate");
		diag "In:  $in_string.";
		diag "Out: $out_string";
}

done_testing;
