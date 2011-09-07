package Genealogy::Gedcom::Reader::Lexer::Date;

use strict;
use warnings;

use DateTime;
use DateTime::Format::Natural;
use DateTime::Infinite;

use Hash::FieldHash ':all';

use Text::Abbrev; # For abbrev.

fieldhash my %debug   => 'debug';
fieldhash my %from_to => 'from_to';
fieldhash my %period  => 'period';

our $VERSION = '0.80';

# --------------------------------------------------

sub _init
{
	my($self, $arg)  = @_;
	$$arg{debug}     ||= 0;             # Caller can set.
	$$arg{from_to}   ||= [qw/from to/]; # Caller can set.
	$$arg{period}    ||= '';            # Caller can set.
	$self            = from_hash($self, $arg);

	return $self;

} # End of _init.

# --------------------------------------------------

sub log
{
	my($self, $s) = @_;

	print STDERR "#\t$s. \n" if ($self -> debug);

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

sub parse_duration
{
	my($self, %arg) = @_;
	my($period)     = lc ($arg{period} || $self -> period);
	$period         =~ s/^\s+//;
	$period         =~ s/\s+$//;
	my($from_to)    = $arg{from_to} || $self -> from_to;

	# Phase 1: Validate parameters.

	die "No value of the 'period' key"                                     if (length($period) == 0);
	die "The value of the 'from_to' key must be an arrayref of 2 elements" if ( (! ref $from_to) || (ref $from_to ne 'ARRAY') || ($#$from_to != 1) );

	$from_to = [map{lc} @$from_to];

	# Phase 2: Split the date on '-' or spaces, so we can check for 'from' and 'to'.
	# Expected format is something like 'from 21 jun 1950 to 21 jun 2011'.

	my(@field)  = split(/[-\s]+/, $period);
	my($prefix) = '';

	if ($field[0] eq $$from_to[0])
	{
		$prefix = 'one';
	}
	elsif ($field[0] eq $$from_to[1])
	{
		$prefix = 'two';
	}

	if (! $prefix)
	{
		die "The value of the 'period' key must start with '$$from_to[0]' or '$$from_to[1]'";
	}

	# Phase 3: Handle the date escape.
	# We ignore the value because the user always (implicitly or explicitly) sets a locale.

	my($offset_of_escape) = - 1;

	for my $i (0 .. $#field)
	{
		if ($field[$i] =~ /@#(.+)@/)
		{
			$offset_of_escape = $i;
		}
	}

	splice(@field, $offset_of_escape, 1) if ($offset_of_escape >= 0);

	my(%flags);

	for my $key (qw/one two/)
	{
		$flags{$key}               = $key eq 'one' ? DateTime::Infinite::Past -> new : DateTime::Infinite::Future -> new;
		$flags{"${key}_ambiguous"} = 0;
		$flags{"${key}_bc"}        = 0;
		$flags{"${key}_date"}      = $flags{$key};
	}

	$self -> parse_1or2_dates(\%flags, $from_to, @field);

	return {%flags};

} # End of parse_duration.

# --------------------------------------------------

sub parse_1or2_dates
{
	my($self, $flags, $from_to, @field) = @_;

	# Phase 1: Check for embedded 'to', as in 'from date.1 to date.2'.

	my(%offset) =
		(
		 one => - 1,
		 two => - 1,
		);

	for my $i (0 .. $#field)
	{
		if ($field[$i] eq $$from_to[0])
		{	
			$offset{one} = $i;
		}
		if ($field[$i] eq $$from_to[1])
		{	
			$offset{two} = $i;
		}
	}

	# Phase 2: Search for BC, of which there might be 2.

	my(@offset_of_bc);

	for my $i (0 .. $#field)
	{
		# Note: The field might contain just BC or something like 500BC.

		if ($field[$i] =~ /^(\d*)b\.?c\.?$/)
		{
			# Remove BC. Allow for year 0 with defined().

			if (defined($1) && $1)
			{
				$field[$i] = $1;
			}
			else
			{
				# Save offsets so we can remove BC later.

				push @offset_of_bc, $i;
			}

			# Flag which date is BC. They may both be.

			if ( ($offset{two} < 0) || ($i < $offset{two}) )
			{
				$$flags{one_bc} = 1;
			}
			else
			{
				$$flags{two_bc} = 1;
			}
		}
	}

	# Clean up if there is there a BC or 2.

	if ($#offset_of_bc >= 0)
	{
		# Discard 1st BC.

		splice(@field, $offset_of_bc[0], 1);

		# Is there another BC?

		if ($#offset_of_bc > 0)
		{
			# We use - 1 because of the above splice.

			splice(@field, $offset_of_bc[1] - 1, 1);
		}
	}

	# Phase 3: We have 1 or 2 dates without BCs.
	# We process them separately, so we can determine if they are ambiguous.

	if ($offset{one} >= 0)
	{
		my($end) = $offset{two} >= 0 ? $offset{two} - 1 : $#field;

		$self -> parse_1_date('one',  $flags, @field[($offset{one} + 1) .. $end]);
	}

	if ($offset{two} >= 0)
	{
		my($start) = $offset{two} >= 0 ? $offset{two} + 1 : 0;

		$self -> parse_1_date('two', $flags, @field[$start .. $#field]);
	}

} # End of parse_1or2_dates.

# --------------------------------------------------

sub parse_1_date
{
	my($self, $which, $flags, @field) = @_;

	# Phase 1: Flag an isolated year or a year with a month.

	$$flags{"${which}_ambiguous"} = $#field < 2 ? 1 : 0;

	# Phase 2: Handle missing data and 2-digit years.

	if ($#field == 0)
	{
		# This assumes the year is the last and only input field.

		$field[2] = $field[0];
		$field[1] = 1; # Month.
		$field[0] = 1; # Day.
	}
	elsif ($#field == 1)
	{
		# This assumes the year is the last input field, and the month is first.

		$field[2] = $field[1];
		$field[1] = $field[0]; # Month.
		$field[0] = 1;         # Day.
	}

	# Phase 3: Hand over analysis to our slave.

	my($four_digit_year) = 1;

	if ($field[2] < 1000)
	{
		# DateTime only accepts 4-digit years :-(.

		$field[2]        += 1000;
		$four_digit_year = 0;
	}

	$$flags{"${which}_date"} = DateTime::Format::Natural -> new -> parse_datetime(join('-', @field) );
	$$flags{$which}          = qq|$$flags{"${which}_date"}|;

	# Phase 4: Replace leading 1 with 0 if we rigged a 4-digit year.

	substr($$flags{$which}, 0, 1) = '0' if (! $four_digit_year);

} # End of parse_1_date.

# --------------------------------------------------

1;

=pod

=head1 NAME

L<Genealogy::Gedcom::Reader::Lexer::Date> - An OS-independent lexer for GEDCOM dates

=head1 Synopsis

	my($parser) = Genealogy::Gedcom::Reader::Lexer::Date -> new;

	or, in debug mode, which might print progress reports:

	my($parser) = Genealogy::Gedcom::Reader::Lexer::Date -> new(debug => 1);

	# These samples are some cases from t/date.t.

	for my $period (
	'From 0 to 99',
	'From 1 Jan 2001 to 2 Feb 2002',
	'From 21 Jun 6004BC.',
	'From 500BC to 400',
	'To 2011',
	'To 500 BC'
	)
	{
		my($hashref) = $parser -> parse_duration(period => $period);
	}

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

Key-value pairs accepted in the parameter list (see corresponding methods for details [e.g. debug()]):

=over 4

=item o debug => $Boolean

Turn debugging prints off or on.

Default: 0.

This parameter is optional.

=item o from_to => $arrayref

Specify the case-insensitive words, in your language, which indicate a date duration.

Default: ['From', 'To'] I<in that order>.

This parameter is optional. If supplied, it must be a 2-element arrayref. It can be supplied to new() or to L<parse_duration([%arg])>.

=item o period => $a_string

The string to be parsed. It may contain just 1 date, prefixed with (in English) 'From' or 'To'.

Default: ''.

This parameter is optional. It can be supplied to new() or to L<parse_duration([%arg])>.

=back

=head1 Methods

=head2 debug([$Boolean])

The [] indicate an optional parameter.

Get or set the debug flag.

=head2 from_to([$arrayref])

The [] indicate an optional parameter.

Get or set the arrayref of words, in your language, for 'From' and 'To' I<in that order>.

=head2 log($s)

Print the string "#\t$s. \n" to STDERR.

The '#' co-operates with L<Test::More>.

=head2 parse_duration([%arg])

Here, the [] indicate an optional parameter.

Parse the period and return a hashref.

Key => value pairs for %arg:

=over 4

=item o from_to => $arrayref

Specify the case-insensitive words, in your language, which indicate a date duration.

This parameter is optional. If supplied, it must be a 2-element arrayref.

$arg{from_to}: The 'From' and 'To' strings can be passed in to new as new(from_to => $arrayref), or into this method as parse_duration(from_to => $arrayref).

parse_duration(from_to => $arrayref) takes precedence over new(from_to => $arrayref).

=item o period => $a_string

Specify the string to parse.

This parameter is optional.

$arg{period}: The candidate duration can be passed in to new as new(period => $a_string), or into this method as parse_duration(period => $a_string).

parse_duration(period => $period) takes precedence over new(period => $period).

This string is always converted to lower case before being processed.

=back

The return value is a hashref with these key => value pairs:

=over 4

=item o one => $first_date_in_range

Returns the first (or only) date as a string, after 'From'.

This is for cases like '1999' in 'from 1999', and for '1999' in 'from 1999 to 2000'.

A missing month defaults to 01. A missing day defaults to 01.

'500BC' will be returned as '0500-01-01', with the 'one_bc' flag set. See also the key 'one_date'.

Default: DateTime::Infinite::Past -> new, which stringifies to '-inf'.

=item o one_ambiguous => $Boolean

Returns 1 if the first (or only) date is ambiguous. Possibilities:

=over 4

=item o Only the year is present

=item o Only the year and month are present

=item o The day and month are reversible

This is checked for by testing whether or not the day is <= 12, since in that case it could be a month.

=back

Default: 0.

=item o one_bc => $Boolean

Returns 1 if the first date is followed by one of (case-insensitive): 'B.C.', 'BC.' or 'BC'.

In the input, this suffix can be separated from the year by spaces, so both '500BC' and '500 B.C.' are accepted.

Default: 0.

=item o one_date => $a_date_object

This object is of type L<DateTime::Format::Natural>, which will actually be an object of type L<DateTime>.

Warning: Since these objects only accept 4-digit years, any year 0 .. 999 will have 1000 added to it.
Of course, the value for the 'one' key will I<not> have 1000 added it.

This means that if the value of the 'one' key does not match the stringified value of the 'one_date' key
(assuming the latter is not '-inf'), then the year is < 1000.

Alternately, if the stringified value of the 'one_date' key is '-inf', the period supplied did not have a 'From' date.

Default: DateTime::Infinite::Past -> new, which stringifies to '-inf'.

=item o two => $second_date_in_range

Returns the second (or only) date as a string, after 'To'.

This is for cases like '1999' in 'to 1999', and for '2000' in 'from 1999 to 2000'.

A missing month defaults to 01. A missing day defaults to 01.

'500BC' will be returned as '0500-01-01', with the 'two_bc' flag set. See also the key 'two_date'.

Default: DateTime::Infinite::Future -> new, which stringifies to 'inf'.

=item o two_ambiguous => $Boolean

Returns 1 if the second (or only) date is ambiguous. Possibilities:

=over 4

=item o Only the year is present

=item o Only the year and month are present

=item o The day and month are reversible

This is checked for by testing whether or not the day is <= 12, since in that case it could be a month.

=back

Default: 0.

=item o two_bc => $Boolean

Returns 1 if the second date is followed by one of (case-insensitive): 'B.C.', 'BC.' or 'BC'.

In the input, this suffix can be separated from the year by spaces, so both '500BC' and '500 B.C.' are accepted.

Default: 0.

=item o two_date => $a_date_object

This object is of type L<DateTime::Format::Natural>, which will actually be an object of type L<DateTime>.

Warning: Since these objects only accept 4-digit years, any year 0 .. 999 will have 1000 added to it.
Of course, the value for the 'two' key will I<not> have 1000 added it.

This means that if the value of the 'two' key does not match the stringified value of the 'two_date' key
(assuming the latter is not 'inf'), then the year is < 1000.

Alternately, if the stringified value of the 'two_date' key is 'inf', the period supplied did not have a 'To' date.

Default: DateTime::Infinite::Future -> new, which stringifies to 'inf'.

=back

=head1 FAQ

=head2 Why are dates returned as objects of type DateTime?

Because such objects have the sophistication required to handle such a complex topic.

See L<DateTime> and L<http://datetime.perl.org/wiki/datetime/dashboard> for details.

=head2 What happens if parse_duration() is given a string like 'From 2000 to 1999'

Then the returned hashref will have:

=over 4

=item o one => '2000-01-01T00:00:00'

=item o two => '1999-01-01T00:00:00'

=back

Clearly then, the code I<does not> reorder the dates.

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
