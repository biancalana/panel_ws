package PanelWS::Model::Tenant;
use Mojo::Base -base;

use Data::Dumper;

has 'mysql';


sub add {
  my ($self, $name) = @_;

  my $sql = 'insert into tenant (name) values (?)';
  return $self->mysql->db->query($sql, $name);
}

sub list {
  my ($self) = @_;

  shift->mysql->db->query('select id,name from tenant')->hashes->to_array;
}

sub list_by_id {
  my ($self, $id) = @_;

  if ( $id && $id =~ /^\d+$/ ) {
    shift->mysql->db->query('select name from tenant where id = ?', $id)->hashes->to_array;
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

  my $sql = 'select id,name,ctime from tenant where name = ?';

  return $self->mysql->db->query($sql, $name)->hash;
}

sub get_by_id {
  my ($self, $id) = @_;

  my $sql = 'select id,name,ctime from tenant where id = ?';

  return $self->mysql->db->query($sql, $id)->hash;
}

=asdasdsad
#sub add {
  my ($self, $post) = @_;
  my $sql = 'insert into serverpool (lb_id, name, type, mode, ) values (?, ?) returning id';
  return $self->pg->db->query($sql, $post->{title}, $post->{body})->hash->{id};
}

sub all { shift->pg->db->query('select * from posts')->hashes->to_array }

sub find {
  my ($self, $id) = @_;
  return $self->pg->db->query('select * from posts where id = ?', $id)->hash;
}

sub remove { shift->pg->db->query('delete from posts where id = ?', shift) }

sub save {
  my ($self, $id, $post) = @_;
  my $sql = 'update posts set title = ?, body = ? where id = ?';
  $self->pg->db->query($sql, $post->{title}, $post->{body}, $id);
}
=cut

1;
