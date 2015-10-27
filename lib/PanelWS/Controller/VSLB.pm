package PanelWS::Controller::VSLB;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use PanelWS::Util;


sub add {

  my ( $self, $app, $tx, $uuid );

  $self = shift;
  $app  = $self->app;
  $tx   = $self->tx;


  # Valid name
  unless ( $self->param('name') =~ /^[a-z0-9_-]+$/ ) {
    return $self->nok($self->config->{msgs}->{InternalError});
  }

  # Generate new user id
  unless ( $uuid = NewUUID($self) ) {
    return $self->nok($self->config->{msgs}->{InternalError});
  }

  if ( $self->tenant->get_by_name($tx->req->param('name')) ) {
    return $self->nok("vslb name already exists")
  }

  # Insert user into database
  unless ( $self->vslb->add($uuid, $self->param('name'), PanelWS::Util::uuid_string_to_bin('CE334B60-7C44-11E5-84CD-E03CD5576268')) ) {
    return $self->nok($self->config->{msgs}->{InternalError});
  }

  return $self->render( json => { tenant_id => 'CE334B60-7C44-11E5-84CD-E03CD5576268', vlsb_id =>  PanelWS::Util::uuid_bin_to_string($uuid)});

  return $self->ok({ tenant_id => 'CE334B60-7C44-11E5-84CD-E03CD5576268', vlsb_id =>  PanelWS::Util::uuid_bin_to_string($uuid)});
}

sub change {

  my ( $self, $app, $tx, $json );

  $self = shift;

  $app  = $self->app;
  $tx   = $self->tx;
  $json = $tx->req->json;

  return $self->ok("not implemented");
}

sub list {
  my ( $self, $app, $tx, $json );

  $self = shift;
  $app  = $self->app;
  $tx   = $self->tx;

  unless ( $self->stash('tenant_id') ) {

  }
  return $self->render($self->vslb->list());
}

sub get {

  my ( $self );

  $self = shift;

  $self->app->log->debug(Dumper($self->vslb->get($self->stash('tenant_id'), $self->stash('vslb_id'))));

  #$app->log->debug($self->stash('name'));
  return $self->render( json => $self->vslb->get($self->stash('tenant_id'), $self->stash('vslb_id')));
}


#============================================================
#
#============================================================
sub NewUUID {

  my ( $self, $uuid );

  $self = shift;

  $uuid = PanelWS::Util::NewUUID();

  while ( (my $User = $self->vslb->get_by_id($uuid)) ) {
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
