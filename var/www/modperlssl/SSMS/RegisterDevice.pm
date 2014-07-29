  package SSMS::RegisterDevice;
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
     
     my $key;
     my $apnToken;
     ($key, $apnToken) = split(/\=/, $r->args);

     my $sslId;

     if($key eq "deviceToken"){
      # $r->log_error(Dumper($apnToken));
      $sslId = dBgetDevId($dbh, $apnToken);
      if(! $sslId) {
        registerNewDevice($dbh, $apnToken);
        $sslId = dBgetDevId($dbh, $apnToken);
      }
    }

     my $registrationStatusRec = {
      'sslId' => $sslId,
     };

     my $json = JSON->new->allow_nonref;
     $r->print($json->pretty->encode ($registrationStatusRec));

     $dbh->disconnect();
     return Apache2::Const::OK;
   }

   sub dBgetDevId {
    my $dbh = shift;
    my $apnToken = shift;
     my $sql;
     $sql =  "SELECT device_registration.id";
     $sql .= " FROM device_registration";
     $sql .= " WHERE";
     $sql .= "  device_registration.device_id = ?";
     my $sth = $dbh->prepare($sql);
     $sth->execute($apnToken);

     my $row;
     my $id;
     while ($row = $sth->fetchrow_arrayref()) {
       $id = @$row[0];
     }
     return $id;
   }

   sub registerNewDevice{
      my $dbh = shift;
      my $deviceId = shift;
      $dbh->do("INSERT INTO device_registration (device_id, time, active) VALUES (\"$deviceId\", ".time.", 1)");    
   }
  1;

