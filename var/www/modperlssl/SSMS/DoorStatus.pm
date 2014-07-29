  package SSMS::DoorStatus;
  use strict;
  use Data::Dumper;
  use Apache2::RequestRec ();
  use Apache2::RequestIO ();
  use Apache2::Const -compile => qw(OK);
  use Switch;
  use DBI;
  use JSON;

  #use Apache::Constants qw(:common);
  sub handler {
     my $r = shift;
     $r->content_type("application/json");

     my $dbh = DBI->connect("dbi:SQLite:dbname=/var/sqlite/garagemon.db","","",{AutoCommit=>1,RaiseError=>1,PrintError=>0});
     
     my $sql;
     $sql =  "SELECT position.current_position";
     $sql .= " FROM position";
     $sql .= " WHERE";
     $sql .= "  position.door_name = \"Door 1\"";
     my $sth = $dbh->prepare($sql);
     $sth->execute();

     my $row;
     my $currentDoorPosition;
     while ($row = $sth->fetchrow_arrayref()) {
       $currentDoorPosition = @$row[0];
     }
     $sth->finish();
     
     my $doorStatusRec = {
      'door_name' => "Door 1",
      'status' => $currentDoorPosition,
     };

     my $json = JSON->new->allow_nonref;
     $r->print($json->pretty->encode ($doorStatusRec));

     return Apache2::Const::OK;
   }

  1;

