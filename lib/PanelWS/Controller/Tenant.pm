package PanelWS::Controller::Tenant;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub add {

  my ( $self, $app, $tx );

  $self = shift;
  $app  = $self->app;
  $tx   = $self->tx;

  #$self->app->log->debug($tx->req->headers->content_type);
  #$self->app->log->debug("->>>> " . Dumper($tx->req->body));
  #$self->app->log->debug(Dumper($tx->req->param('name')));

  return $self->nok("invalid tenant name")  unless $tx->req->param('name') =~ /^[a-z0-9_-]+$/;

  $self->tenant->add($tx->req->param('name'));

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
  my @x = @_;

  $app  = $self->app;
  $tx   = $self->tx;
  $json = $tx->req->json;

  #$app->log->debug($self->stash('name'));
  return $self->render( json => $self->serverpool->get(1, $self->stash('name')));
}

1;
