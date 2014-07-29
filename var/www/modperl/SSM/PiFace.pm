
  package SSM::PiFace;
  use strict;
  use Net::APNS;
  use Data::Dumper;
  use Apache2::RequestRec ();
  use Apache2::RequestIO ();
  use Apache2::Const -compile => qw(OK);
  use HiPi::BCM2835;

 sub handler {
   my $r = shift;

   my($user, $group) = ('root', 'root');

   HiPi::Utils::drop_permissions_name($user, $group);

   $r->content_type("text/plain");
   print "TEST PI!\n";

   return Apache2::Const::OK;
 }


1;