# "speravo che fosse nel canale" -- gaspa

package Boha::Botlet::Morse;

use Convert::Morse qw(as_morse as_ascii);

$VERSION = '$Id: Morse.pm,v 1.0 2007/03/06 14:57:00 dada Exp $';
$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;
sub onPublic {
    if($cmd eq 'morse') {
    }
    	$bot->say($chan, as_ascii($txt));
    }
}
sub help {
}

1;