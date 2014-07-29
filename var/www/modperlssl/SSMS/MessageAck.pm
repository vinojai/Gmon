  package SSMS::MessageAck;
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
    
     # $VAR1 = 'sslID=1&message_id=1'
     my $sslIdAndKey;
     my $message_idAndKey;
     ($sslIdAndKey, $message_idAndKey) = split(/\&/, $r->args());
     my ($foo, $sslId) = split(/\=/, $sslIdAndKey);
     my ($foo1, $message_id) = split(/\=/, $message_idAndKey);

     $r->log_error("sslId: ".Dumper($sslId));
     $r->log_error("message_id: ".Dumper($message_id));
     updateAck($dbh, $sslId, $message_id);
     
     $dbh->disconnect();
     return Apache2::Const::OK;
   }

   sub updateAck() {
      my $dbh = shift;
      my $sslId = shift;
      my $message_id = shift;
      my $sql = "UPDATE notify_log SET ack = 1";
      $sql .= " WHERE ssl_id = ? and id = ?";
      my $sth = $dbh->prepare($sql);
      $sth->execute($sslId, $message_id);
      $sth->finish();   
   }

  1;

