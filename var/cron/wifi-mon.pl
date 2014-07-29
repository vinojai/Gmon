#! /usr/bin/perl

## Checks connectivity to the local router. Resets NIC if there is no connection.
use Net::Ping;
use DBI;

use constant TIMETOREBOOT => 120;
use constant HOSTNAME => "10.0.0.1";

my $logFile = "/var/log/wifi-mon.log";
open(LOG, ">>", $logFile) || die "$! >> $logFile";

my $TimeToReboot = 120;

 my $dbh = DBI->connect("dbi:SQLite:dbname=/var/sqlite/garagemon.db","","",{AutoCommit=>1,RaiseError=>1,PrintError=>0});
 
 my $sql;
 $sql =  "SELECT ";
 $sql .= " status,";
 $sql .= " time";
 $sql .= " FROM system_status";
 $sql .= " WHERE";
 $sql .= "  ID = (SELECT MAX(ID) FROM system_status)";

 my $sth = $dbh->prepare($sql);
 $sth->execute();

 my $row;
 my $oldStatus;
 my $oldTime;
 while ($row = $sth->fetchrow_arrayref()) {
   $oldStatus = @$row[0];
   $oldTime = @$row[1];
 }
 $sth->finish();

my $status;

my $host = HOSTNAME;

$p = Net::Ping->new();
if (! $p->ping($host)) {
	if($oldStatus eq "ERROR" && (time - oldTime >= TIMETOREBOOT)) {
		$status = "REBOOT"
	} else {
		system ("ifdown wlan0");
		sleep(2);
		system ("ifup wlan0");
		system ("iwconfig wlan0 power off");
		$status = "ERROR";
	}

 } else {
 	$status = "OK";
 }
 print LOG localtime." $status\n";
 updateTable($dbh, $status);
 cleanTable($dbh);
 $p->close();
 $dbh->disconnect();
 if($status eq "REBOOT"){
 	system ("reboot");
 }



sub updateTable() {
  my $dbh = shift;
  my $status = shift;
  my $sql;
  $sql .= "INSERT INTO system_status("; 
  $sql .= "	status, ";
  $sql .= " time )";
  $sql .= " VALUES";
  $sql .= " (?, ?)";
  my $sth = $dbh->prepare($sql);
  $sth->execute($status, time);
  $sth->finish();   
}

sub cleanTable() {
  my $dbh = shift;
  my $sql;
  $sql .= "DELETE FROM system_status"; 
  $sql .= " WHERE";
  $sql .= " (status = ? and time < ?)";
  my $sth = $dbh->prepare($sql);
  $sth->execute("OK", (time - 26000));
  $sth->finish();   
}

1;
