use Test::More qw/no_plan/;

use Boha::Botlet::Url;

is( Boha::Botlet::Url::is_url( 'http://www.perl.it' ), 1, 
    ' ...URI valido' );
is( Boha::Botlet::Url::is_url( 'http://www.perl.it/prova.pl' ), 1, 
    ' ...URI valido un po\' piu` complesso' );
is( Boha::Botlet::Url::is_url( 'http://www.perl.it/prova.pl?foo=bar' ), 1, 
    ' ...URI valido sempre piu` complesso' );
is( Boha::Botlet::Url::is_url( 'no' ), 0, 
    ' ...URI non valido' );
is( Boha::Botlet::Url::is_url( 'www.perlmonks.org' ), 0, 
    ' ...URI valido ma senza schema' );
is( Boha::Botlet::Url::is_url( 'ftp://ftp.sunsite.it' ), 1, 
    ' ...altro schema' );


