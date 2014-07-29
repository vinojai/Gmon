package SSMS::PrintEnvironment;

 # should already be in effect, being careful:
use strict;
use warnings;
use Apache2::RequestRec ( ); # for $r->content_type
use Apache2::Const -compile => qw(OK FORBIDDEN);
use YAML;



sub handler {
    my $r = shift;

    $r->content_type('text/plain');
    for (sort keys %ENV){
        print "$_ => $ENV{$_}\n";
    }

   print Dump({
      'Path_info' => $r->path_info(),
      'request_time' => scalar localtime($r->request_time()),
      });
   
   
    return Apache2::Const::OK;
}

1;
