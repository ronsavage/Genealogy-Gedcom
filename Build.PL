use Module::Build;

Module::Build -> new
(
 module_name    => 'Genealogy::Gedcom',
 license        => 'artistic_2',
 dist_abstract  => 'An OS-independent processor for GEDCOM data',
 dist_author    => 'Ron Savage <ron@savage.net.au>',
 build_requires =>
 {
 	 Test::More => 0.94,
 	 Test::Pod  => 1.44,
 },
 configure_requires =>
 {
 	 Module::Build => 0.3800,
 },
 requires =>
 {
	 DateTime                => 0.70,
	 DateTime::Infinite      => 0.70,
	 Genealogy::Gedcom::Date => 1.00,
	 Getopt::Long            => 2.38,
	 Hash::FieldHash         => 0.10,
	 Log::Handler            => 0.71,
	 Perl6::Slurp            => 0.03,
	 Pod::Usage              => 1.36,
	 Set::Array              => 0.23,
 },
) -> create_build_script();
