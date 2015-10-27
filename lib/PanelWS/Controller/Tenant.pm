package PanelWS::Controller::Tenant;
use Mojo::Base 'Mojolicious::Controller';


use PanelWS::Util;

use Data::Dumper;


sub add {

  my ( $self, $app, $tx, $uuid );

  $self = shift;
  $app  = $self->app;
  $tx   = $self->tx;

  return $self->nok("invalid tenant name")          unless $tx->req->param('name') =~ /^[a-z0-9_-]+$/;
  return $self->nok("tenant name already exists")   if $self->tenant->get_by_name($tx->req->param('name'));
  return $self->nok("internal error")               unless $uuid = NewUUID($self);

  $self->tenant->add($uuid, $tx->req->param('name'));

  return $self->ok("Ok");
}

sub list {

  my ( $self, $app, $tx, $json );

  $self = shift;

  $app  = $self->app;
  $tx   = $self->tx;
  $json = $tx->req->json;

  return $self->render( json => $self->tenant->list() );
}

sub get {

  my ( $self, $app, $tx, $json );

  $self = shift;

  return $self->render( json => $self->serverpool->get(1, $self->stash('name')));
}

#============================================================
#
#============================================================
sub NewUUID {

  my ( $self, $uuid );

  $self = shift;

  $uuid = PanelWS::Util::NewUUID();

  while ( (my $User = $self->tenant->get_by_id($uuid)) ) {
    sleep(1);

    if ( ref($User) eq 'HASH' ) {
      $uuid = PanelWS::Util::NewUUID();
    } else {
      $self->log->error("Failure generating new uuid");
      return;
    }
  }

  return($uuid);
}


1;
