package Genealogy::Gedcom::Reader::Lexer::Date;

use strict;
use warnings;

use Hash::FieldHash ':all';

use Text::Abbrev; # For abbrev.

fieldhash my %candidate => 'candidate';
fieldhash my %counter   => 'counter';
fieldhash my %logger    => 'logger';

our $VERSION = '0.80';

# --------------------------------------------------

sub _init
{
	my($self, $arg)  = @_;
	$$arg{candidate} = $$arg{candidate} || die 'Error: No value supplied for candidate';
	$$arg{counter}   = 0;
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

	die 'No value supplied for candidate' if (! $candidate);

	my(%abbrev) = abbrev (qw/about after before between calculated estimated from interpreted to/);
	my(@field)  = split(/\s+/, $candidate);
	$field[0]   = $abbrev{$field[0]} ? $abbrev{$field[0]} : $field[0];

	return $candidate;

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

=item o default_century => $an_integer

An integer which specifies what to do with 2 digit dates.

This means '29 Feb 00', with the default century of 1900, is interpreted as 29-02-1900.

Default: 1900.

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

=head2 logger([$logger_object])

Here, the [] indicate an optional parameter.

Get or set the logger object.

To disable logging, just set logger to the empty string.

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
