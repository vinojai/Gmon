   package SSM::garagescv ;
   use warnings ;
   use strict ;

   # sub new(){
   #  my $self = {};
   #  bless $self;
   #  return $self;
   # }

   # Implement the GET HTTP method.
   sub GET{
       my ($self, $request, $response) = @_ ;
       $response->data()->{'api_mess'} = 'Hello, this is MyApp REST API' ;
       return Apache2::Const::HTTP_OK ;
   }
   # Authorize the GET method.
   sub isAuth{
      my ($self, $method, $req) = @ _; 
      return $method eq 'GET';
   }
   1 ;