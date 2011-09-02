package Genealogy::Gedcom::Reader::Lexer::Date;

use strict;
use warnings;

use Hash::FieldHash ':all';

use Text::Abbrev; # For abbrev.

fieldhash my %candidate => 'candidate';
fieldhash my %century   => 'century';
fieldhash my %locale    => 'locale';
fieldhash my %logger    => 'logger';

our $VERSION = '0.80';

# --------------------------------------------------

sub _init
{
	my($self, $arg)  = @_;
	$$arg{candidate} ||= '';     # Caller can set.
	$$arg{century}   ||= '1900'; # Caller can set.
	$$arg{locale}    ||= 'en';   # Caller can set.
	my($user_logger) = defined($$arg{logger}); # Caller can set (e.g. to '').
	$$arg{logger}    = $user_logger ? $$arg{logger} : Log::Handler -> new;
	$self            = from_hash($self, $arg);

	return $self;

} # End of _init.

# --------------------------------------------------

sub log
{
	my($self, $level, $s) = @_;

	$self -> logger -> $level($s) if ($self -> logger);

} # End of log.

# --------------------------------------------------

sub new
{
	my($class, %arg) = @_;
	my($self)        = bless {}, $class;
	$self            = $self -> _init(\%arg);

	return $self;

}	# End of new.

# --------------------------------------------------

sub parse
{
	my($self, %arg) = @_;
	my($candidate)  = lc ($arg{candidate} || $self -> candidate);
	my($locale)     = $arg{locale}        || $self -> locale;

	die 'No value supplied for candidate' if (! $candidate);

	# Phase 1: Handle interpreted case (/...(...)/).

	my(%date) =
		(
		 escape          => 'dgregorian',
		 first           => '',
		 first_ambiguous => 0,
		 infix           => '',
		 last            => '',
		 last_ambiguous  => 0,
		 locale          => $locale,
		 phrase          => '',
		 prefix          => '',
		);

	if ($candidate =~ /^(.*)\((.+)\)/)
	{
		$candidate    = $1 || '';
		$date{phrase} = $2;
	}

	return {%date} if (length($candidate) == 0);

	# Phase 2: Handle leading word or abbreviation.
	# Note: This hash deliberately includes words from ranges, as documentation.

	my(%abbrev) =
		(
		 en => {abbrev (qw/about abt and after before between calculated estimated from  interpreted to/)},
		 nl => {abbrev (qw/rond      en  na    voor   tussen  calculated estimated vanaf interpreted tot/)},
		);

	my(@field) = split(/\s+/, $candidate);

	if ($abbrev{$locale}{$field[0]})
	{
		$date{prefix} = $abbrev{$locale}{$field[0]};
		$date{prefix} = 'about' if ($date{prefix} eq 'abt'); # Sigh.

		shift @field;
	}

	# Phase 3: Handle date escape.

	if ($field[0] =~ /@#(.+)@/)
	{
		$date{escape} = $1;

		shift @field;
	}

	# Phase 4: Check for date range.

	my(%range_abbrev) =
		(
		 en => {abbrev (qw/and to/)},
		 nl => {abbrev (qw/en  tot/)},
		);

	my($field);
	my($offset);

	for my $i (0 .. $#field)
	{
		$field = $field[$i];

		if ($range_abbrev{$locale}{$field})
		{
			$date{infix} = $range_abbrev{$locale}{$field};
			$offset      = $i;
		}
	}

	# Did we find a range '... and ...' or '... to ...'?
 
	if (defined $offset)
	{
		# Expect 'd m y' and/to 'd m y', possibly with abbreviations.
	}
	else
	{
		# Expect 'd m y', possibly with abbreviations.
	}

	return {%date};

} # End of parse.

# --------------------------------------------------

1;

=pod

=head1 NAME

L<Genealogy::Gedcom::Reader::Lexer::Date> - An OS-independent lexer for GEDCOM dates

=head1 Synopsis

	my($locale) = 'en';
	my($parser) = Genealogy::Gedcom::Reader::Lexer::Date -> new
	(
	locale => $locale,
	logger => '',
	);

	my($candidate)    = 'Bet 4 Apr 2004 and 5 May 2005';
	my($date_hashref) = $parser -> parse($candidate);

=head1 Description

L<Genealogy::Gedcom::Reader::Lexer::Date> provides a lexer for GEDCOM dates.

See L<the GEDCOM Specification Ged551-5.pdf|http://wiki.webtrees.net/File:Ged551-5.pdf>.

=head1 Installation

Install L<Genealogy::Gedcom> as you would for any C<Perl> module:

Run:

	cpanm Genealogy::Gedcom

or run:

	sudo cpan Genealogy::Gedcom

or unpack the distro, and then either:

	perl Build.PL
	./Build
	./Build test
	sudo ./Build install

or:

	perl Makefile.PL
	make (or dmake or nmake)
	make test
	make install

=head1 Constructor and Initialization

C<new()> is called as C<< my($date) = Genealogy::Gedcom::Reader::Lexer::Date -> new(k1 => v1, k2 => v2, ...) >>.

It returns a new object of type C<Genealogy::Gedcom::Reader::Lexer::Date>.

Key-value pairs accepted in the parameter list (see corresponding methods for details [e.g. candidate()]):

=over 4

=item o candidate => $a_string

A string which the code tries to parse as a GEDCOM date of some sort.

Default: ''.

=item o century => $an_integer

An integer which specifies what to do with 2 digit dates.

This means '29 Feb 00', with the default century of 1900, is interpreted as 29-02-1900.

Default: 1900.

=item o locale => $a_locale

A string which specifies the desired locale.

Only 'en' is supported. However, some traces of 'nl' (Dutch) are present in the source code (but not in t/date.t).

Default: 'en'.

=item o logger => $logger_object

Specify a logger object.

To disable logging, just set logger to the empty string.

Default: An object of type L<Log::Handler>.

=back

=head1 Methods

=head2 candidate([$a_string])

The [] indicate an optional parameter.

Get or set the string being parsed.

=head2 default_century([$an_integer])

The [] indicate an optional parameter.

Get or set the value of the default century.

=head2 log($level, $s)

Calls $self -> logger -> $level($s).

=head2 locale([$locale])

Here, the [] indicate an optional parameter.

Get or set the locale.

Only 'en' is supported.

=head2 logger([$logger_object])

Here, the [] indicate an optional parameter.

Get or set the logger object.

To disable logging, just set logger to the empty string.

=head2 parse([%arg])

Here, the [] indicate an optional parameter.

Parse the candidate and return a hashref.

$arg{candidate} => $candiate takes precedence over new(candidate => $candidate).

The string which is a candidate date can be passed in to new as new(candidate => $a_string), or into parse as parse(candidate => $a_string).

This string is always converted to lower case before being processed. Hence all result data is lower case.

The string which is a locale can be passed in to new as new(locale => $a_string), or into parse as parse(locale => $a_string).

$arg{locale} => $locale takes precedence over new(locale => $locale).

Only 'en' is supported.

The return value is a hashref with these key => value pairs:

=over 4

=item o escape => $the_escape_string

Default: 'dgregorian' (yes, lower case).

=item o first => $first_date_in_range

Returns the first (or only) date.

This is for cases like '1999' in 'about 1999', and for '1999' in 'Between 1999 and 2000', and '2002' in 'From 2001 to 2002'.

Default: ''.

=item o first_ambiguous => $Boolean

Returns 1 if the first (or only) date is ambiguous.

Default: 0.

=item o infix => $a_string

This is for cases like 'and' in 'Between 1999 and 2000', and 'to' in 'From 2001 to 2002'.

Default: ''.

=item o last => $last_date_in_range

This is for cases like '2000' in 'Between 1999 and 2000', and '2002' in 'From 2001 to 2002'.

Default: ''.

=item o last_ambiguous => $Boolean

Returns 1 if the last date is ambiguous.

Default: 0.

=item o locale => $the_user_supplied_locale

Default: The locale supplied to new() or to parse().

=item o phrase => $the_phrase

This is for cases like '(Unsure about the date)' or the part within () in '1999 (Approx)'.

The () are discarded.

Default: ''.

=item o prefix => $the_prefix

This is for cases like 'about' in 'About 1999'.

Default: ''.

=back

=head1 FAQ

=head1 Machine-Readable Change Log

The file CHANGES was converted into Changelog.ini by L<Module::Metadata::Changes>.

=head1 Version Numbers

Version numbers < 1.00 represent development versions. From 1.00 up, they are production versions.

=head1 Support

Email the author, or log a bug on RT:

L<https://rt.cpan.org/Public/Dist/Display.html?Name=Genealogy::Gedcom>.

=head1 Thanx

Thanx to Eugene van der Pijll, the author of the Gedcom::Date::* modules.

=head1 Author

L<Genealogy::Gedcom::Reader::Lexer> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2011.

Home page: L<http://savage.net.au/index.html>.

=head1 Copyright

Australian copyright (c) 2011, Ron Savage.

	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License, a copy of which is available at:
	http://www.opensource.org/licenses/index.html

=cut
