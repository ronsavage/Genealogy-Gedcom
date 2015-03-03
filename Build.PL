use warnings;
use strict;

use Module::Build;

Module::Build -> new
(
	module_name    => 'Genealogy::Gedcom',
	license        => 'artistic_2',
	dist_abstract  => 'An OS-independent processor for GEDCOM data',
	dist_author    => 'Ron Savage <ron@savage.net.au>',
	build_requires =>
	{
		'Test::More' => 1.001014,
		'Test::Pod' => 1.48,
	},
	configure_requires =>
	{
		'Module::Build' => 0.4211,
	},
	requires =>
	{
		'DateTime' => 1.03,
		'DateTime::Infinite' => 1.03,
		'Genealogy::Gedcom::Date' => 1.08,
		'Getopt::Long' => 2.38,
		'Hash::FieldHash' => 0.14,
		'Log::Handler' => 0.78,
		'Perl6::Slurp' => 0.051003,
		'Pod::Usage' => 1.36,
		'Set::Array' => 0.28,
		'strict' => 0,
		'warnings' => 0,
	},
) -> create_build_script();
