package PanelWS::Model::ServerPool;
use Mojo::Base -base;


use Data::Dumper;

has 'mysql';


sub add {
  my ($self, $tenant_id, $name, $json) = @_;

  my $sql = 'insert into serverpool (tenant_uuid, name, json ) values (?, ?, ?)';
  return $self->mysql->db->query($sql, $tenant_id, $name, $json);
}

sub change {

  my ($self, $tenant_id, $id, $json) = @_;

  my $sql = 'update serverpool set json = ? WHERE tenant_uuid = ? AND uuid = ?';

  return $self->mysql->db->query($sql, $json, $tenant_id, $id);
}

sub list {
  my ($self, $tenant_id) = @_;

  shift->mysql->db->query('select uuid,name from serverpool where tenant_uuid = ?', $tenant_id)->hashes->to_array;
}

sub get {
  my ($self, $tenant_id, $id) = @_;

  my $sql = 'select id,name,json from serverpool where tenant_uuid = ? and uuid = ?';

  #$self->app->log->debug(Dumper($self->mysql->db->query($sql, $tenant_id, $id)->hash));

  return $self->mysql->db->query($sql, $tenant_id, $id)->hash;
}

1;
