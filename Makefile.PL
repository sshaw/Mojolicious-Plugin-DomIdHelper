use ExtUtils::MakeMaker;

WriteMakefile(NAME         => 'Mojolicious::Plugin::DomIdHelper',
	      AUTHOR       => 'Skye Shaw <sshaw AT lucas.cis.temple.edu>',
	      ABSTRACT     => 'Mojolicious plugin to generate DOM IDs and CSS class names from your ORM objects',
	      VERSION_FROM => 'lib/Mojolicious/Plugin/DomIdHelper.pm',
	      PREREQ_PM    => { Mojolicious => 0 });

# Create README.pod for a repo's GitHub page. Unlike CPAN, GitHub won't 
# display the module's POD, it looks for a README.*
sub MY::postamble
{
  my $self = shift;
  return if -r 'README' or ! -r $self->{VERSION_FROM};
  return<<END_MAKE;
README.pod: $self->{VERSION_FROM}
	\@perldoc -uT $self->{VERSION_FROM} > README.pod
END_MAKE
}
