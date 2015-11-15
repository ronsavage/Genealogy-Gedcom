package Genealogy::Gedcom;

use strict;
use warnings;

our $VERSION = '0.86';

# --------------------------------------------------

1;

=pod

=head1 NAME

Genealogy::Gedcom - An OS-independent processor for GEDCOM data

=head1 Synopsis

See L<Genealogy::Gedcom::Reader::Lexer>.

=head1 Description

L<Genealogy::Gedcom> provides a processor for GEDCOM data.

See L<The GEDCOM Specification Ged551-5.pdf|http://wiki.webtrees.net/File:Ged551-5.pdf>.

=head1 Distributions

This module is available as a Unix-style distro (*.tgz).

See L<http://savage.net.au/Perl-modules/html/installing-a-module.html>
for help on unpacking and installing distros.

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

See L<Genealogy::Gedcom::Reader::Lexer>.

=head1 FAQ

=head2 o What is the purpose of this set of modules?

It's the basis of a long-term project to write a new interface to GEDCOM files.

=head2 How are the modules related?

=over 4

=item o Genealogy::Gedcom

This is a dummy module at the moment, which just occupies the namespace.

=item o Genealogy::Gedcom::Reader

This employs the lexer to do the work. It may one day use a (non-existent) parser too.

=item o Genealogy::Gedcom::Reader::Lexer

This does the real work for finding tokens within GEDCOM files.

Run scripts/lex.pl -help.

See L<Genealogy::Gedcom::Reader::Lexer> for details.

=back

=head1 Repository

L<https://github.com/ronsavage/Genealogy-Gedcom>

=head1 See Also

L<Genealogy::Gedcom::Date>.

<Gedcom::Date>.

=head1 Machine-Readable Change Log

The file Changes was converted into Changelog.ini by L<Module::Metadata::Changes>.

=head1 Version Numbers

Version numbers < 1.00 represent development versions. From 1.00 up, they are production versions.

=head1 Thanks

Many thanks are due to the people who worked on L<Gedcom>.

=head1 Support

Email the author, or log a bug on RT:

L<https://rt.cpan.org/Public/Dist/Display.html?Name=Genealogy::Gedcom>.

=head1 Author

L<Genealogy::Gedcom> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2011.

Home page: L<http://savage.net.au/index.html>.

=head1 Copyright

Australian copyright (c) 2011, Ron Savage.

	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License, a copy of which is available at:
	http://www.opensource.org/licenses/index.html

=cut
