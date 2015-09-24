package PanelWS;
use Mojo::Base 'Mojolicious';

use PanelWS::Model::ServerPool;
use PanelWS::Model::Tenant;
use PanelWS::Model::VIP;
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
  $self->helper( mysql      => sub { state $mysql = Mojo::mysql->new('mysql://controller:123mudar@192.168.20.20/nginx-controller') });
  $self->helper( serverpool => sub { state $serverpool = PanelWS::Model::ServerPool->new(mysql => shift->mysql) });
  $self->helper( tenant     => sub { state $tenant = PanelWS::Model::Tenant->new(mysql => shift->mysql) });
  $self->helper( vip        => sub { state $vip = PanelWS::Model::VIP->new(mysql => shift->mysql) });

  # Migrate to latest version if necessary
  my $path = $self->home->rel_file('migrations/panel.sql');
  $self->mysql->migrations->name('controller')->from_file($path)->migrate;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/' => sub {
    my $c = shift;

    $c->stash(tenant_list => $self->tenant->list() || []);

    #$c->stash(vip_list => []);
  } => 'index');

  #$r->get('/lb/add')->to('lb#add');

  $r->get('/tenant/list')->to('Tenant#list');
  $r->post('/tenant/add')->to('Tenant#add');
  $r->get('/tenant/:tenant_id' => [tenant_id => qr/\d+/] => sub {
    my $c = shift;

    if ( my $tenant = $self->tenant->get_by_id($c->stash('tenant_id')) ) {
      $c->stash(tenant_name     => $tenant->{name});
      $c->stash(serverpool_list => $self->serverpool->list($c->stash('tenant_id')) || []);

    } else {
      $c->redirect_to('/');
    }
  } => 'tenant_view');

  $r->post('/tenant/:tenant_id/serverpool/add'                    => [tenant_id => qr/\d+/])->to('ServerPool#add');
  $r->post('/tenant/:tenant_id/serverpool/change/:server_pool_id' => [tenant_id => qr/\d+/, server_pool_id => qr/\d+/])->to('ServerPool#change');
  $r->get('/tenant/:tenant_id/serverpool/get/:server_pool_id'     => [tenant_id => qr/\d+/, server_pool_id => qr/\d+/])->to('ServerPool#get');

  $r->post('/tenant/:tenant_id/vip/add/:serverpool_id'  => [tenant_id => qr/\d+/,  serverpool_id => qr/\d+/])->to('VIP#add');
  $r->get('/tenant/:tenant_id/vip/list'                 => [tenant_id => qr/\d+/])->to('VIP#list');
  $r->get('/tenant/:tenant_id/vip/get/:vip_id'          => [tenant_id => qr/\d+/,   vip_id => qr/\d+/])->to('VIP#get');

  #$r->post('/serverpool/add')->to('ServerPool#add');
  #$r->get('/serverpool/get/:name')->to('ServerPool#get');
}

1;
