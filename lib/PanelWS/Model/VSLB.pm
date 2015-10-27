package PanelWS::Model::VSLB;
use Mojo::Base -base;

use Data::Dumper;

has 'mysql';


sub add {
  my ($self, $id, $name, $tenant_id) = @_;

  my $sql = 'insert into vslb (uuid, name, tenant_uuid, ctime, mtime) values (?, ?, ?, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP())';
  return $self->mysql->db->query($sql, $id, $name, $tenant_id);
}

sub list {
  my ($self, $tenant_id) = @_;

  shift->mysql->db->query('select name from vslb where tenant_uuid = ?', $tenant_id)->hashes->to_array;
}

sub get_by_id {
  my ($self, $tenant_id, $id) = @_;

  shift->mysql->db->query('select uuid,name,ctime,mtime,tenant_uuid from vslb where tenant_uuid = ? AND uuid = ?', $tenant_id, $id)->hash;
}

1;
