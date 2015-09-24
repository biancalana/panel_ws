package PanelWS::Controller::VIP;
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

  #$self->app->log->debug(sprintf("type(%s)", $type[0]));

  # only accept json input
  return $self->nok("invalid json")  unless $json;

  unless ( $json->{type} =~ /^(tcp|http)$/ ) {
    $self->app->log->error("invalid vip type");
    return $self->nok("invalid vip type");
  }

  my $serverpool;

  unless ( $serverpool = $self->serverpool->get($self->stash('tenant_id'), $self->stash('serverpool_id')) ) {
    return $self->nok("invalid serverpool");
  }


  $self->app->log->debug(Dumper($json));

  $self->vip->add($json->{name}, $self->stash('tenant_id'), $self->stash('serverpool_id'), $tx->req->body);

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

  return $self->render($self->vip->list($self->stash('tenant_id')));
}

sub get {

  my ( $self );

  $self = shift;

  $self->app->log->debug(Dumper($self->vip->get($self->stash('tenant_id'), $self->stash('vip_id'))));

  #$app->log->debug($self->stash('name'));
  return $self->render( json => $self->vip->get($self->stash('tenant_id'), $self->stash('vip_id')));
}

1;
