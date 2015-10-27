package PanelWS::Model::Tenant;
use Mojo::Base -base;

use Data::Dumper;

has 'mysql';


sub add {
  my ($self, $uuid, $name) = @_;

  my $sql = 'insert into tenant (uuid,name) values (?, ?)';
  return $self->mysql->db->query($sql, $uuid, $name);
}

sub list {
  my ($self) = @_;

  shift->mysql->db->query('select uuid,name from tenant')->hashes->to_array;
}

sub list_by_id {
  my ($self, $id) = @_;

  if ( $id && $id =~ /^\d+$/ ) {
    shift->mysql->db->query('select name from tenant where uuid = ?', $id)->hashes->to_array;
  }
}

sub list_by_name {
  my ($self, $name) = @_;

  if ( $name && $name =~ /^\w+$/ ) {
    shift->mysql->db->query('select name from tenant where name = ?', $name)->hashes->to_array;
  }
}

sub get_by_name {
  my ($self, $name) = @_;

  my $sql = 'select uuid,name,ctime from tenant where name = ?';

  return $self->mysql->db->query($sql, $name)->hash;
}

sub get_by_id {
  my ($self, $id) = @_;

  my $sql = 'select uuid,name,ctime from tenant where uuid = ?';

  return $self->mysql->db->query($sql, $id)->hash;
}


1;
