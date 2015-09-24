package PanelWS::Model::ServerPool;
use Mojo::Base -base;

use Data::Dumper;

has 'mysql';


sub add {
  my ($self, $tenant_id, $name, $json) = @_;

  my $sql = 'insert into serverpool (tenant_id, name, json ) values (?, ?, ?)';
  return $self->mysql->db->query($sql, $tenant_id, $name, $json);
}

sub change {

  my ($self, $tenant_id, $id, $json) = @_;

  my $sql = 'update serverpool set json = ? WHERE tenant_id = ? AND id = ?';

  return $self->mysql->db->query($sql, $json, $tenant_id, $id);
}

sub list {
  my ($self, $tenant_id) = @_;

  if ( $tenant_id && $tenant_id =~ /^\d+$/ ) {
    shift->mysql->db->query('select id,name from serverpool where tenant_id = ?', $tenant_id)->hashes->to_array;
  }
}

sub get {
  my ($self, $tenant_id, $id) = @_;

  my $sql = 'select id,name,json from serverpool where tenant_id = ? and id = ?';

  #$self->app->log->debug(Dumper($self->mysql->db->query($sql, $tenant_id, $id)->hash));

  return $self->mysql->db->query($sql, $tenant_id, $id)->hash;
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
