use ExtUtils::MakeMaker;

WriteMakefile(NAME         => 'Mojolicious::Plugin::DomIdHelper',
	      AUTHOR       => 'Skye Shaw <sshaw AT lucas.cis.temple.edu>',
	      ABSTRACT     => 'Mojolicious plugin to generate DOM IDs from your ORM objects',
	      VERSION_FROM => 'lib/Mojolicious/Plugin/DomIdHelper.pm',
	      PREREQ_PM    => { Mojolicious => 0 });
