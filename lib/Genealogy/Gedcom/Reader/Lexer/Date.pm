package Genealogy::Gedcom::Reader::Lexer::Date;

use strict;
use warnings;

use DateTime;
use DateTime::Format::Natural;
use DateTime::Infinite;

use Hash::FieldHash ':all';

use Text::Abbrev; # For abbrev.

fieldhash my %century   => 'century';
fieldhash my %from_to   => 'from_to';
fieldhash my %locale    => 'locale';
fieldhash my %period    => 'period';

our $VERSION = '0.80';

# --------------------------------------------------

sub _init
{
	my($self, $arg)  = @_;
	$$arg{century}   ||= '1900';        # Caller can set.
	$$arg{from_to}   ||= [qw/from to/]; # Caller can set.
	$$arg{locale}    ||= 'en_AU';       # Caller can set.
	$$arg{period}    ||= '';            # Caller can set.
	$self            = from_hash($self, $arg);

	return $self;

} # End of _init.

# --------------------------------------------------

sub new
{
	my($class, %arg) = @_;
	my($self)        = bless {}, $class;
	$self            = $self -> _init(\%arg);

	return $self;

}	# End of new.

# --------------------------------------------------

sub _parse_date
{
	my($self, $date, @field) = @_;

	# Phase 1: Change 'and' to 'to' to keep DateTime::Format::Natural happy.

	my($offset_of_to) = - 1;

	for my $i (0 .. $#field)
	{
		if ($field[$i] eq 'and')
		{
			$$date{infix} = 'and';
			$field[$i]    = 'to';
			$offset_of_to = $i;
		}
		elsif ($field[$i] eq 'to')
		{	
			$$date{infix} = 'to';
			$offset_of_to = $i;
		}
	}

	# Phase 2: Search for 'BC', of which there might be 2.

	my(@offset_of_bc);

	for my $i (0 .. $#field)
	{
		# Note: The field might contain just 'BC' or something like '500BC'.

		if ($field[$i] =~ /^(\d*)b\.?c\.?$/)
		{
			# Remove 'BC'. Allow for year 0 with defined().

			if (defined($1) && $1)
			{
				$field[$i] = $1 + 1000;
			}
			else
			{
				# Save offsets so we can remove 'BC' later.

				push @offset_of_bc, $i;

				# Add 1000 if BC year < 1000, to keep DateTime happy.
				# This assumes the 'BC' immediately follows the year.

				if ($i > 0)
				{
					$field[$i - 1] += $field[$i - 1] < 1000 ? 1000 : 0;
				}
			}

			# Flag which date is BC.

			if ( ($offset_of_to < 0) || ($i < $offset_of_to) )
			{
				$$date{first_bc} = 1;
			}
			else
			{
				$$date{last_bc} = 1;
			}
		}
	}

	# Clean up if there is there a 'BC' or 2.

	if ($#offset_of_bc >= 0)
	{
		splice(@field, $offset_of_bc[0], 1);

		# Is there another 'BC'?

		if ($#offset_of_bc > 0)
		{
			# We use - 1 because of the above splice.

			splice(@field, $offset_of_bc[1] - 1, 1);
		}
	}

	# Phase 3: We have 1 or 2 dates without BCs.
	# We process them separately, so we can determine if they are ambiguous.

	if ($offset_of_to >= 0)
	{
		# We have a 'to', which may be the only date present.

		$self -> parse_date_field('first', $date, @field[0 .. ($offset_of_to - 1)]);
		$self -> parse_date_field('last',  $date, @field[($offset_of_to + 1) .. $#field]);
	}
	else
	{
		$self -> _parse_date_field('first', $date, @field);
	}

} # End of _parse_date.

# --------------------------------------------------

sub _parse_date_field
{
	my($self, $which, $date, @field) = @_;

	# Phase 1: Handle an isolated year or a year with a month.

	if ($#field < 2)
	{
		$$date{"${which}_ambiguous"} = 1;
	}

	# Phase 2: Handle missing data and 2-digit years.

	if ($#field == 0)
	{
		# This assumes the year is the last and only input field.

		$field[2] = $field[0] + ( ($field[0] < 100) ? $self -> century : 0);
		$field[1] = 1; # Month.
		$field[0] = 1; # Day.
	}
	elsif ($#field == 1)
	{
		# This assumes the year is the last input field, and the month is first.

		$field[2] = $field[1] + ( ($field[1] < 100) ? $self -> century : 0);
		$field[1] = $field[0]; # Month.
		$field[0] = 1;         # Day.
	}

	$$date{$which} = DateTime::Format::Natural -> new -> parse_datetime(join('-', @field) );

} # End of _parse_date_field.

# --------------------------------------------------

sub parse_datetime
{
	my($self, %arg) = @_;
	my($period)     = lc ($arg{period} || $self -> period);
	$period         =~ s/^\s+//; # Just in case...
	$period         =~ s/\s+$//;

	die "No value supplied for the 'period' key" if (length($period) == 0);

	$self -> century($arg{century}) if ($arg{century});
	$self -> locale($arg{locale})   if ($arg{locale});

	# Phase 1: Handle interpreted case, i.e. /...(...)/.

	my(%date) =
		(
		 century         => $self -> century,
		 escape          => 'dgregorian',
		 first           => DateTime::Infinite::Past -> new,
		 first_ambiguous => 0,
		 first_bc        => 0,
		 infix           => '',
		 last            => DateTime::Infinite::Future -> new,
		 last_ambiguous  => 0,
		 last_bc         => 0,
		 locale          => $self -> locale,
		 phrase          => '',
		 prefix          => '',
		);

	if ($period =~ /^(.*)\((.*)\)/)
	{
		$period       = $1 || '';
		$date{phrase} = $2 || ''; # Allow for '... ()'.
	}

	return {%date} if (length($period) == 0);

	# Phase 2: Handle leading word or abbreviation.
	# Note: This hash deliberately includes words from ranges, as documentation,
	# even though ranges are checked separately below.

	my(%abbrev) =
		(
		 en_AU => {abbrev (qw/about abt and after before between calculated estimated from  interpreted to/)},
		 nl_NL => {abbrev (qw/rond      en  na    voor   tussen  calculated estimated vanaf interpreted tot/)},
		);

	# Split the date on '-' or spaces.

	my(@field) = split(/[-\s]+/, $period);

	if ($abbrev{$self -> locale}{$field[0]})
	{
		$date{prefix} = $abbrev{$self -> locale}{$field[0]};
		$date{prefix} = 'about' if ($date{prefix} eq 'abt'); # Sigh.

		shift @field;
	}

	# Phase 3: Handle the date escape.

	if ($field[0] =~ /@#(.+)@/)
	{
		$date{escape} = $1;

		shift @field;
	}

	# Phase 4: Handle the date(s).

	$self -> _parse_date(\%date, @field);

	return {%date};

} # End of parse_datetime.

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
		$prefix = 'from';
	}
	elsif ($field[0] eq $$from_to[1])
	{
		$prefix = 'to';
	}

	if ($prefix)
	{
		shift @field;
	}
	else
	{
		die "The value of the 'period' key must start with '$$from_to[0]' or '$$from_to[1]'";
	}

	# Phase 3: Handle the date escape.
	# We ignore the value because the user always implicitly or explicitly sets a locale.

	if ($field[0] =~ /@#(.+)@/)
	{
		shift @field;
	}

	my(%flags) =
		(
		 first_bc  => 0,
		 second_bc => 0,
		);

	$self -> parse_1or2_dates(\%flags, $from_to, @field);

	return {%flags};

} # End of parse_duration.

# --------------------------------------------------

sub parse_1or2_dates
{
	my($self, $flags, $from_to, @field) = @_;

	# Phase 1: Check for embedded 'to'.

	my($offset_of_to) = - 1;

	for my $i (0 .. $#field)
	{
		if ($field[$i] eq $$from_to[1])
		{	
			$offset_of_to = $i;
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
				$field[$i] = $1 + 1000;
			}
			else
			{
				# Save offsets so we can remove BC later.

				push @offset_of_bc, $i;

				# Add 1000 if BC year < 1000, to keep DateTime happy.
				# This assumes the BC immediately follows the year,
				# and hence [$i - 1] is the index of the year.

				if ($i > 0)
				{
					$field[$i - 1] += $field[$i - 1] < 1000 ? 1000 : 0;
				}
			}

			# Flag which date is BC. They may both be.

			if ( ($offset_of_to < 0) || ($i < $offset_of_to) )
			{
				$$flags{first_bc} = 1;
			}
			else
			{
				$$flags{second_bc} = 1;
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

	if ($offset_of_to >= 0)
	{
		# We have a 'to', which may be the only date present.

		$self -> parse_1_date('first',  $flags, @field[0 .. ($offset_of_to - 1)]) if ($offset_of_to > 0);
		$self -> parse_1_date('second', $flags, @field[($offset_of_to + 1) .. $#field]);
	}
	else
	{
		# We have 1 date, and it's not a 'to'.

		$self -> parse_1_date('first', $flags, @field);
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

		$$flags{"${which}_offset"} = $field[0] < 100 ? 1 : 0;
		$field[2]                  = $field[0] + ( ($field[0] < 100) ? $self -> century : 0);
		$field[1]                  = 1; # Month.
		$field[0]                  = 1; # Day.
	}
	elsif ($#field == 1)
	{
		# This assumes the year is the last input field, and the month is first.

		$$flags{"${which}_offset"} = $field[1] < 100 ? 1 : 0;
		$field[2]                  = $field[1] + ( ($field[1] < 100) ? $self -> century : 0);
		$field[1]                  = $field[0]; # Month.
		$field[0]                  = 1;         # Day.
	}
	else
	{
		$$flags{"${which}_offset"} = 0;
	}

	$$flags{$which} = DateTime::Format::Natural -> new -> parse_datetime(join('-', @field) );

	print "\t$which: $$flags{$which}. \n";

} # End of parse_1_date.

# --------------------------------------------------

1;

=pod

=head1 NAME

L<Genealogy::Gedcom::Reader::Lexer::Date> - An OS-independent lexer for GEDCOM dates

=head1 Synopsis

	my($locale) = 'en_AU';
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

Default: 'en_AU'.

=item o logger => $logger_object

Specify a logger object.

To disable logging, just set logger to the empty string.

Default: An object of type L<Log::Handler>.

=back

=head1 Methods

=head2 candidate([$a_string])

The [] indicate an optional parameter.

Get or set the string being parsed.

=head2 century([$an_integer])

The [] indicate an optional parameter.

Get or set the value of the default century.

=head2 log($level, $s)

Calls $self -> logger -> $level($s).

=head2 locale([$locale])

Here, the [] indicate an optional parameter.

Get or set the locale.

=head2 logger([$logger_object])

Here, the [] indicate an optional parameter.

Get or set the logger object.

To disable logging, just set logger to the empty string.

=head2 parse([%arg])

Here, the [] indicate an optional parameter.

Parse the candidate and return a hashref.

$arg{candidate}: The candidate date can be passed in to new as new(candidate => $a_string), or into parse as parse(candidate => $a_string).

$arg{candidate} => $candidate takes precedence over new(candidate => $candidate).

This string is always converted to lower case before being processed.

In fact I<all> result data is lower case.

$arg{century}: The century can be passed in to new as new(century => $a_number), or into parse as parse(century => $a_number).

$arg{century} => $a_number takes precedence over new(century => $number).

$arg{locale}: The locale can be passed in to new as new(locale => $a_string), or into parse as parse(locale => $a_string).

$arg{locale} => $locale takes precedence over new(locale => $locale).

The return value is a hashref with these key => value pairs:

=over 4

=item o century => $integer

Returns the value passed in to new() or parse().

Default: 1900.

=item o escape => $the_escape_string

Default: 'dgregorian' (yes, lower case).

=item o first => $first_date_in_range

Returns the first (or only) date as a L<DateTime> object.

This is for cases like '1999' in 'about 1999', and for '1999' in 'Between 1999 and 2000', and '2001' in 'From 2001 to 2002'.

A missing month defaults to 01. A missing day defaults to 01.

'500BC' will be returned as '500-01-01', with the 'bc' flag set.

Default: DateTime::Infinite::Past -> new.

=item o first_ambiguous => $Boolean

Returns 1 if the first (or only) date is ambiguous. Possibilities:

=over 4

=item o The year is only 2 digits

=item o The month and day are reversible

=back

Default: 0.

=item o first_bc => $Boolean

Returns 1 if the first date is followed by one of: 'B.C.', 'BC.' or 'BC'.

In the input, this suffix can be separated from the year by spaces.

Warning: If this flag is set, the year has 1000 added to it, because L<DateTime> can't handle 1, 2 or 3 digit years.

That means, 500BC is 1500 with the flag set, and 2222BC is 3222 with the flag set.

Default: 0.

=item o infix => $a_string

This is for cases like 'and' in 'Between 1999 and 2000', and 'to' in 'From 2001 to 2002'.

Default: ''.

=item o last => $last_date_in_range

Returns the second of 2 dates as a L<DateTime> object.

This is for cases like '2000' in 'Between 1999 and 2000', and '2002' in 'From 2001 to 2002'.

A missing month defaults to 01. A missing day defaults to 01.

Default: DateTime::Infinite::Future -> new.

=item o last_ambiguous => $Boolean

Returns 1 if the last date is ambiguous.

See first_ambiguous for situations where this flag is set.

Default: 0.

=item o last_bc => $Boolean

Returns 1 if the second date is followed by one of: 'B.C.', 'BC.' or 'BC'.

In the input, this suffix can be separated from the year by spaces.

Warning: If this flag is set, the year has 1000 added to it, because L<DateTime> can't handle 1, 2 or 3 digit years.

That means, 500BC is 1500 with the flag set, and 2222BC is 3222 with the flag set.

Default: 0.

=item o locale => $the_user_supplied_locale

Default: The locale supplied to new() or to parse().

=item o phrase => $the_phrase

This is for cases like '(Unsure about the date)' or 'Approx' in '1999 (Approx)'.

The () are discarded.

Default: ''.

=item o prefix => $the_prefix

This is for cases like 'about' in 'About 1999'.

Default: ''.

=back

=head1 FAQ

=head2 Why are dates returned as objects of type DateTime?

Because such objects have the sophistication required to handle such a complex topic.

See L<DateTime> and L<http://datetime.perl.org/wiki/datetime/dashboard> for details.

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
