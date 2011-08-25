#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 10;

# -----------------------------------------------

sub BEGIN { use_ok('Genealogy::Gedcom::Reader::Lexer'); }

# ------------------------------------------------

my($lexer) = Genealogy::Gedcom::Reader::Lexer -> new
	(
	 input_file   => 'data/sample.4.ged',
	 logger       => '',
	 report_items => 0,
	 strict       => 1,
	);

my($result) = $lexer -> run;
my(@item)   = @{$lexer -> items};

print "Item count: ", scalar @item, "\n";
