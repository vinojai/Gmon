  package SSM::Notify;
  use strict;
  use Net::APNS;
  use Data::Dumper;
  use Apache2::RequestRec ();
  use Apache2::RequestIO ();
  use Apache2::Const -compile => qw(OK);
  use XML::Simple;
  use DBI;
  use Net::Ping;

  my %messageMap = (
    "Garage Door Is Open",        0,
    "Garage Door Is Still Open",  1,
    "Garage Door Is Closed",      2
    );
  
  sub handler {
    my $r = shift;
    $r->content_type("text/plain");

    my $dbh = DBI->connect("dbi:SQLite:dbname=/var/sqlite/garagemon.db","","",{AutoCommit=>1,RaiseError=>1,PrintError=>0});

    my $xs = XML::Simple->new();
    my $xcfg = $xs->XMLin("/etc/apache2/certificate/cert.xml");

    wakeUpWiFi();

    foreach my $idSet (dBgetActiveDeviceIds($dbh)) {
        my $id = $idSet->{sslId};
        my $deviceID = $idSet->{devid};
        $dbh->do("INSERT INTO notify_log (type_name, ssl_id, time, ack) VALUES (".$messageMap{$r->dir_config('PUSH_MESSAGE')}.", \"$id\", ".time.", 0)");
        # $r->log_error(Dumper($deviceID));
        my $APNS = Net::APNS->new;
        my $Notifier = $APNS->notify({
          cert   => $xcfg->{certfile},
          key    => $xcfg->{keyfile},
          passwd => $xcfg->{passwd}
        });
        $Notifier->devicetoken($deviceID);
        $Notifier->message($r->dir_config('PUSH_MESSAGE')); ## From Apache Config
        $Notifier->badge(1);
        $Notifier->sound('default');
        $Notifier->sandbox($xcfg->{sandbox});
        $Notifier->custom({ message_id => dBgetGetHighestMessageId($dbh)});

        $Notifier->write();
        print "NOTIFY! to $deviceID \n";
        print "Certificate: ".$Notifier->{cert}."\n";
        print "Key: ".$Notifier->{key}."\n";
        print $r->dir_config('PUSH_MESSAGE');
    }
    $dbh->disconnect();
    return Apache2::Const::OK;
  }

  sub dBgetActiveDeviceIds {
       my $dbh = shift;
       my $sql;
       $sql =  "SELECT ";
       $sql .= " device_registration.id,";
       $sql .= " device_registration.device_id";
       $sql .= " FROM device_registration";
       $sql .= " WHERE";
       $sql .= "  device_registration.active > 0";
       my $sth = $dbh->prepare($sql);
       $sth->execute();

       my $row;
       my @devIds;
       while ($row = $sth->fetchrow_arrayref()) {
         my $id = @$row[0];
         my $devId = @$row[1];
         push(@devIds, {sslId=>$id, devid=>$devId});
       }
       return @devIds;
   }

   sub dBgetGetHighestMessageId {
       my $dbh = shift;
       my $sql;
       $sql =  "SELECT MAX(notify_log.id)";
       $sql .= " FROM notify_log";
       my $sth = $dbh->prepare($sql);
       $sth->execute();

       my $row;
       my $msgId;
       while ($row = $sth->fetchrow_arrayref()) {
         $msgId = @$row[0];
       }
       return $msgId;
   }

   sub wakeUpWiFi {
    my $host = "10.0.0.1";
    my $i = 0;
    my $p = Net::Ping->new();
    while (! $p->ping($host) && $i++ < 8) {}
  }
  1;
