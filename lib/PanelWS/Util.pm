package PanelWS::Util;

use Data::UUID;

#============================================================
#
#============================================================
sub NewUUID {

  my $ug   = new Data::UUID;

  return($ug->create_bin());
}

#============================================================
#
#============================================================
sub uuid_bin_to_string {

  my $uuid_bin = shift;

  my $ug = Data::UUID->new();

  return($ug->to_string($uuid_bin));

}

#============================================================
#
#============================================================
sub uuid_string_to_bin {

  my $uuid = shift;

  my $ug = Data::UUID->new();

  return($ug->from_string($uuid));

}

#============================================================
#
#============================================================
sub ValidUUID_string {

  my ( $uuid_str );

  $uuid_str    = shift;

  if ( $uuid_str =~ m/([[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-([[:xdigit:]]){12})/gia ) {
    return 1;
  }
}

1;
