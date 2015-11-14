use ExtUtils::MakeMaker;

# ----------------

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my(%params) =
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
		'File::Slurper' => 0.008,
		'Genealogy::Gedcom::Date' => 2.01,
		'Getopt::Long' => 0,
		'Log::Handler' => 0.84,
		'Moo' => 2.000002,
		'Pod::Usage' => 0,
		'Set::Array' => 0.30,
		'strict' => 0,
		'Test::Stream' => 1.302026,
		'Test::Pod' => 1.48,
		'warnings' => 0,
	},
	VERSION_FROM => 'lib/Genealogy/Gedcom.pm',
);

if ( ($ExtUtils::MakeMaker::VERSION =~ /^\d\.\d\d$/) && ($ExtUtils::MakeMaker::VERSION > 6.30) )
{
	$params{LICENSE} = 'artistic_2';
}

if ($ExtUtils::MakeMaker::VERSION ge '6.46')
{
	$params{META_MERGE} =
	{
		'meta-spec' =>
		{
			'version' => 2,
		},
		resources   =>
		{
			'bugtracker' => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Genealogy-Gedcom',
			'license'    => 'http://opensource.org/licenses/Artistic-2.0',
			repository   =>
			{
				'type' => 'git',
				'url'  => 'https://github.com/ronsavage/Genealogy-Gedcom.git',
				'web'  => 'https://github.com/ronsavage/Genealogy-Gedcom',
			},
		},
	};
}

WriteMakefile(%params);
