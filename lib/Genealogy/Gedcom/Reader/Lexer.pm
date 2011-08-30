package Genealogy::Gedcom::Reader::Lexer;

use strict;
use warnings;

use Hash::FieldHash ':all';

use Log::Handler;

use Perl6::Slurp;

use Set::Array;

fieldhash my %counter      => 'counter';
fieldhash my %gedcom_data  => 'gedcom_data';
fieldhash my %input_file   => 'input_file';
fieldhash my %items        => 'items';
fieldhash my %logger       => 'logger';
fieldhash my %maxlevel     => 'maxlevel';
fieldhash my %minlevel     => 'minlevel';
fieldhash my %report_items => 'report_items';
fieldhash my %result       => 'result';
fieldhash my %strict       => 'strict';

my $myself;
our $VERSION = '0.60';

# --------------------------------------------------

sub check_length
{
	my($self, $key, $line) = @_;
	my($value)  = $$line[4];
	my($length) = length($value);
	my($min)    = $self -> get_min_length($key, $line);
	my($max)    = $self -> get_max_length($key, $line);

	if ( ($length < $min) || ($length > $max) )
	{
		$self -> log(warning => "Warning: Line: $$line[0]. Field: $key. Value: $value. Length: $length. Valid length range $min .. $max");
	}

} # End of check_length.

# --------------------------------------------------

sub _count
{
	my($self) = @_;

	# Warning! Don't use:
	# return $self -> counter($self -> counter + 1);
	# It returns $self.

	$self -> counter($self -> counter + 1);

	return $self -> counter;

} # End of _count.

# --------------------------------------------------

sub cross_check_xrefs
{
	my($self) = @_;

	my(@link);
	my(%target);

	for my $item ($self -> items -> print)
	{
		if ($$item{type} =~ /^Link/)
		{
			push @link, [$$item{data}, $$item{line_count}];
		}

		if ( ($$item{level} == 0) && $$item{xref})
		{
			if ($target{$$item{xref} })
			{
				$self -> log(warning => "Warning. Line $$item{line_count}. Xref $$item{xref} was also used on line $target{$$item{xref} }");
			}

			$target{$$item{xref} } = $$item{line_count};
		}
	}

	my(%seen);

	for my $link (@link)
	{
		next if ($seen{$$link[0]});

		$self -> log(warning => "Warning: Line $$link[1]. Link $$link[0] does not point to an existing xref") if (! $target{$$link[0]}); 

		$seen{$$link[0]} = 1;
	}

} # End of cross_check_xrefs.

# --------------------------------------------------

sub get_gedcom_data_from_file
{
	my($self) = @_;

	$self -> gedcom_data([map{s/^\s+//; s/\s+$//; $_} slurp($self -> input_file, {chomp => 1})]);

} # End of get_gedcom_data_from_file.

# --------------------------------------------------
# Source of max: Ged551-5.pdf.
# See also scripts/find.unused.limits.pl.

sub get_max_length
{
	my($self, $key, $line) = @_;
	my(%max) =
		(
		 address_city => 60,
		 address_country => 60,
		 address_email => 120,
		 address_fax => 60,
		 address_line => 60,
		 address_line1 => 60,
		 address_line2 => 60,
		 address_line3 => 60,
		 address_postal_code => 10,
		 address_state => 60,
		 address_web_page => 120,
		 adopted_by_which_parent => 4,
		 age_at_event => 12,
		 ancestral_file_number => 12,
		 approved_system_id => 20,
		 attribute_descriptor => 90,
		 attribute_type => 4,
		 automated_record_id => 12,
		 caste_name => 90,
		 cause_of_event => 90,
		 certainty_assessment => 1,
		 change_date => 11,
		 character_set => 8,
		 child_linkage_status => 15,
		 copyright_gedcom_file => 90,
		 copyright_source_data => 90,
		 count_of_children => 3,
		 count_of_marriages => 3,
		 date => 35,
		 date_approximated => 35,
		 date_calendar => 35,
		 date_calendar_escape => 15,
		 date_exact => 11,
		 date_fren => 35,
		 date_greg => 35,
		 date_hebr => 35,
		 date_juln => 35,
		 date_lds_ord => 35,
		 date_period => 35,
		 date_phrase => 35,
		 date_range => 35,
		 date_value => 35,
		 day => 2,
		 descriptive_title => 248,
		 digit => 1,
		 entry_recording_date => 90,
		 event_attribute_type => 15,
		 event_descriptor => 90,
		 event_or_fact_classification => 90,
		 event_type_family => 4,
		 event_type_individual => 4,
		 events_recorded => 90,
		 file_name => 90,
		 gedcom_content_description => 248,
		 gedcom_form => 20,
		 generations_of_ancestors => 4,
		 generations_of_descendants => 4,
		 language_id => 15,
		 language_of_text => 15,
		 language_preference => 90,
		 lds_baptism_date_status => 10,
		 lds_child_sealing_date_status => 10,
		 lds_endowment_date_status => 10,
		 lds_spouse_sealing_date_status => 10,
		 multimedia_file_reference => 30,
		 multimedia_format => 4,
		 name_of_business => 90,
		 name_of_family_file => 120,
		 name_of_product => 90,
		 name_of_repository => 90,
		 name_of_source_data => 90,
		 name_personal => 120,
		 name_phonetic_variation => 120,
		 name_piece => 90,
		 name_piece_given => 120,
		 name_piece_nickname => 30,
		 name_piece_prefix => 30,
		 name_piece_suffix => 30,
		 name_piece_surname => 120,
		 name_piece_surname_prefix => 30,
		 name_romanized_variation => 120,
		 name_text => 120,
		 name_type => 30,
		 national_id_number => 30,
		 national_or_tribal_origin => 120,
		 new_tag => 15,
		 nobility_type_title => 120,
		 null => 0,
		 occupation => 90,
		 ordinance_process_flag => 3,
		 pedigree_linkage_type => 7,
		 permanent_record_file_number => 90,
		 phone_number => 25,
		 phonetic_type => 30,
		 physical_description => 248,
		 place_hierarchy => 120,
		 place_latitude => 8,
		 place_living_ordinance => 120,
		 place_longitude => 8,
		 place_name => 120,
		 place_phonetic_variation => 120,
		 place_romanized_variation => 120,
		 place_text => 120,
		 possessions => 248,
		 publication_date => 11,
		 receiving_system_name => 20,
		 record_identifier => 18,
		 registered_resource_identifier => 25,
		 relation_is_descriptor => 25,
		 religious_affiliation => 90,
		 responsible_agency => 120,
		 restriction_notice => 7,
		 role_descriptor => 25,
		 role_in_event => 15,
		 romanized_type => 30,
		 scholastic_achievement => 248,
		 sex_value => 7,
		 social_security_number => 11,
		 source_call_number => 120,
		 source_description => 248,
		 source_descriptive_title => 248,
		 source_filed_by_entry => 60,
		 source_jurisdiction_place => 120,
		 source_media_type => 15,
		 source_originator => 248,
		 source_publication_facts => 248,
		 submitter_name => 60,
		 submitter_registered_rfn => 30,
		 submitter_text => 248,
		 temple_code => 5,
		 text => 248,
		 text_from_source => 248,
		 time_value => 12,
		 transmission_date => 11,
		 user_reference_number => 20,
		 user_reference_type => 40,
		 version_number => 15,
		 where_within_source => 248,
		 year => 4,
		 year_greg => 7,
		);

	# This dies rather than calls log(error...) because it's a coding error if $key is mis-spelt.

	return $max{$key} || die "Error: Line: $$line[0]. Invalid field name in get_max_length($key)";

} # End of get_max_length.

# --------------------------------------------------

sub get_min_length
{
	my($self, $key, $line) = @_;

	return $self -> strict;

} # End of get_min_length.

# --------------------------------------------------

sub _init
{
	my($self, $arg)     = @_;
	$$arg{counter}      = 0;
	$$arg{gedcom_data}  = [];
	$$arg{input_file}   ||= ''; # Caller can set.
	$$arg{items}        = Set::Array -> new;
	my($user_logger)    = defined($$arg{logger}); # Caller can set (e.g. to '').
	$$arg{logger}       = $user_logger ? $$arg{logger} : Log::Handler -> new;
	$$arg{maxlevel}     ||= 'info';  # Caller can set.
	$$arg{minlevel}     ||= 'error'; # Caller can set.
	$$arg{report_items} ||= 0;       # Caller can set.
	$$arg{result}       = 0;
	$$arg{strict}       ||= $$arg{strict} =~ /^[01]$/ ? $$arg{strict} : 0;  # Caller can set.
	$self               = from_hash($self, $arg);

	if (! $user_logger)
	{
		$self -> logger -> add
			(
			 screen =>
			 {
				 alias          => 'screen',
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

sub push_item
{
	my($self, $line, $type) = @_;

	$myself -> items -> push
		(
		 {
			 count      => $self -> _count,
			 data       => $$line[4],
			 level      => $$line[1],
			 line_count => $$line[0],
			 tag        => $$line[3],
			 type       => $type,
			 xref       => $$line[2],
		 }
		);

} # End of push_item.

# -----------------------------------------------

sub renumber_items
{
	my($self) = @_;
	my(@item) = @{$self -> items};

	my(@new);

	for my $i (0 .. $#item)
	{
		$item[$i]{count} = $i + 1;

		push @new, $item[$i];
	}

	$self -> items(Set::Array -> new(@new) );

} # End of renumber_items.

# -----------------------------------------------

sub report
{
	my($self)   = @_;
	my($format) = '%6s  %6s  %6s  %-6s  %-6s  %-12s  %-s';

	$self -> log(info => sprintf($format, 'Count', 'Line', 'Level', 'Tag', 'Xref', 'Type', 'Data') );

	my(%type);

	for my $item ($self -> items -> print)
	{
		$type{$$item{type} } = 1;

		$self -> log(info => sprintf($format, $$item{count}, $$item{line_count}, $$item{level}, $$item{tag}, $$item{xref}, $$item{type}, $$item{data}) );
	}

} # End of report.

# --------------------------------------------------

sub run
{
	my($self) = @_;
	$myself   = $self;

	if ($self -> input_file)
	{
		$self -> get_gedcom_data_from_file;
	}
	else
	{
		my($lines) = $self -> gedcom_data;

		die 'Error: You must provide a GEDCOM file with -input_file, or data with gedcom_data([...])' if ($#$lines < 0);
	}

	my($line)       = [];
	my($line_count) = 0;
	my($result)     = 0; # Default to success.

	for my $record (@{$self -> gedcom_data})
	{
		$line_count++;

		next if ($record =~ /^$/);

		# Arrayref elements:
		# 0: Input file line count.
		# 1: Level.
		# 2: Record id to be used as the target of a xref.
		# 3: Tag.
		# 4: Data belonging to tag.
		# 5: Type (Item/Child of item) of record.
		# 6: Input record.

		if ($record =~ /^(0)\s+\@(.+?)\@\s+(_?(?:[A-Z]{3,4}))\s*(.*)$/)
		{
			push @$line, [$line_count, $1, defined($2) ? $2 : '', $3, defined($4) ? $4 : '', $record];
		}
		elsif ($record =~ /^(0)\s+(HEAD|TRLR)$/)
		{
			push @$line, [$line_count, $1, '', $2, '', $record];
		}
		elsif ($record =~ /^(\d+)\s+(_?(?:ADR[123]|[A-Z]{3,5}))\s*\@?(.*?)\@?$/)
		{
			push @$line, [$line_count, $1, '', $2, defined($3) ? $3 : '', $record];
		}
		else
		{
			die "Error: Line: $line_count. Invalid GEDCOM syntax in '$record'";
		}
	}

	tag_lineage(0, $line);

	$self -> report if ($self -> report_items);
	$self -> cross_check_xrefs;

	# Return 0 for success and 1 for failure.

	return $result;

} # End of run.

# --------------------------------------------------

sub tag_address_city
{
	my($index, $line) = @_;
	my($id) = 'address_city';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Address');

	return ++$index;

} # End of tag_address_city.

# --------------------------------------------------

sub tag_address_country
{
	my($index, $line) = @_;
	my($id) = 'address_country';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Address');

	return ++$index;

} # End of tag_address_country.

# --------------------------------------------------

sub tag_address_email
{
	my($index, $line) = @_;
	my($id) = 'address_email';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Address');

	return ++$index;

} # End of tag_address_email.

# --------------------------------------------------

sub tag_address_fax
{
	my($index, $line) = @_;
	my($id) = 'address_fax';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Address');

	return ++$index;

} # End of tag_address_fax.

# --------------------------------------------------

sub tag_address_line
{
	my($index, $line) = @_;
	my($id) = 'address_line';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Address');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 ADR1 => \&tag_address_line1,
			 ADR2 => \&tag_address_line2,
			 ADR3 => \&tag_address_line3,
			 CITY => \&tag_address_city,
			 CONT => \&tag_continue,
			 CTRY => \&tag_address_country,
			 POST => \&tag_address_postal_code,
			 STAE => \&tag_address_state,
		 }
		);

} # End of tag_address_line.

# --------------------------------------------------

sub tag_address_line1
{
	my($index, $line) = @_;
	my($id) = 'address_line1';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Address');

	return ++$index;

} # End of tag_address_line1.

# --------------------------------------------------

sub tag_address_line2
{
	my($index, $line) = @_;
	my($id) = 'address_line2';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Address');

	return ++$index;

} # End of tag_address_line2.

# --------------------------------------------------

sub tag_address_line3
{
	my($index, $line) = @_;
	my($id) = 'address_line3';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Address');

	return ++$index;

} # End of tag_address_line3.

# --------------------------------------------------

sub tag_address_postal_code
{
	my($index, $line) = @_;
	my($id) = 'address_postal_code';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Address');

	return ++$index;

} # End of tag_address_postal_code.

# --------------------------------------------------

sub tag_address_state
{
	my($index, $line) = @_;
	my($id) = 'address_state';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Address');

	return ++$index;

} # End of tag_address_state.

# --------------------------------------------------

sub tag_address_structure
{
	my($index, $line) = @_;
	my($id) = 'address_structure';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($index, 'address_line', $$line[$index][4]);
	$myself -> push_item($$line[$index], 'Address structure');

	# Special case: $index, not ++$index. We're assumed to be already printing at the tag ADDR.

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 tag_address_structure_tags(),
		 }
		);

} # End of tag_address_structure.

# --------------------------------------------------

sub tag_address_structure_tags
{
	return
		(
		 ADDR  => \&tag_address_line,
		 EMAIL => \&tag_address_email,
		 FAX   => \&tag_address_fax,
		 PHON  => \&tag_phone_number,
		 WWW   => \&tag_address_web_page,
		);

} # End of tag_address_structure_tags.

# --------------------------------------------------

sub tag_address_web_page
{
	my($index, $line) = @_;
	my($id) = 'address_web_page';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Address');

	return ++$index;

} # End of tag_address_web_page.

# --------------------------------------------------

sub tag_advance
{
	my($id, $index, $line, $jump) = @_;
	my($level) = $$line[$index][1];
	my($tag)   = $$line[$index][3];

	$myself -> log(debug => "\tEnter tag_advance. Line: $$line[$index][0]. Index: $index. Tag: $tag. Level: $level. Caller: tag_$id");

	while ( ($index <= $#$line) && ($$line[$index][1] >= $level) && ($$jump{$$line[$index][3]} || ($$line[$index][3] =~ /^_/) ) )
	{
		if ($$jump{$$line[$index][3]})
		{
			$index = $$jump{$$line[$index][3]} -> ($index, $line);
		}
		else
		{
			$myself -> push_item($$line[$index], 'User');

			$index++;
		}
	}

	$myself -> log(debug => "\tLeave tag_advance. Line: $$line[$index][0]. Index: $index. Tag: $tag. Level: $level. Caller: tag_$id");

	return $index;

} # End of tag_advance.

# --------------------------------------------------

sub tag_age_at_event
{
	my($index, $line) = @_;
	my($id) = 'age_at_event';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_age_at_event.

# --------------------------------------------------

sub tag_alias_xref
{
	my($index, $line) = @_;
	my($id) = 'alias_xref';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Link to INDI');

	return ++$index;

} # End of tag_alias_xref.

# --------------------------------------------------

sub tag_ancestral_file_number
{
	my($index, $line) = @_;
	my($id) = 'ancestral_file_number';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_ancestral_file_number.

# --------------------------------------------------

sub tag_approved_system_id
{
	my($index, $line) = @_;
	my($id) = 'approved_system_id';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 CORP => \&tag_name_of_business,
			 DATA => \&tag_name_of_source_data,
			 NAME => \&tag_name_of_product,
			 VERS => \&tag_version_number,
		 }
		);

} # End of tag_approved_system_id.

# --------------------------------------------------

sub tag_association_structure
{
	my($index, $line) = @_;
	my($id) = 'association_structure';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Individual');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 NOTE => \&tag_note_structure,
			 RELA => \&tag_relation_is_descriptor,
			 SOUR => \&tag_source_citation,
		 }
		);

} # End of tag_association_structure.

# --------------------------------------------------

sub tag_automated_record_id
{
	my($index, $line) = @_;
	my($id) = 'automated_record_id';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_automated_record_id.

# --------------------------------------------------

sub tag_bapl_conl
{
	my($index, $line) = @_;
	my($id) = 'bapl_conl';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Individual');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 DATE => \&tag_date_lds_ord,
			 NOTE => \&tag_note_structure,
			 PLAC => \&tag_place_living_ordinance,
			 SOUR => \&tag_source_citation,
			 STAT => \&tag_lds_baptism_date_status,
			 TEMP => \&tag_temple_code,
		 }
		);

} # End of tag_bapl_conl.

# --------------------------------------------------

sub tag_caste_name
{
	my($index, $line) = @_;
	my($id) = 'caste_name';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return tag_advance
		(
		 $id,
		 +$index,
		 $line,
		 {
			 DATE => \&tag_change_date1,
			 NOTE => \&tag_note_structure,
		 }
		);

} # End of tag_caste_name.

# --------------------------------------------------

sub tag_cause_of_event
{
	my($index, $line) = @_;
	my($id) = 'cause_of_event';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Event');

	return ++$index;

} # End of tag_cause_of_event.

# --------------------------------------------------

sub tag_certainty_assessment
{
	my($index, $line) = @_;
	my($id) = 'certainty_assessment';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Source');

	return ++$index;

} # End of tag_certainty_assessment.

# --------------------------------------------------

sub tag_change_date1
{
	my($index, $line) = @_;
	my($id) = 'change_date1';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], '');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 DATE => \&tag_change_date,
			 NOTE => \&tag_note_structure,
		 }
		);

} # End of tag_change_date1.

# --------------------------------------------------

sub tag_change_date
{
	my($index, $line) = @_;
	my($id) = 'change_date';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 TIME => \&tag_time_value,
		 }
		);

} # End of tag_change_date.

# --------------------------------------------------

sub tag_character_set
{
	my($index, $line) = @_;
	my($id) = 'character_set';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Header');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 VERS => \&tag_version_number,
		 }
		);

} # End of tag_character_set.

# --------------------------------------------------

sub tag_child_xref
{
	my($index, $line) = @_;
	my($id) = 'child_xref';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Link to INDI');

	return ++$index;

} # End of tag_child_xref.

# --------------------------------------------------

sub tag_child_linkage_status
{
	my($index, $line) = @_;
	my($id) = 'child_linkage_status';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_child_linkage_status.

# --------------------------------------------------

sub tag_child_to_family_link
{
	my($index, $line) = @_;
	my($id) = 'child_to_family_link';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Link to FAM');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 NOTE => \&tag_note_structure,
			 PEDI => \&tag_pedigree_linkage_type,
			 STAT => \&tag_child_linkage_status,
		 }
		);

} # End of tag_child_to_family_link.

# --------------------------------------------------

sub tag_child_to_family_xref
{
	my($index, $line) = @_;
	my($id) = 'child_to_family_xref';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Link to FAM');

	return ++$index;

} # End of tag_child_to_family_xref.

# --------------------------------------------------

sub tag_concat
{
	my($index, $line) = @_;
	my($id) = 'concat';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Concat');

	return ++$index;

} # End of tag_concat.

# --------------------------------------------------

sub tag_continue
{
	my($index, $line) = @_;
	my($id) = 'continue';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Continue');

	return ++$index;

} # End of tag_continue.

# --------------------------------------------------

sub tag_copyright_gedcom_file
{
	my($index, $line) = @_;
	my($id) = 'copyright_gedcom_file';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Header');

	return ++$index;

} # End of tag_copyright_gedcom_file.

# --------------------------------------------------

sub tag_copyright_source_data
{
	my($index, $line) = @_;
	my($id) = 'copyright_source_data';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Copyright');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 CONC => \&tag_concat,
			 CONT => \&tag_continue,
		 }
		);

} # End of tag_copyright_source_data.

# --------------------------------------------------

sub tag_count_of_children
{
	my($index, $line) = @_;
	my($id) = 'count_of_children';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Family');

	return ++$index;

} # End of tag_child_count.

# --------------------------------------------------

sub tag_count_of_marriages
{
	my($index, $line) = @_;
	my($id) = 'count_of_marriages';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Family');

	return ++$index;

} # End of tag_count_of_marriages.

# --------------------------------------------------

sub tag_date_lds_ord
{
	my($index, $line) = @_;
	my($id) = 'date_lds_ord';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Family');

	return ++$index;

} # End of tag_date_lds_ord.

# --------------------------------------------------

sub tag_date_period
{
	my($index, $line) = @_;
	my($id) = 'date_period';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_date_period.

# --------------------------------------------------

sub tag_date_value
{
	my($index, $line) = @_;
	my($id) = 'date_value';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_date_value.

# --------------------------------------------------

sub tag_descriptive_title
{
	my($index, $line) = @_;
	my($id) = 'descriptive_title';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_descriptive_title.

# --------------------------------------------------

sub tag_endl
{
	my($index, $line) = @_;
	my($id) = 'endl';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Individual');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 DATE => \&tag_date_lds_ord,
			 NOTE => \&tag_note_structure,
			 PLAC => \&tag_place_living_ordinance,
			 SOUR => \&tag_source_citation,
			 STAT => \&tag_lds_endowment_date_status,
			 TEMP => \&tag_temple_code,
		 }
		);

} # End of tag_endl.

# --------------------------------------------------

sub tag_event_detail
{
	my($index, $line) = @_;
	my($id) = 'event_detail';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Event');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 tag_event_detail_tags(),
		 }
		);

} # End of tag_event_detail.

# --------------------------------------------------

sub tag_event_detail_tags
{
	return
		(
		 AGNC => \&tag_responsible_agency,
		 CAUS => \&tag_cause_of_event,
		 DATE => \&tag_date_value,
		 NOTE => \&tag_note_structure,
		 OBJE => \&tag_multimedia_link,
		 PLAC => \&tag_place_name,
		 RELI => \&tag_religious_affiliation,
		 RESN => \&tag_restriction_notice,
		 SOUR => \&tag_source_citation,
		 TYPE => \&tag_event_or_fact_classification,
		 tag_address_structure_tags(),
		);

} # End of tag_event_detail_tags.

# --------------------------------------------------

sub tag_event_or_fact_classification
{
	my($index, $line) = @_;
	my($id) = 'event_or_fact_classification';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_event_or_fact_classification.

# --------------------------------------------------

sub tag_event_type_cited_from
{
	my($index, $line) = @_;
	my($id) = 'event_type_cited_from';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Event');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 ROLE => \&tag_role_in_event,
		 }
		);

} # End of tag_event_type_cited_from.

# --------------------------------------------------

sub tag_events_recorded
{
	my($index, $line) = @_;
	my($id) = 'events_recorded';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Event');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 DATE => \&tag_date_period,
			 PLAC => \&tag_source_jurisdiction_place,
		 }
		);

} # End of tag_events_recorded.

# --------------------------------------------------

sub tag_family_event_detail
{
	my($index, $line) = @_;
	my($id) = 'family_event_detail';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Event');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 HUSB => \&tag_age_at_event,
			 WIFE => \&tag_age_at_event,
			 tag_event_detail_tags(),
		 }
		);

} # End of tag_family_event_detail.

# --------------------------------------------------

sub tag_file_name
{
	my($index, $line) = @_;
	my($id) = 'file_name';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'File name');

	return ++$index;

} # End of tag_file_name.

# --------------------------------------------------

sub tag_family_record
{
	my($index, $line) = @_;
	my($id) = 'family_record';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Family');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 ANUL  => \&tag_family_event_detail,
			 CENS  => \&tag_family_event_detail,
			 CHAN  => \&tag_change_date1,
			 CHIL  => \&tag_child_xref,
			 DIV   => \&tag_family_event_detail,
			 DIVF  => \&tag_family_event_detail,
			 ENGA  => \&tag_family_event_detail,
			 EVEN  => \&tag_family_event_detail,
			 HUSB  => \&tag_husband_xref,
			 MARB  => \&tag_family_event_detail,
			 MARC  => \&tag_family_event_detail,
			 MARL  => \&tag_family_event_detail,
			 MARR  => \&tag_family_event_detail,
			 MARS  => \&tag_family_event_detail,
			 NCHIL => \&tag_count_of_children,
			 NOTE  => \&tag_note_structure,
			 OBJE  => \&tag_multimedia_link,
			 REFN  => \&tag_user_reference_number,
			 RESI  => \&tag_family_event_detail,
			 RESN  => \&tag_restriction_notice,
			 RIN   => \&tag_rin,
			 SLGS  => \&tag_lds_spouse_sealing,
			 SOUR  => \&tag_source_citation,
			 SUBM  => \&tag_submitter_xref,
			 WIFE  => \&tag_wife_xref,
		 }
		);

} # End of tag_family_record.

# --------------------------------------------------

sub tag_gedcom
{
	my($index, $line) = @_;
	my($id) = 'gedcom';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Header');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 FORM => \&tag_gedcom_form,
			 VERS => \&tag_version_number,
		 }
		);

} # End of tag_gedcom.

# --------------------------------------------------

sub tag_gedcom_form
{
	my($index, $line) = @_;
	my($id) = 'gedcom_form';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_gedcom_form.

# --------------------------------------------------

sub tag_generations_of_ancestors
{
	my($index, $line) = @_;
	my($id) = 'generations_of_ancestors';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Submission');

	return ++$index;

} # End of tag_generations_of_ancestors.

# --------------------------------------------------

sub tag_generations_of_descendants
{
	my($index, $line) = @_;
	my($id) = 'generations_of_descendants';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Submission');

	return ++$index;

} # End of tag_generations_of_descendants.

# --------------------------------------------------

sub tag_header
{
	my($index, $line) = @_;
	my($id) = 'header';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Header');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
		 CHAR => \&tag_character_set,
		 COPR => \&tag_copyright_gedcom_file,
		 DATE => \&tag_transmission_date,
		 DEST => \&tag_receiving_system_name,
		 FILE => \&tag_file_name,
		 GEDC => \&tag_gedcom,
		 LANG => \&tag_language_of_text,
		 NOTE => \&tag_note_structure,
		 PLAC => \&tag_place,
		 SUBM => \&tag_submitter_xref,
		 SUBN => \&tag_submission_xref,
		 SOUR => \&tag_approved_system_id,
		 }
		);

} # End of tag_header.

# --------------------------------------------------

sub tag_husband_xref
{
	my($index, $line) = @_;
	my($id) = 'husband_xref';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Link to INDI');

	return ++$index;

} # End of tag_husband_xref.

# --------------------------------------------------

sub tag_individual_attribute_detail
{
	my($index, $line) = @_;
	my($id) = 'individual_attribute_detail';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_individual_attribute_detail.

# --------------------------------------------------

sub tag_individual_attribute_structure_tags
{
	return
		(
		 CAST => \&tag_caste_name,
		 DSCR => \&tag_physical_description,
		 EDUC => \&tag_scholastic_achievement,
		 FACT => \&tag_individual_attribute_detail,
		 IDNO => \&tag_national_id_number,
		 NATI => \&tag_national_or_tribal_origin,
		 NCHI => \&tag_individual_attribute_detail,
		 NMR  => \&tag_count_of_marriages,
		 OCCU => \&tag_occupation,
		 PROP => \&tag_possessions,
		 RELI => \&tag_individual_attribute_detail,
		 RESI => \&tag_individual_attribute_detail,
		 SSN  => \&tag_social_security_number,
		 TITL => \&tag_nobility_type_title,
		);

} # End of tag_individual_attribute_structure_tags.

# --------------------------------------------------

sub tag_individual_event_detail
{
	my($index, $line) = @_;
	my($id) = 'individual_event_detail';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Event');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 AGE => \&tag_age_at_event,
			 tag_event_detail_tags(),
		 }
		);

} # End of tag_individual_event_detail.

# --------------------------------------------------

sub tag_individual_event_structure_tags
{
	return
		(
		 ADOP => \&tag_individual_event_detail,
		 BAPM => \&tag_individual_event_detail,
		 BARM => \&tag_individual_event_detail,
		 BASM => \&tag_individual_event_detail,
		 BLES => \&tag_individual_event_detail,
		 BIRT => \&tag_individual_event_detail,
		 BURI => \&tag_individual_event_detail,
		 CENS => \&tag_individual_event_detail,
		 CHAN => \&tag_change_date1,
		 CHR  => \&tag_individual_event_detail,
		 CHRA => \&tag_individual_event_detail,
		 CONF => \&tag_individual_event_detail,
		 CREM => \&tag_individual_event_detail,
		 DEAT => \&tag_individual_event_detail,
		 EMIG => \&tag_individual_event_detail,
		 EVEN => \&tag_individual_event_detail,
		 FCOM => \&tag_individual_event_detail,
		 GRAD => \&tag_individual_event_detail,
		 IMMI => \&tag_individual_event_detail,
		 NATU => \&tag_individual_event_detail,
		 ORDN => \&tag_individual_event_detail,
		 PROB => \&tag_individual_event_detail,
		 RETI => \&tag_individual_event_detail,
		 WILL => \&tag_individual_event_detail,
		);

} # End of tag_individual_event_structure_tags.

# --------------------------------------------------

sub tag_individual_record
{
	my($index, $line) = @_;
	my($id) = 'individual_record';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Individual');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 AFN  => \&tag_ancestral_file_number,
			 ALIA => \&tag_alias_xref,
			 ANCI => \&tag_submitter_xref,
			 ASSO => \&tag_association_structure,
			 BAPL => \&tag_bapl_conl,
			 CONL => \&tag_bapl_conl,
			 DESI => \&tag_submitter_xref,
			 ENDL => \&tag_endl,
			 FAMC => \&tag_child_to_family_link,
			 FAMS => \&tag_spouse_to_family_link,
			 NAME => \&tag_name_personal,
			 REFN => \&tag_user_reference_number,
			 RESN => \&tag_restriction_notice,
			 RFN  => \&tag_permanent_record_file_number,
			 RIN  => \&tag_automated_record_id,
			 SEX  => \&tag_sex_value,
			 SLGC => \&tag_slgc,
			 SUBM => \&tag_submitter_xref,
			 tag_individual_attribute_structure_tags(),
			 tag_individual_event_structure_tags(),
		 }
		);

} # End of tag_individual_record.

# --------------------------------------------------

sub tag_language_of_text
{
	my($index, $line) = @_;
	my($id) = 'language_of_text';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Header');

	return ++$index;

} # End of tag_language_of_text.

# --------------------------------------------------

sub tag_language_preference
{
	my($index, $line) = @_;
	my($id) = 'language_preference';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Submitter');

	return ++$index;

} # End of tag_language_preference.

# --------------------------------------------------

sub tag_lds_baptism_date_status
{
	my($index, $line) = @_;
	my($id) = 'lds_baptism_date_status';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 DATE => \&tag_change_date1,
		 }
		);

} # End of tag_lds_baptism_date_status.

# --------------------------------------------------

sub tag_lds_child_sealing_date_status
{
	my($index, $line) = @_;
	my($id) = 'lds_child_sealing_date_status';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 DATE => \&tag_change_date1,
		 }
		);

} # End of tag_lds_child_sealing_date_status.

# --------------------------------------------------

sub tag_lds_endowment_date_status
{
	my($index, $line) = @_;
	my($id) = 'lds_endowment_date_status';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 DATE => \&tag_change_date1,
		 }
		);

} # End of tag_lds_endowment_date_status.

# --------------------------------------------------

sub tag_lds_spouse_sealing
{
	my($index, $line) = @_;
	my($id) = 'lds_spouse_sealing';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Family');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 DATE => \&tag_date_lds_ord,
			 NOTE => \&tag_note_structure,
			 PLAC => \&tag_place_living_ordinance,
			 SOUR => \&tag_source_citation,
			 STAT => \&tag_lds_spouse_sealing_date_status,
			 TEMP => \&tag_temple_code,
		 }
		);

} # End of tag_lds_spouse_sealing.

# --------------------------------------------------

sub tag_lds_spouse_sealing_date_status
{
	my($index, $line) = @_;
	my($id) = 'lds_spouse_sealing_date_status';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Family');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 DATE => \&tag_change_date1,
		 }
		);

} # End of tag_lds_spouse_sealing_date_status.

# --------------------------------------------------

sub tag_lineage
{
	my($index, $line) = @_;
	my($id) = 'lineage';
	$index  = tag_header($index, $line);
	$index  = tag_advance
		(
		 $id,
		 $index,
		 $line,
		 {
			 SUBN => \&tag_submission_record,
		 }
		);
	$index = tag_advance
		(
		 $id,
		 $index,
		 $line,
		 {
			 FAM  => \&tag_family_record,
			 INDI => \&tag_individual_record,
			 NOTE => \&tag_note_record,
			 OBJE => \&tag_multimedia_record,
			 REPO => \&tag_repository_record,
			 SOUR => \&tag_source_record,
			 SUBM => \&tag_submitter_record,
		 }
		);

	tag_trailer($index, $line);

} # End of tag_lineage.

# --------------------------------------------------

sub tag_map
{
	my($index, $line) = @_;
	my($id) = 'map';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Place');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 LATI => \&tag_place_latitude,
			 LONG => \&tag_place_longitude,
		 }
		);

} # End of tag_map.

# --------------------------------------------------

sub tag_multimedia_link
{
	my($index, $line) = @_;
	my($id) = 'multimedia_link';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Link to OBJE');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 FILE => \&tag_multimedia_link_file_refn,
			 TITL => \&tag_descriptive_title,
		 }
		);

} # End of tag_multimedia_link.

# --------------------------------------------------

sub tag_multimedia_link_file_refn
{
	my($index, $line) = @_;
	my($id) = 'multimedia_link_file_refn';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($index, 'multimedia_file_reference', $$line[$index][4]);
	$myself -> push_item($$line[$index], 'Multimedia');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 FORM => \&tag_multimedia_link_format,
		 }
		);

} # End of tag_multimedia_link_file_refn.

# --------------------------------------------------

sub tag_multimedia_link_format
{
	my($index, $line) = @_;
	my($id) = 'multimedia_format';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Multimedia');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 MEDI => \&tag_source_media_type,
		 }
		);

} # End of tag_multimedia_link_format.

# --------------------------------------------------

sub tag_multimedia_record
{
	my($index, $line) = @_;
	my($id) = 'multimedia_record';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Multimedia');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 CHAN => \&tag_change_date1,
			 FILE => \&tag_multimedia_record_file_refn,
			 NOTE => \&tag_note_structure,
			 REFN => \&tag_user_reference_number,
			 RIN  => \&tag_automated_record_id,
			 SOUR => \&tag_source_citation,
		 }
		);

} # End of tag_multimedia_record.

# --------------------------------------------------

sub tag_multimedia_record_file_refn
{
	my($index, $line) = @_;
	my($id) = 'multimedia_record_file_refn';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($index, 'multimedia_file_reference', $$line[$index][4]);
	$myself -> push_item($$line[$index], 'Multimedia');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 FORM => \&tag_multimedia_record_format,
			 TITL => \&tag_descriptive_title,
		 }
		);

} # End of tag_multimedia_record_file_refn.

# --------------------------------------------------

sub tag_multimedia_record_format
{
	my($index, $line) = @_;
	my($id) = 'multimedia_format';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Multimedia');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 TYPE => \&tag_source_media_type,
		 }
		);

} # End of tag_multimedia_record_format.

# --------------------------------------------------

sub tag_name_of_business
{
	my($index, $line) = @_;
	my($id) = 'name_of_business';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 tag_address_structure_tags(),
		 }
		);

} # End of tag_name_of_business.

# --------------------------------------------------

sub tag_name_of_family_file
{
	my($index, $line) = @_;
	my($id) = 'name_of_family_file';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'File name');

	return ++$index;

} # End of tag_name_of_family_file.

# --------------------------------------------------

sub tag_name_of_product
{
	my($index, $line) = @_;
	my($id) = 'name_of_product';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_name_of_product.

# --------------------------------------------------

sub tag_name_of_repository
{
	my($index, $line) = @_;
	my($id) = 'name_of_repository';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Repository');

	return ++$index;

} # End of tag_name_of_repository.

# --------------------------------------------------

sub tag_name_of_source_data
{
	my($index, $line) = @_;
	my($id) = 'name_of_source_data';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Source');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 DATE => \&tag_publication_date,
			 COPR => \&tag_copyright_source_data,
		 }
		);

} # End of tag_name_of_source_data.

# --------------------------------------------------

sub tag_name_personal
{
	my($index, $line) = @_;
	my($id) = 'name_personal';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 FONE => \&tag_name_phonetic_variation,
			 ROMN => \&tag_name_romanized_variation,
			 TYPE => \&tag_name_type,
			 tag_personal_name_piece_tags(),
		 }
		);

} # End of tag_name_personal.

# --------------------------------------------------

sub tag_name_phonetic_variation
{
	my($index, $line) = @_;
	my($id) = 'name_phonetic_variation';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 TYPE => \&tag_phonetic_type,
			 tag_personal_name_piece_tags(),
		 }
		);

} # End of tag_name_phonetic_variation.

# --------------------------------------------------

sub tag_name_piece_given
{
	my($index, $line) = @_;
	my($id) = 'name_piece_given';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_name_piece_given.

# --------------------------------------------------

sub tag_name_piece_nickname
{
	my($index, $line) = @_;
	my($id) = 'name_piece_nickname';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_name_piece_nickname.

# --------------------------------------------------

sub tag_name_piece_prefix
{
	my($index, $line) = @_;
	my($id) = 'name_piece_prefix';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_name_piece_prefix.

# --------------------------------------------------

sub tag_name_piece_suffix
{
	my($index, $line) = @_;
	my($id) = 'name_piece_suffix';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_name_piece_suffix.

# --------------------------------------------------

sub tag_name_piece_surname
{
	my($index, $line) = @_;
	my($id) = 'name_piece_surname';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_name_piece_surname.

# --------------------------------------------------

sub tag_name_piece_surname_prefix
{
	my($index, $line) = @_;
	my($id) = 'name_piece_surname_prefix';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_name_piece_surname_prefix.

# --------------------------------------------------

sub tag_name_romanized_variation
{
	my($index, $line) = @_;
	my($id) = 'name_romanized_variation';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 TYPE => \&tag_romanized_type,
			 tag_personal_name_piece_tags(),
		 }
		);

} # End of tag_name_romanized_variation.

# --------------------------------------------------

sub tag_name_type
{
	my($index, $line) = @_;
	my($id) = 'name_type';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_name_type.

# --------------------------------------------------

sub tag_national_or_tribal_origin
{
	my($index, $line) = @_;
	my($id) = 'national_or_tribal_origin';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_national_or_tribal_origin.

# --------------------------------------------------

sub tag_national_id_number
{
	my($index, $line) = @_;
	my($id) = 'national_id_number';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_national_id_number.

# --------------------------------------------------

sub tag_nobility_type_title
{
	my($index, $line) = @_;
	my($id) = 'nobility_type_title';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_nobility_type_title.

# --------------------------------------------------

sub tag_note_record
{
	my($index, $line) = @_;
	my($id) = 'note_record';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Note');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 CHAN => \&tag_change_date1,
			 CONC => \&tag_concat,
			 CONT => \&tag_continue,
			 REFN => \&tag_user_reference_number,
			 RIN  => \&tag_automated_record_id,
			 SOUR => \&tag_source_citation,
		 }
		);

} # End of tag_note_record.

# --------------------------------------------------

sub tag_note_structure
{
	my($index, $line) = @_;
	my($id) = 'note_structure';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Note');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 CONC => \&tag_concat,
			 CONT => \&tag_continue,
		 }
		);

} # End of tag_note_structure.

# --------------------------------------------------

sub tag_occupation
{
	my($index, $line) = @_;
	my($id) = 'occupation';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_occupation.

# --------------------------------------------------

sub tag_ordinance_process_flag
{
	my($index, $line) = @_;
	my($id) = 'ordinance_process_flag';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Submission');

	return ++$index;

} # End of tag_ordinance_process_flag.

# --------------------------------------------------

sub tag_pedigree_linkage_type
{
	my($index, $line) = @_;
	my($id) = 'pedigree_linkage_type';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_pedigree_linkage_type.

# --------------------------------------------------

sub tag_permanent_record_file_number
{
	my($index, $line) = @_;
	my($id) = 'permanent_record_file_number';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_permanent_record_file_number.

# --------------------------------------------------

sub tag_personal_name_piece_tags
{
	return
		(
		 GIVN => \&tag_name_piece_given,
		 NICK => \&tag_name_piece_nickname,
		 NOTE => \&tag_note_structure,
		 NPFX => \&tag_name_piece_prefix,
		 NSFX => \&tag_name_piece_suffix,
		 SOUR => \&tag_source_citation,
		 SPFX => \&tag_name_piece_surname_prefix,
		 SURN => \&tag_name_piece_surname,
		);

} # End of tag_personal_name_piece_tags.

# --------------------------------------------------

sub tag_personal_name_pieces
{
	my($index, $line) = @_;
	my($id) = 'personal_name_pieces';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Individual');

	# Special case. $index not ++$index.

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 tag_personal_name_piece_tags
		 }
		);

} # End of tag_personal_name_pieces.

# --------------------------------------------------

sub tag_phone_number
{
	my($index, $line) = @_;
	my($id) = 'phone_number';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_phone_number.

# --------------------------------------------------

sub tag_phonetic_type
{
	my($index, $line) = @_;
	my($id) = 'phonetic_type';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_phonetic_type.

# --------------------------------------------------

sub tag_physical_description
{
	my($index, $line) = @_;
	my($id) = 'physical_description';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_physical_description.

# --------------------------------------------------

sub tag_place
{
	my($index, $line) = @_;
	my($id) = 'place';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Place');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 FORM => \&tag_place_hierarchy,
		 }
		);

} # End of tag_place.

# --------------------------------------------------

sub tag_place_hierarchy
{
	my($index, $line) = @_;
	my($id) = 'place_hierarchy';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Place');

	return ++$index;

} # End of tag_place_hierarchy.

# --------------------------------------------------

sub tag_place_latitude
{
	my($index, $line) = @_;
	my($id) = 'place_latitude';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Place');

	return ++$index;

} # End of tag_place_latitude.

# --------------------------------------------------

sub tag_place_living_ordinance
{
	my($index, $line) = @_;
	my($id) = 'place_living_ordinance';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Place');

	return ++$index;

} # End of tag_place_living_ordinance.

# --------------------------------------------------

sub tag_place_longitude
{
	my($index, $line) = @_;
	my($id) = 'place_longitude';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Place');

	return ++$index;

} # End of tag_place_longitude.

# --------------------------------------------------

sub tag_place_name
{
	my($index, $line) = @_;
	my($id) = 'place_name';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Place');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 FORM => \&tag_place_hierarchy,
			 FONE => \&tag_place_phonetic_variation,
			 MAP  => \&tag_map,
			 ROMN => \&tag_place_romanized_variation,
			 NOTE => \&tag_note_structure,
		 }
		);

} # End of tag_place_name.

# --------------------------------------------------

sub tag_place_phonetic_variation
{
	my($index, $line) = @_;
	my($id) = 'place_phonetic_variation';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Place');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 TYPE => \&tag_phonetic_type,
		 }
		);

} # End of tag_place_phonetic_variation.

# --------------------------------------------------

sub tag_place_romanized_variation
{
	my($index, $line) = @_;
	my($id) = 'place_romanized_variation';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Place');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 TYPE => \&tag_romanized_type,
		 }
		);

} # End of tag_place_romanized_variation.

# --------------------------------------------------

sub tag_possessions
{
	my($index, $line) = @_;
	my($id) = 'possessions';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_possessions.

# --------------------------------------------------

sub tag_publication_date
{
	my($index, $line) = @_;
	my($id) = 'publication_date';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_publication_date.

# --------------------------------------------------

sub tag_receiving_system_name
{
	my($index, $line) = @_;
	my($id) = 'receiving_system_name';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Header');

	return ++$index;

} # End of tag_receiving_system_name.

# --------------------------------------------------

sub tag_relation_is_descriptor
{
	my($index, $line) = @_;
	my($id) = 'relation_is_descriptor';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_relation_is_descriptor.

# --------------------------------------------------

sub tag_religious_affiliation
{
	my($index, $line) = @_;
	my($id) = 'religious_affiliation';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_religious_affiliation.

# --------------------------------------------------

sub tag_repository_record
{
	my($index, $line) = @_;
	my($id) = 'repository_record';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Repository');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 CHAN => \&tag_change_date1,
			 NAME => \&tag_name_of_repository,
			 NOTE => \&tag_note_structure,
			 REFN => \&tag_user_reference_number,
			 RIN  => \&tag_automated_record_id,
			 tag_address_structure_tags(),
		 }
		);

} # End of tag_repository_record.

# --------------------------------------------------

sub tag_responsible_agency
{
	my($index, $line) = @_;
	my($id) = 'responsible_agency';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Source');

	return ++$index;

} # End of tag_responsible_agency.

# --------------------------------------------------

sub tag_restriction_notice
{
	my($index, $line) = @_;
	my($id) = 'restriction_notice';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_restriction_notice.

# --------------------------------------------------

sub tag_rin
{
	my($index, $line) = @_;
	my($id) = 'rin';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_rin.

# --------------------------------------------------

sub tag_role_in_event
{
	my($index, $line) = @_;
	my($id) = 'role_in_event';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Source');

	return ++$index;

} # End of tag_role_in_event.

# --------------------------------------------------

sub tag_romanized_type
{
	my($index, $line) = @_;
	my($id) = 'romanized_type';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_romanized_type.

# --------------------------------------------------

sub tag_scholastic_achievement
{
	my($index, $line) = @_;
	my($id) = 'scholastic_achievement';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_scholastic_achievement.

# --------------------------------------------------

sub tag_sex_value
{
	my($index, $line) = @_;
	my($id) = 'sex_value';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_sex_value.

# --------------------------------------------------

sub tag_slgc
{
	my($index, $line) = @_;
	my($id) = 'slgc';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Individual');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 DATE => \&tag_date_lds_ord,
			 FAMC => \&tag_child_to_family_xref,
			 NOTE => \&tag_note_structure,
			 PLAC => \&tag_place_living_ordinance,
			 SOUR => \&tag_source_citation,
			 STAT => \&tag_lds_child_sealing_date_status,
			 TEMP => \&tag_temple_code,
		 }
		);

} # End of tag_slgc.

# --------------------------------------------------

sub tag_social_security_number
{
	my($index, $line) = @_;
	my($id) = 'social_security_number';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Individual');

	return ++$index;

} # End of tag_social_security_number.

# --------------------------------------------------

sub tag_source_call_number
{
	my($index, $line) = @_;
	my($id) = 'source_call_number';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Source');

	return ++$index;

} # End of tag_source_call_number.

# --------------------------------------------------

sub tag_source_citation
{
	my($index, $line) = @_;
	my($id) = 'source_citation';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Source');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 CONC => \&tag_concat,
			 CONT => \&tag_continue,
			 DATA => \&tag_source_citation_data,
			 EVEN => \&tag_event_type_cited_from,
			 OBJE => \&tag_multimedia_link,
			 NOTE => \&tag_note_structure,
			 PAGE => \&tag_where_within_source,
			 QUAY => \&tag_certainty_assessment,
			 TEXT => \&tag_text_from_source,
		 }
		);

} # End of tag_source_citation.

# --------------------------------------------------

sub tag_source_citation_data
{
	my($index, $line) = @_;
	my($id) = 'source_citation_data';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Source');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 DATE => \&tag_entry_recording_date,
			 TEXT => \&tag_text_from_source,
		 }
		);

} # End of tag_source_citation_data.

# --------------------------------------------------

sub tag_source_data
{
	my($index, $line) = @_;
	my($id) = 'source_data';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Source');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 AGNC => \&tag_responsible_agency,
			 EVEN => \&tag_events_recorded,
			 NOTE => \&tag_note_structure,
		 }
		);

} # End of tag_source_data.

# --------------------------------------------------

sub tag_source_descriptive_title
{
	my($index, $line) = @_;
	my($id) = 'source_descriptive_title';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Source');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 CONC => \&tag_concat,
			 CONT => \&tag_continue,
		 }
		);

} # End of tag_source_descriptive_title.

# --------------------------------------------------

sub tag_source_filed_by_entry
{
	my($index, $line) = @_;
	my($id) = 'source_filed_by_entry';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Source');

	return ++$index;

} # End of tag_source_filed_by_entry.

# --------------------------------------------------

sub tag_source_jurisdiction_place
{
	my($index, $line) = @_;
	my($id) = 'source_jurisdiction_place';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Source');

	return ++$index;

} # End of tag_source_jurisdiction_place.

# --------------------------------------------------

sub tag_source_media_type
{
	my($index, $line) = @_;
	my($id) = 'source_media_type';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Source');

	return ++$index;

} # End of tag_source_media_type.

# --------------------------------------------------

sub tag_source_originator
{
	my($index, $line) = @_;
	my($id) = 'source_originator';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Source');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 CONC => \&tag_concat,
			 CONT => \&tag_continue,
		 }
		);

} # End of tag_source_originator.

# --------------------------------------------------

sub tag_source_publication_date
{
	my($index, $line) = @_;
	my($id) = 'source_publication_date';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Source');

	return ++$index;

} # End of tag_source_publication_date.

# --------------------------------------------------

sub tag_source_publication_facts
{
	my($index, $line) = @_;
	my($id) = 'source_publication_facts';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Source');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 CONC => \&tag_concat,
			 CONT => \&tag_continue,
		 }
		);

} # End of tag_source_publication_facts.

# --------------------------------------------------

sub tag_source_record
{
	my($index, $line) = @_;
	my($id) = 'source_record';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Source');
	$myself -> push_item($$line[$index], 'Source');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 ABBR => \&tag_source_filed_by_entry,
			 AUTH => \&tag_source_originator,
			 CHAN => \&tag_change_date1,
			 DATA => \&tag_source_record_data,
			 NOTE => \&tag_note_structure,
			 OBJE => \&tag_multimedia_link,
			 PUBL => \&tag_source_publication_facts,
			 REFN => \&tag_user_reference_number,
			 RIN  => \&tag_automated_record_id,
			 REPO => \&tag_source_repository_citation,
			 TEXT => \&tag_text_from_source,
			 TITL => \&tag_source_descriptive_title,
		 }
		);

} # End of tag_source_record.

# --------------------------------------------------

sub tag_source_record_data
{
	my($index, $line) = @_;
	my($id) = 'source_record_data';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Source');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 AGNC => \&tag_responsible_agency,
			 EVEN => \&tag_events_recorded,
			 NOTE => \&tag_note_structure,
		 }
		);

} # End of tag_source_record_data.

# --------------------------------------------------

sub tag_spouse_to_family_link
{
	my($index, $line) = @_;
	my($id) = 'spouse_to_family_link';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Link to FAM');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 NOTE => \&tag_note_structure,
		 }
		);

} # End of tag_spouse_to_family_link.

# --------------------------------------------------

sub tag_submission_record
{
	my($index, $line) = @_;
	my($id) = 'submission_record';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Link to SUBM');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 ANCE => \&tag_generations_of_ancestors,
			 DESC => \&tag_generations_of_descendants,
			 FAMF => \&tag_name_of_family_file,
			 ORDI => \&tag_ordinance_process_flag,
			 NOTE => \&tag_note_structure,
			 RIN  => \&tag_rin,
			 SUBM => \&tag_submitter_xref,
			 TEMP => \&tag_temple_code,
		 }
		);

} # End of tag_submission_record.

# --------------------------------------------------

sub tag_submission_repository_citation
{
	my($index, $line) = @_;
	my($id) = 'submission_repository_citation';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Submission');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 CALN => \&tag_source_call_number,
			 MEDI => \&tag_source_media_type,
			 NOTE => \&tag_note_structure,
		 }
		);

} # End of tag_submission_repository_citation.

# --------------------------------------------------

sub tag_submission_xref
{
	my($index, $line) = @_;
	my($id) = 'submission_xref';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Submission');

	return ++$index;

} # End of tag_submission_xref.

# --------------------------------------------------

sub tag_submitter_record
{
	my($index, $line) = @_;
	my($id) = 'submitter_record';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Submitter');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 CHAN => \&tag_change_date1,
			 LANG => \&tag_language_preference,
			 NAME => \&tag_submitter_name,
			 NOTE => \&tag_note_structure,
			 OBJE => \&tag_multimedia_link,
			 RFN  => \&tag_submitter_registered_rfn,
			 RIN  => \&tag_rin,
			 tag_address_structure_tags(),
		 }
		);

} # End of tag_submitter_record.

# --------------------------------------------------

sub tag_submitter_registered_rfn
{
	my($index, $line) = @_;
	my($id) = 'submitter_registered_rfn';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Submitter');

	return ++$index;

} # End of tag_rfn.

# --------------------------------------------------

sub tag_submitter_name
{
	my($index, $line) = @_;
	my($id) = 'submitter_name';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Submission');

	return ++$index;

} # End of tag_submitter_name.

# --------------------------------------------------

sub tag_submitter_xref
{
	my($index, $line) = @_;
	my($id) = 'submitter_xref';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Submission');

	return ++$index;

} # End of tag_submitter_xref.

# --------------------------------------------------

sub tag_temple_code
{
	my($index, $line) = @_;
	my($id) = 'temple_code';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_temple_code.

# --------------------------------------------------

sub tag_text_from_source
{
	my($index, $line) = @_;
	my($id) = 'text_from_source';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 CONC => \&tag_concat,
			 CONT => \&tag_continue,
		 }
		);

} # End of tag_text_from_source.

# --------------------------------------------------

sub tag_time_value
{
	my($index, $line) = @_;
	my($id) = 'time_value';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_time_value.

# --------------------------------------------------

sub tag_trailer
{
	my($index, $line) = @_;
	my($id) = 'trailer';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Trailer');
	$myself -> log(warning => "Line: $$line[$index][0]. The unknown tag $$line[$index][3] was detected") if ($$line[$index][3] ne 'TRLR');

	return ++$index;

} # End of tag_trailer.

# --------------------------------------------------

sub tag_transmission_date
{
	my($index, $line) = @_;
	my($id) = 'transmission_date';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Header');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 TIME => \&tag_time_value,
		 }
		);

} # End of tag_transmission_date.

# --------------------------------------------------

sub tag_user_reference_number
{
	my($index, $line) = @_;
	my($id) = 'user_reference_number';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return tag_advance
		(
		 $id,
		 ++$index,
		 $line,
		 {
			 TYPE => \&tag_user_reference_type,
		 }
		);

} # End of tag_user_reference_number.

# --------------------------------------------------

sub tag_user_reference_type
{
	my($index, $line) = @_;
	my($id) = 'user_reference_type';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_user_reference_type.

# --------------------------------------------------

sub tag_version_number
{
	my($index, $line) = @_;
	my($id) = 'version_number';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], '');

	return ++$index;

} # End of tag_version_number.

# --------------------------------------------------

sub tag_where_within_source
{
	my($index, $line) = @_;
	my($id) = 'where_within_source';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> check_length($id, $$line[$index]);
	$myself -> push_item($$line[$index], 'Source');

	return ++$index;

} # End of tag_page.

# --------------------------------------------------

sub tag_wife_xref
{
	my($index, $line) = @_;
	my($id) = 'wife_xref';

	$myself -> log(debug => "tag_$id($$line[$index][0], '$$line[$index][5]')");
	$myself -> push_item($$line[$index], 'Link to INDI');

	return ++$index;

} # End of tag_wife_xref.

# --------------------------------------------------

1;

=pod

=head1 NAME

L<Genealogy::Gedcom::Reader::Lexer> - An OS-independent lexer for GEDCOM data

=head1 Synopsis

Run scripts/lex.pl -help.

A typical run would be:

perl -Ilib scripts/lex.pl -i data/royal.ged -report_items 1 -strict 1

Turn on debugging (extra logging) with:

perl -Ilib scripts/lex.pl -i data/royal.ged -report_items 1 -strict 1 -max debug

royal.ged was downloaded from L<http://www.vjet.f2s.com/ftree/download.html>. It's more up-to-date than the one shipped with L<Gedcom>.

Various sample GEDCOM files may be found in the data/ directory in the distro.

=head1 Description

L<Genealogy::Gedcom::Reader::Lexer> provides a lexer for GEDCOM data.

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

C<new()> is called as C<< my($lexer) = Genealogy::Gedcom::Reader::Lexer -> new(k1 => v1, k2 => v2, ...) >>.

It returns a new object of type C<Genealogy::Gedcom::Reader::Lexer>.

Key-value pairs accepted in the parameter list (see corresponding methods for details [e.g. input_file()]):

=over 4

=item o input_file => $gedcom_file_name

Read the GEDCOM data from this file.

Default: ''.

=item o logger => $logger_object

Specify a logger object.

To disable logging, just set logger to the empty string.

Default: An object of type L<Log::Handler>.

=item o maxlevel => $level

This option is only used if the lexer creates an object of type L<Log::Handler>. See L<Log::Handler::Levels>.

Default: 'info'.

Log levels are, from highest (i.e. most output) to lowest: 'debug', 'info', 'warning', 'error'. No lower levels are used.

=item o minlevel => $level

This option is only used if the lexer creates an object of type L<Log::Handler>. See L<Log::Handler::Levels>.

Default: 'error'.

=item o report_items => $Boolean

=over 4

=item o 0 => Report nothing

=item o 1 => Call L</report()> to report, via the log, the items recognized by the lexer

This output is at log level 'info'.

=back

Default: 0.

=item o strict => $Boolean

Specifies lax or strict string length checking during validation.

=over 4

=item o 0 => String lengths can be 0, allowing blank NOTE etc records.

=item o 1 => String lengths must be > 0, as per L<the GEDCOM Specification Ged551-5.pdf|http://wiki.webtrees.net/File:Ged551-5.pdf>.

Note: A string of length 1 - e.g. '0' - might still be an error.

=back

Default: 0.

The upper lengths on strings are always as per L<the GEDCOM Specification Ged551-5.pdf|http://wiki.webtrees.net/File:Ged551-5.pdf>.
See L</get_max_length($key, $line)> for details.

String lengths out of range (as with all validation failures) are reported as log messages at level 'warning'.

=back

=head1 Methods

=head2 check_length($key, $line)

Checks the length of the data component (after the tag) on the given input $line.

$key identifies what type of record the $line is expected to be.

=head2 get_gedcom_from_file()

If the caller has requested GEDCOM data be read from a file, with the input_file option to new(), this method reads that file.

Called as appropriate by L</run()>, if you do not suppy data with L</gedcom_data([$gedcom_data])>.

=head2 gedcom_data([$gedcom_data])

The [] indicate an optional parameter.

Get or set the arrayref of GEDCOM records to be processed.

This is normally only used internally, but can be used to bypass reading from a file.

Note: If supplying data this way rather than via the file, you must strip newlines etc on every line, as well as leading and trailing blanks.

=head2 get_max_length($key, $line)

Get the maximum string length of the data component (after the tag) on the given $line.

$key identifies what type of record the $line is expected to be.

=head2 get_min_length($key, $line)

Get the minimum string length of the data component (after the tag) on the given $line.

Currently, this value is actually the value of strict(), i.e. 0 or 1.

$key identifies what type of record the $line is expected to be.

=head2 input_file([$gedcom_file_name])

Here, the [] indicate an optional parameter.

Get or set the name of the file to read the GEDCOM data from.

=head2 items()

Returns a object of type L<Set::Array>, which is an arrayref of items output by the lexer.

See the L</FAQ> for details.

=head2 log($level, $s)

Calls $self -> logger -> $level($s).

=head2 logger([$logger_object])

Here, the [] indicate an optional parameter.

Get or set the logger object.

To disable logging, just set logger to the empty string.

=head2 maxlevel([$string])

Here, the [] indicate an optional parameter.

Get or set the value used by the logger object.

This option is only used if the lexer creates an object of type L<Log::Handler>. See L<Log::Handler::Levels>.

=head2 minlevel([$string])

Here, the [] indicate an optional parameter.

Get or set the value used by the logger object.

This option is only used if the lexer creates an object of type L<Log::Handler>. See L<Log::Handler::Levels>.

=head2 push_item($line, $type)

Pushes a hashref of components of the $line, with type $type, onto the arrayref of items returned by L</items()>.

See the L</FAQ> for details.

=head2 report()

Report, via the log, the list of items recognized by the lexer.

=head2 report_items([0 or 1])

The [] indicate an optional parameter.

Get or set the value which determines whether or not to report the items recognised by the lexer.

=head2 run()

This is the only method the caller needs to call. All parameters are supplied to new(), or via previous calls to various methods.

Returns 0 for success and 1 for failure.

=head2 strict([0 or 1])

The [] indicate an optional parameter.

Get or set the value which determines whether or not to use 0 or 1 as the minimum string length.

=head1 FAQ

=head2 How are user-defined tags handled?

In the same way as GEDCOM tags.

They are defined by having a leading '_', as well as same syntax as GEDCOM files. That is:

=over 4

=item o At level 0, they match /(_?(?:[A-Z]{3,4}))/.

=item o At level > 0, they match /(_?(?:ADR[123]|[A-Z]{3,5}))/.

=back

Each user-defined tag is stand-alone, meaning they can't be extended with CONC or CONT tags in the way some GEDCOM tags can.

See data/sample.4.ged.

=head2 How are CONC and CONT tags handled?

Nothing is done with them, meaning e.g. text flowing from a NOTE (say) onto a CONC or CONT is not concatenated.

Currently then, even GEDCOM tags are stand-alone.

=head2 How is the lexed data stored in RAM?

Items are stored in an arrayref. This arrayref is available via the L</items()> method.

This method returns the same data as does L<Genealogy::Gedcom::Reader/items()>.

Each element in the array is a hashref of the form:

	{
	count      => $n,
	data       => $a_string
	level      => $n,
	line_count => $n,
	tag        => $a_tag,
	type       => $a_string,
	xref       => $a_string,
	}

Key-value pairs are:

=over 4

=item o count => $n

Items are numbered from 1 up, so this is the array index + 1.

Note: Blank lines in the input file are skipped.

=item o data => $a_string

This is any data associated with the tag.

Given the GEDCOM record:

	1   NAME Given Name /Surname/

then data will be 'Given Name /Surname/', i.e. the text after the tag.

Given the GEDCOM record:

	1   SUBM @SUBM1@

then data will be 'SUBM1'.

As with xref (below), the '@' characters are stripped.

=item o level => $n

The is the level from the GEDCOM data.

=item o line_count => $n

This is the line number from the GEDCOM data.

=item o tag => $a_tag

This is the GEDCOM tag.

=item o type => $a_string

This is a string indicating what broad class the tag refers to. Values:

=over 4

=item o (Empty string)

Used for various cases.

=item o Address

=item o Concat

=item o Continue

=item o Event

=item o Family

=item o File name

=item o Header

=item o Individual

=item o Link to FAM

=item o Link to INDI

=item o Link to OBJE

=item o Link to SUBM

=item o Multimedia

=item o Note

=item o Place

=item o Repository

=item o Source

=item o Submission

=item o Submitter

=item o Trailer

=back

=item o xref => $a_string

Given the GEDCOM record:

	0 @I82@ INDI

then xref will be 'I82'.

As with data (above), the '@' characters are stripped.

=back

=head2 What validation is performed?

There is no perfect answer as to what should be a warning and what should be an error.

So, the author's philosophy is that unrecoverable states are errors, and the code calls 'die'. See L</Under what circumstances does the code call 'die'?>.

And, the log level 'error' is not used. All validation failures are logged at level warning, leaving interpretation up to the user. See L</How does logging work?>.

Details:

=over 4

=item o Cross-references

Xrefs (pointers) are checked that they point to an xref which exists. Each dangling xref is only reported once.

=item o Duplicate xrefs

Xrefs which are (potentially) pointed to are checked for uniqueness.

=item o String lengths

Maximum string lengths are checked as per L<the GEDCOM Specification Ged551-5.pdf|http://wiki.webtrees.net/File:Ged551-5.pdf>.

Minimum string lengths are checked as per the value of the 'strict' option to L<new()|Constructor and Initialization>.

=item o Strict 'v' Mandatory

Validation is mandatory, even with the 'strict' option set to 0. 'strict' only affects the minimum string length acceptable.

=item o Tag nesting

Tag nesting is validated by the mechanism of nested function calls, with each function knowing what tags it handles, and with each nested call handling its own tags.

This process starts with the call to tag_lineage(0, $line) in method L</run()>.

=item o Unexpected tags

The lexer reports the first unexpected tag, meaning it is not a GEDCOM tag and it does not start with '_'.

=back

All validation failures are reported as log messages at level 'warning'.

=head2 What other validation is planned?

Here are some suggestions from L<the mailing list|The Gedcom Mailing List>:

=over 4

=item o Date checks and more date checks

=item o Mandatory sub-tags

This means check that each tag has all its mandatory sub-tags.

=item o Natural (not step-) parent must be older than child

=item o Prior art

L<http://www.tamurajones.net/GEDCOMValidation.xhtml>.

=item o Specific values for data attached to tags

Many such checks are possible. E.g. Attribute type (p 43 of L<GEDCOM Specification|http://wiki.webtrees.net/File:Ged551-5.pdf>) must be one of:
CAST | EDUC | NATI | OCCU | PROP | RELI | RESI | TITL | FACT.

=back

=head2 What other features are planned?

Here are some suggestions from L<the mailing list|The Gedcom Mailing List>:

=over 4

=item o Persistent IDs for individuals

L<A proposal re UUIDs|http://savage.net.au/Perl-modules/html/genealogy/uuid.html>.

=back

=head2 How does logging work?

=over 4

=item o Debugging

When new() is called as new(maxlevel => 'debug'), each function entry is logged at level 'debug'.

This has the effect of tracing all code which processes tags, since this is done with function calls. Method calls are not traced.

Since the default value of 'maxlevel' is 'info', all this output is suppressed by default. Such output is mainly for the author's benefit.

=item o Log levels

Log levels are, from highest (i.e. most output) to lowest: 'debug', 'info', 'warning', 'error'. No lower levels are used. See L<Log::Handler::Levels>.

'maxlevel' defaults to 'info' and 'minlevel' defaults to 'error'. In this way, levels 'info' and 'warning' are reported by default.

Currently, level 'error' is not used. Fatal errors cause 'die' to be called, since they are unrecoverable. See L</Under what circumstances does the code call 'die'?>.

=item o Reporting

When new() is called as new(report_items => 1), the items are logged at level 'info'.

=item o  Validation failures

These are reported at level 'warning'.

=back

=head2 Under what circumstances does the code call 'die'?

=over 4

=item o When there is a typo in the field name passed in to check_length()

This is a programming error.

=item o When an input file is not specified

This is a user (run time) error.

=item o When there is a syntax error in a GEDCOM record

This is a user (data preparation) error.

=back

=head2 Why did you use functions and not methods in all the jump tables?

Because of the effort of taking references to methods.

A function can be used as \&tag_x, but the equivalent usage of a method requires sub{$self -> tag_x}. Even if the Perl compiler optimizes away all the sub calls, what's the gain?

=head2 How do I change the version of the GEDCOM grammar supported?

Errr, by changing the source code - unfortunately.

=head2 What file charsets are supported?

ASCII - i.e. nothing else has been tested.

The code should really ought to support ANSEL (a superset of ASCII), ASCII, UTF-8 and UTF-16 (known to GEDCOM as UNICODE).

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
