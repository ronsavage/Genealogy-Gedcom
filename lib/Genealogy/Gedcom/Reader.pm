package Genealogy::Gedcom::Reader;

use strict;
use warnings;

use Genealogy::Gedcom::Reader::Lexer;

use Hash::FieldHash ':all';

use Log::Handler;

fieldhash my %input_file   => 'input_file';
fieldhash my %items        => 'items';
fieldhash my %lexer        => 'lexer';
fieldhash my %logger       => 'logger';
fieldhash my %maxlevel     => 'maxlevel';
fieldhash my %minlevel     => 'minlevel';
fieldhash my %report_items => 'report_items';
fieldhash my %strict       => 'strict';

our $VERSION = '0.83';

# --------------------------------------------------

sub _init
{
	my($self, $arg)     = @_;
	$$arg{input_file}   ||= ''; # Caller can set.
	$$arg{lexer}        = '';
	my($user_logger)    = defined($$arg{logger}); # Caller can set (e.g. to '').
	$$arg{logger}       = $user_logger ? $$arg{logger} : Log::Handler -> new;
	$$arg{maxlevel}     ||= 'warning';# Caller can set.
	$$arg{minlevel}     ||= 'error'; # Caller can set.
	$$arg{report_items} ||= 0;  # Caller can set.
	$$arg{strict}       ||= 0;  # Caller can set.
	$self               = from_hash($self, $arg);

	if (! $user_logger)
	{
		$self -> logger -> add
			(
			 screen =>
			 {
				 maxlevel       => $self -> maxlevel,
				 message_layout => '%m',
				 minlevel       => $self -> minlevel,
			 }
			);
	}

	return $self;

} # End of _init.

# --------------------------------------------------

sub log
{
	my($self, $level, $s) = @_;

	$self -> logger -> $level($s);

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

sub run
{
	my($self)  = @_;
	my($lexer) = Genealogy::Gedcom::Reader::Lexer -> new
		(
		 input_file   => $self -> input_file,
		 logger       => $self -> logger,
		 maxlevel     => $self -> maxlevel,
		 minlevel     => $self -> minlevel,
		 report_items => $self -> report_items,
		 strict       => $self -> strict,
		);
	my($result) = $lexer -> run;

	$self -> items($lexer -> items);

	# Return 0 for success and 1 for failure.

	return $result;

} # End of run.

# --------------------------------------------------

1;

=pod

=head1 NAME

L<Genealogy::Gedcom::Reader> - An OS-independent reader for GEDCOM data

=head1 Synopsis

See L<Genealogy::Gedcom::Reader::Lexer>.

=head1 Description

L<Genealogy::Gedcom::Reader> provides a reader for GEDCOM data.

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

Run scripts/read.pl -help.

read.pl is currenly a copy of lex.pl. The latter is recommended.

=item o Genealogy::Gedcom::Reader::Lexer

This does the real work for finding tokens within GEDCOM files.

Run scripts/lex.pl -help.

See L<Genealogy::Gedcom::Reader::Lexer> for details.

=back

=head2 Why did you choose L<Hash::FieldHash> over L<Moose>?

My policy is to use the light-weight L<Hash::FieldHash> for stand-alone modules and L<Moose> for applications.

=head1 Machine-Readable Change Log

The file CHANGES was converted into Changelog.ini by L<Module::Metadata::Changes>.

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
