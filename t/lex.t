use strict;
use warnings;

use Test::More tests => 2;

# -----------------------------------------------

sub BEGIN { use_ok('Genealogy::Gedcom::Reader::Lexer'); }

# ------------------------------------------------

my($file_name) = 'data/sample.4.ged';
my($lexer)     = Genealogy::Gedcom::Reader::Lexer -> new
	(
	 input_file   => $file_name,
	 logger       => '',
	 report_items => 0,
	 strict       => 1,
	);

my($result)     = $lexer -> run;
my(@item)       = @{$lexer -> items};
my($item_count) = 51;

ok(scalar @item == $item_count, "$file_name really does contain $item_count items");
