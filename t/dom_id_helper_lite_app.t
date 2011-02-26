package DB::Package::User;

sub new 
{  
    my $class = shift;
    bless { 
	id   => shift,
	name => shift
    }, $class; 
} 

sub id   { (shift)->{id} }
sub name { (shift)->{name} }

# Multi column PK
sub primary_key
{ 
    my $self = shift;
    return ($self->id, $self->name);
}

package main;

use Mojolicious::Lite;
use Test::More tests => 6;
use Test::Mojo;

my $user = DB::Package::User->new(1,'sshaw');

get '/plugin_defaults' => sub {
    plugin 'dom_id_helper'; 

    my $self = shift;
    $self->render('plugin_defaults', user => $user);
};

get '/plugin_overrides' => sub {
   plugin 'dom_id_helper', keep_namespace => 1, delimiter => '-', method => 'primary_key';
   
   my $self = shift;
   $self->render('plugin_overrides', user => $user);
};


my $t = Test::Mojo->new;
$t->get_ok('/plugin_defaults')->status_is(200)->content_is(<<END_HTML);
<div id="user_1"></div>
<div id="array"></div>
<div id="user*1"></div>
<div id="user_sshaw"></div>
<div id="db-package-user-1sshaw"></div>
END_HTML


$t->get_ok('/plugin_overrides')->status_is(200)->content_is(<<END_HTML);
<div id="db-package-user-1sshaw"></div>
END_HTML


__DATA__

@@ plugin_defaults.html.ep
<div id="<%= dom_id($user) %>"></div>
<div id="<%= dom_id([]) %>"></div>
<div id="<%= dom_id($user, delimiter => '*') %>"></div>
<div id="<%= dom_id($user, method => 'name') %>"></div>
<div id="<%= dom_id($user, method => [qw{id name}], delimiter => '-', keep_namespace => 1) %>"></div>


@@ plugin_overrides.html.ep
<div id="<%= dom_id($user) %>"></div>