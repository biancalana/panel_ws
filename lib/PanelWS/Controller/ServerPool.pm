package PanelWS::Controller::ServerPool;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;


sub add {

  my ( $self, $app, $tx, $json );

  $self = shift;
  $app  = $self->app;
  $tx   = $self->tx;
  $json = $tx->req->json;

  #$self->app->log->debug($tx->req->headers->content_type);
  #$self->app->log->debug(Dumper($tx->req->body));

  my @type = keys %{$json};

  #$self->app->log->debug(sprintf("type(%s)", $type[0]));

  unless ( $type[0] =~ /^(tcp|http)$/ ) {
    $self->app->log->error("invalid serverpool type");
  }

  # only accept json input
  return $self->nok("invalid json")  unless $json;

  $self->app->log->debug(Dumper($json));

  $self->serverpool->add($self->stash('tenant_id'), $json->{$type[0]}->{upstream}->{name}, $tx->req->body);

  return $self->ok("Ok");
}

sub change {

  my ( $self, $app, $tx, $json );

  $self = shift;

  $app  = $self->app;
  $tx   = $self->tx;
  $json = $tx->req->json;

  my @type = keys %{$json};

  unless ( $type[0] =~ /^(tcp|http)$/ ) {
    $self->app->log->error("invalid serverpool type");
    return $self->nok("invalid serverpool type")
  }

  # only accept json input
  return $self->nok("invalid json")  unless $json;

  $self->serverpool->change($self->stash('tenant_id'), $self->stash('server_pool_id'), $tx->req->body);

  return $self->ok("Ok");

}

sub list {
  my ( $self, $app, $tx, $json );

  $self = shift;
  $app  = $self->app;
  $tx   = $self->tx;

  return $self->render($self->serverpool->list($self->stash('tenant_id')));
}

sub get {

  my ( $self );

  $self = shift;

  $self->app->log->debug(Dumper($self->serverpool->get($self->stash('tenant_id'), $self->stash('server_pool_id'))));

  #$app->log->debug($self->stash('name'));
  return $self->render( json => $self->serverpool->get($self->stash('tenant_id'), $self->stash('server_pool_id')));
}

1;
