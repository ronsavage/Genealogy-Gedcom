use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
	($] ge '5.005') ?
	(
		AUTHOR   => 'Ron Savage (ron@savage.net.au)',
		ABSTRACT => 'An OS-independent processor for GEDCOM data',
	) : (),
	clean =>
	{
		FILES => 'blib/* Makefile MANIFEST Genealogy-Gedcom-*'
	},
	dist =>
	{
		COMPRESS => 'gzip',
		SUFFIX   => 'gz'
	},
	DISTNAME  => 'Genealogy-Gedcom',
	NAME      => 'Genealogy::Gedcom',
	LICENSE   => 'artistic_2',
	PL_FILES  => {},
	PREREQ_PM =>
	{
		DateTime                => 0.70,
		DateTime::Infinite      => 0.70,
		Genealogy::Gedcom::Date => 1.08,
		Getopt::Long            => 2.38,
		Hash::FieldHash         => 0.14,
		Log::Handler            => 0.78,
		Perl6::Slurp            => 0.051003,
		Pod::Usage              => 1.36,
		Set::Array              => 0.28,
		strict                  => 0,
		Test::More              => 0.98,
#		Test::Pod               => 1.45, # Make it optional. See t/pod.t
		warnings                => 0,
	},
	VERSION_FROM => 'lib/Genealogy/Gedcom.pm',
);
