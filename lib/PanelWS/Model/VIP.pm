package PanelWS::Model::VIP;
use Mojo::Base -base;

use Data::Dumper;

has 'mysql';


sub add {
  my ($self, $name, $tenant_id, $serverpool_id,  $json) = @_;

  my $sql = 'insert into vip (name, tenant_id, serverpool_id, json, ctime, mtime) values (?, ?, ?, ?, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP())';
  return $self->mysql->db->query($sql, $name, $tenant_id, $serverpool_id, $json);
}

sub list {
  my ($self, $tenant_id) = @_;

  if ( $tenant_id && $tenant_id =~ /^\d+$/ ) {
    shift->mysql->db->query('select name from vip where tenant_id = ?', $tenant_id)->hashes->to_array;
  }
}

sub get {
  my ($self, $tenant_id, $id) = @_;

  if ( $id && $id =~ /^\d+$/ && $tenant_id && $tenant_id =~ /^\d+$/ ) {
    shift->mysql->db->query('select id,name,json,ctime,mtime,serverpool_id from vip where tenant_id = ? AND id = ?', $tenant_id, $id)->hash;
  }
}

1;
