package Mojolicious::Plugin::DomIdHelper;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Util qw{xml_escape};
use Scalar::Util qw{blessed};

our $VERSION = '0.03';

# Method used to retrieve the object's PK
my $METHOD = 'id';

# Character used to delimitthe package name from object's PK
my $DELIMITER = '_';

# Keep the full package name when generating the DOM ID, false = strip.
my $KEEP_NAMESPACE = 0;

# If available we'll pluralize the package name when an array is used
my $HAVE_INFLECT = eval "require Lingua::EN::Inflect; 1";  

sub register 
{
    my ($self, $app, $defaults) = @_;

    $defaults ||= {};
    $defaults->{method} ||= $METHOD;
    $defaults->{delimiter} ||= $DELIMITER;
    $defaults->{keep_namespace} ||= $KEEP_NAMESPACE;
       
    $app->helper( 
	dom_id => sub {
	    my $c      = shift;
	    my $obj    = shift;
	    my %config = (%$defaults, @_);
	    my $dom_id = $self->_generate_dom_id($obj, %config);

	    xml_escape($dom_id);
	    $dom_id;
    });

    $app->helper( 		 
	dom_class => sub { 
	    my $c      = shift;
	    my $obj    = shift;
	    my %config = (%$defaults, @_);	    
	    my $dom_class = $self->_generate_dom_class($obj, %config);

	    xml_escape($dom_class);
	    $dom_class;
    });		
}

sub _generate_dom_id
{
    my ($self, $obj, %config) = @_;
    my $methods   = $config{method}; 
    my $delimiter = $config{delimiter};

    my $dom_id = $self->_generate_dom_class($obj, %config);		
    return unless $dom_id;

    # Append the ID suffix to blessed() refs only, others can't receive methods calls.
    if(blessed($obj)) {       
	if(ref($methods) ne 'ARRAY') {
	    $methods = [$methods];
	}
	
	my @suffix;
	for my $method (@$methods) {
	    push @suffix, $obj->$method;
	}
	
	local $_;
	@suffix = grep defined, @suffix;

	if(@suffix) {
	    $dom_id .= $delimiter;
	    $dom_id .= join '', @suffix;
            $dom_id =~ s/\s+/$delimiter/g;
	}
    }

    $dom_id;
}

sub _generate_dom_class
{
    my ($self, $obj, %config) = @_;
    my $type = $self->_instance_name($obj);
    return unless $type;

    my @namespace = split /\b::\b/, $type; 
    my $delimiter = $config{delimiter};

    # Do we want to strip the prefix from the package name
    if(!$config{keep_namespace} && @namespace > 1) {
	@namespace = pop @namespace;
    }
 
    # Split the package name on camelcase bounderies
    local $_;    
    my $dom_class = join $delimiter, map {
	s/([^A-Z])([A-Z])/$1$delimiter$2/g;
	s/([A-Z])([A-Z][^A-Z])/$1$delimiter$2/g;
	lc;
    } @namespace;    
    
    $dom_class;
}

sub _instance_name
{
    my ($self, $obj) = @_;
    my $type = ref $obj;
    
    if($type && $HAVE_INFLECT && $type eq 'ARRAY' && blessed($obj->[0])) {
	$type = Lingua::EN::Inflect::PL(ref $obj->[0]) 
    }
   
    $type;
}

1;

__END__
=head1 NAME

Mojolicious::Plugin::DomIdHelper - Mojolicious plugin to generate DOM IDs and CSS class names from your ORM objects

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('dom_id_helper');

  # Or, your defaults
  $self->plugin('dom_id_helper', delimiter => '-')

  # Mojolicious::Lite   
  plugin 'dom_id_helper';

  # Set defaults 
  plugin 'dom_id_helper', delimiter => '-'

  # Your view
  <div id="<%= dom_id($object) %>" class="<%= dom_class($object) %>">
    ...
  </div>

  <div id="<%= dom_id($object, method => 'name') ) %>">
    ...
  </div>

=head1 DESCRIPTION

DOM IDs are generated by joining an object's package name and its primary key with the character 
specified by the L</delimiter> option. By default the primary key is retrieved via a method 
named C<id>. This can be modified, see L</OPTIONS>.

By default, given an instance of C<DB::Package::User> with an ID of C<1>:

  dom_id($user)
  dom_class($user)

will generate:

  user_1 
  user

For C<dom_id>, if the primary key is undefined only the package name is returned. 
If C<$user> is not a reference C<undef> is returned.

Multi-column primary keys are not separated by the L</delimiter> option, they are concatenated.

For references that aren't blessed C<dom_id> and C<dom_class> return the reference type. 
If Lingua::EN::Inflect is installed array references that contain a blessed reference will return 
the pluralized form of the blessed reference. 

For example, if Lingua::EN::Inflect is installed:

  dom_id([$user])
  dom_class([$user])
  dom_id([])
  dom_id({ user => $user })
  dom_id({})
  
will generate:
  
  users
  users
  array
  hash
  hash
  
If Lingua::EN::Inflect is not installed C<dom_id([$user])> will return C<array>.

=head1 ORMs

The aim is to be ORM agnostic. Just set the L</method> option to the name of the method used to 
retrieve your object's primary key.

Multi-column primary keys returned as array references will cause problems (for now). 

=head1 OPTIONS

=head2 C<delimiter>

  plugin 'dom_id_helper', delimiter => '-'

The character used to delimit the object's package name from its primary key. Defaults to C<'_'>.

=head2 C<method>

  plugin 'dom_id_helper', method => 'name'
  plugin 'dom_id_helper', method => [qw{first_name last_name}]

The method used to retrieve the object's primary key. Defaults to C<'id'>.

=head2 C<keep_namespace>

  plugin 'dom_id_helper', keep_namespace => 1

Keep the full package name when generating the DOM ID. Defaults to C<0> (false).

=head1 AUTHOR

Skye Shaw <sshaw AT lucas.cis.temple.edu>

=head1 SEE ALSO

L<Mojolicious> and L<Mojolicious::Plugin::TagHelpers>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

