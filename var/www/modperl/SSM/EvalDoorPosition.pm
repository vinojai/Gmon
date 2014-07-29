  package SSM::EvalDoorPosition;
  use strict;
  use Net::APNS;
  use Data::Dumper;
  use Apache2::RequestRec ();
  use Apache2::RequestIO ();
  use Apache2::Const -compile => qw(OK);
  use WWW::Curl::Easy;
  use Switch;
  use DBI;

  #use Apache::Constants qw(:common);
  sub handler {
     my $r = shift;
     $r->content_type("text/plain");
     my $curl = WWW::Curl::Easy->new;

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

     $curl->setopt(CURLOPT_HEADER,1);

     if($r->dir_config('DOOR_POSITION')  ne $currentDoorPosition) {
      print "DOOR POSITION was ".$currentDoorPosition." now ".$r->dir_config('DOOR_POSITION')."\n";
      $currentDoorPosition = $r->dir_config('DOOR_POSITION');
      switch ($r->dir_config('DOOR_POSITION')) {
        case "closed"{
          $curl->setopt(CURLOPT_URL, 'http://localhost/isclosed');
        }
        case "open"{
          $curl->setopt(CURLOPT_URL, 'http://localhost/isopen');
        }
      }
      $curl->perform;
      updateTable($dbh, $r->dir_config('DOOR_POSITION'));
     }

     $dbh->disconnect();
     return Apache2::Const::OK;
   }

   sub updateTable() {
      my $dbh = shift;
      my $position = shift;
      my $sql = "UPDATE position SET current_position = ?, time = ? WHERE door_name = ?";
      my $sth = $dbh->prepare($sql);
      $sth->execute($position, time, "Door 1");
      $sth->finish();   
   }
  1;

