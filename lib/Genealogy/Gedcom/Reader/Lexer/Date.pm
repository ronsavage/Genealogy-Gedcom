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
	$$arg{candidate} = $$arg{candidate} || '';   # Caller can set.
	$$arg{locale}    = $$arg{locale}    || 'en'; # Caller can set.
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
		 date   => '',
		 escape => 'dgregorian',
		 first  => '',
		 infix  => '',
		 last   => '',
		 locale => $locale,
		 phrase => '',
		 prefix => '',
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

	my($range) = 0;

	my($offset);

	for my $i (0 .. $#field)
	{
		$field = $field[$i];

		if ($range_abbrev{$locale}{$field})
		{
			$data{$locale}{infix} = $range_abbrev{$locale}{$field};
			$offset               = $i;
		}
	}

	# Did we find a range '... and ...' or '... to ...'?
 
	if (defined $offset)
	{
		# Expect d-m-y and/to d-m-y.
	}
	else
	{
		# Expect d-m-y at most.
	}

	$date{date} = join(' ', @field);

	return {%date};

} # End of parse.

# --------------------------------------------------

1;

=pod

=head1 NAME

L<Genealogy::Gedcom::Reader::Lexer::Date> - An OS-independent lexer for GEDCOM dates

=head1 Synopsis

See L<Genealogy::Gedcom::Reader::Lexer>.

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

Only 'en' is supported. However, faint traces of 'nl' (Dutch) are present in the source code (but not in t/date.t).

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

Here, the [] indicate an optional parameter.

The string which is a candidate date can be passed in to new as new(candidate => $a_string), or into parse as parse(candidate => $a_string).

This string is always converted to lower case before being processed. Hence all result data is lower case.

The return value is a hashref with these key => value pairs:

=over 4

=item o date => $the_date

=item o escape => $the_escape_string

Default: 'dgregorian' (yes, lower case).

=item o first => $first_date_in_range

This is for cases like '1999' in 'Between 1999 and 2000', and '2002' in 'From 2001 to 2002'.

Default: ''.

=item o infix => $a_string

This is for cases like 'and' in 'Between 1999 and 2000', and 'to' in 'From 2001 to 2002'.

Default: ''.

=item o last => $last_date_in_range

This is for cases like '2000' in 'Between 1999 and 2000', and '2002' in 'From 2001 to 2002'.

Default: ''.

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

=head2 parse([%arg])

=head1 FAQ

=head1 Machine-Readable Change Log

The file CHANGES was converted into Changelog.ini by L<Module::Metadata::Changes>.

=head1 Version Numbers

Version numbers < 1.00 represent development versions. From 1.00 up, they are production versions.

=head1 References

=over 4

=item o The original Perl L<Gedcom>

=item o GEDCOM

=over 4

=item o L<GEDCOM Specification|http://wiki.webtrees.net/File:Ged551-5.pdf>

=item o L<GEDCOM Validation|http://www.tamurajones.net/GEDCOMValidation.xhtml>

=item o L<GEDCOM Tags|http://www.tamurajones.net/GEDCOMTags.xhtml>

=back

=item o Usage of non-standard tags

=over 4

=item o L<http://www.tamurajones.net/FTWTEXT.xhtml>

This is apparently the worst offender she's seen. Search that page for 'tags'.

=item o L<http://www.tamurajones.net/GenoPro2011.xhtml>

=item o L<http://www.tamurajones.net/GenoPro2007.xhtml>

=item o L<http://www.tamurajones.net/TheFTWTEXTProblem.xhtml>

=back

=item o Other articles on Tamura's site

=over 4

=item o L<http://www.tamurajones.net/FiveFreakyFeaturesYourGenealogySoftwareShouldNotHave.xhtml>

=item o L<http://www.tamurajones.net/TwelveOrdinaryMustHaveGenealogySoftwareFeatures.xhtml>

=back

=item o Other projects

Many of these are discussed on Tamura's site.

=over 4

=item o L<http://bettergedcom.wikispaces.com/>

=item o L<http://www.ngsgenealogy.org/cs/GenTech_Projects>

=item o L<http://gdmxml.fugal.net/>

=item o L<http://www.cosoft.org/genxml/>

=item o L<http://www.sunflower.com/~billk/GEDC/>

=item o L<http://ancestorsnow.blogspot.com/2011/07/vged.html>

=item o L<http://www.tamurajones.net/GEDCOMValidation.xhtml>

=item o L<http://webtrees.net/>

=item o L<http://swoodbridge.com/Genealogy/lifelines/>

=item o L<http://deadendssoftware.blogspot.com/>

=item o L<http://www.legacyfamilytree.com/>

=item o L<https://devnet.familysearch.org/docs/api-overview>

=back

=back

=head1 The Gedcom Mailing List

Contact perl-gedcom-help@perl.org.

=head1 Support

Email the author, or log a bug on RT:

L<https://rt.cpan.org/Public/Dist/Display.html?Name=Genealogy::Gedcom>.

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
