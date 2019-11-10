use ExtUtils::MakeMaker;

WriteMakefile(NAME          => 'Mojolicious::Plugin::DomIdHelper',
	      AUTHOR        => 'Skye Shaw <sshaw AT lucas.cis.temple.edu>',
	      PREREQ_PM     => { Mojolicious => '2.20' },
	      LICENSE 	    => 'perl',
	      VERSION_FROM  => 'lib/Mojolicious/Plugin/DomIdHelper.pm',
	      ABSTRACT_FROM => 'lib/Mojolicious/Plugin/DomIdHelper.pm',
	     (eval { ExtUtils::MakeMaker->VERSION(6.46) } ?
		(META_MERGE  => { resources => { bugtracker => 'http://github.com/sshaw/Mojolicious-Plugin-DomIdHelper/issues',
                                                 repository => 'http://github.com/sshaw/Mojolicious-Plugin-DomIdHelper'} }) : ())

# Create README.pod for a repo's GitHub page. Unlike CPAN, GitHub won't
# display the module's POD, it looks for a README.*
use Config;
sub MY::postamble
{
  my $self = shift;
  return if -r 'README' or ! -r $self->{VERSION_FROM};
  return<<END_MAKE;
README.pod: $self->{VERSION_FROM}
	\@$Config{bin}/perldoc -uT $self->{VERSION_FROM} > README.pod
END_MAKE
}
