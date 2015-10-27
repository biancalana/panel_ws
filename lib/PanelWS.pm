package PanelWS;
use Mojo::Base 'Mojolicious';

use PanelWS::Model::ServerPool;
use PanelWS::Model::Tenant;
use PanelWS::Model::VIP;
use PanelWS::Model::VSLB;
use PanelWS::Util;

use Mojo::mysql;

use Data::Dumper;

# This method will run once at server start
sub startup {
  my $self = shift;

  my $config = $self->plugin('Config'=> { file => 'etc/system.conf' });

  #
  # Helpers
  #
  $self->helper('ok' => sub {
    my ($c, $msg) = @_;
    $c->app->log->info($msg);

    $c->respond_to(
      json  => { json => {code => $self->config->{code}->{OK}}},
      any   => { text => sprintf("code=%d", $self->config->{code}->{OK})}
    );
  });


  $self->helper('nok' => sub {
    my ($c, $err_msg) = @_;
    $c->app->log->error($err_msg);

    if ( $c->stash->{temp_dir} && -d $c->stash->{temp_dir} ) {
        remove_tree($c->stash->{temp_dir})  if -d $c->stash->{temp_dir};
    }

    $c->respond_to(
      json  => { json => {code => $self->config->{code}->{NOK}, status => $err_msg}},
      any   => { text => sprintf("code=%d\nstatus=%s", $self->config->{code}->{NOK}, $err_msg)}
    );
  });


  # Model
  $self->helper( mysql      => sub { state $mysql       = Mojo::mysql->new('mysql://controller:123mudar@192.168.20.20/nginx-controller') });
  $self->helper( tenant     => sub { state $tenant      = PanelWS::Model::Tenant->new(mysql => shift->mysql) });
  $self->helper( vslb       => sub { state $vslb        = PanelWS::Model::VSLB->new(mysql => shift->mysql) });
  $self->helper( serverpool => sub { state $serverpool  = PanelWS::Model::ServerPool->new(mysql => shift->mysql) });
  $self->helper( vip        => sub { state $vip         = PanelWS::Model::VIP->new(mysql => shift->mysql) });

  # Migrate to latest version if necessary
  my $path = $self->home->rel_file('migrations/panel.sql');
  $self->mysql->migrations->name('controller')->from_file($path)->migrate;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  #
  # Router
  #
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/' => sub {
    my $c = shift;

    $c->stash(tenant_list => $self->tenant->list() || []);

    #$c->stash(vip_list => []);
  } => 'index');


  # Tenant
  $r->delete('/tenants')->to('Tenant#delete');
  $r->get('/tenants')->to('Tenant#list');
  $r->post('/tenants')->to('Tenant#add');
  $r->get('/tenants/:tenant_id' => [tenant_id => qr/\d+/] => sub {
    my $c = shift;

    if ( my $tenant = $self->tenant->get_by_id($c->stash('tenant_id')) ) {
      $c->stash(tenant_name     => $tenant->{name});
      $c->stash(serverpool_list => $self->serverpool->list($c->stash('tenant_id')) || []);

    } else {
      $c->redirect_to('/');
    }
  } => 'tenant_view');

  # VSLB Routing
  $r->get('/tenants/:tenant_id/vslbs')->to('VSLB#list');
  $r->post('/vslbs')->to('VSLB#add');
  $r->delete('/vslbs/:vslb_id')->to('VSLB#delete');
  $r->put('/vslbs/:vslb_id')->to('VSLB#change');
  $r->get('/vslbs/:vslb_id' => [vslb_id => qr/\d+/] => sub {
    my $c = shift;

    if ( my $tenant = $self->vslb->get_by_id($c->stash('vslb_id')) ) {
      #$c->stash(tenant_name     => $tenant->{name});
      #$c->stash(serverpool_list => $self->serverpool->list($c->stash('tenant_id')) || []);

    } else {
      $c->redirect_to('/');
    }
  } => 'vslb_view');

  # ServerPool Routing
  $r->get('/tenants/:tenant_id/servepools')->to('ServerPool#list');
  $r->post('/serverpools')->to('ServerPool#add');
  $r->delete('/serverpools/:serverpool_id')->to('ServerPool#delete');
  $r->put('/serverpools/:serverpool_id')->to('ServerPool#change');
  $r->get('/serverpools/:serverpool_id' => [serverpool_id => qr/\d+/] => sub {
    my $c = shift;

    if ( my $tenant = $self->vslb->get_by_id($c->stash('vslb_id')) ) {
      #$c->stash(tenant_name     => $tenant->{name});
      #$c->stash(serverpool_list => $self->serverpool->list($c->stash('tenant_id')) || []);

    } else {
      $c->redirect_to('/');
    }
  } => 'serverpool_view');

  # VIP Routing
  $r->get('/tenants/:tenant_id/vips')->to('VIP#list');
  $r->post('/vips')->to('VIP#add');
  $r->delete('/vips/:vip_id')->to('VIP#delete');
  $r->put('/vips/:vip_id')->to('VIP#change');
  $r->get('/vips/:vip_id' => [vip_id => qr/\d+/] => sub {
    my $c = shift;

    if ( my $tenant = $self->vslb->get_by_id($c->stash('vslb_id')) ) {
      #$c->stash(tenant_name     => $tenant->{name});
      #$c->stash(serverpool_list => $self->serverpool->list($c->stash('tenant_id')) || []);

    } else {
      $c->redirect_to('/');
    }
  } => 'serverpool_view');


}

1;
