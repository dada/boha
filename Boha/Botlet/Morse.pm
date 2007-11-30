# "speravo che fosse nel canale" -- gaspa

package Boha::Botlet::Morse;

use Convert::Morse qw(as_morse as_ascii);

$VERSION = '$Id: Morse.pm,v 1.0 2007/03/06 14:57:00 dada Exp $';
$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;
sub onPublic {    my($bot, $who, $chan, $msg) = @_;    my $nick = $bot->{ nick };    return unless $msg =~ /^$nick:\s+(morse|demorse)\s+(.*)$/;    my $cmd = $1;    my $txt = $2;
    if($cmd eq 'morse') {        $bot->say($chan, as_morse($txt));        
    }    if($cmd eq 'demorse') {
    	$bot->say($chan, as_ascii($txt));
    }
}
sub help {	my($bot, $who, $topic) = @_;	$bot->say($who, "Morse botlet $VERSION");	$bot->say($who, "vuoi _veramente_ sapere cosa fa sto botlet? non ci credo");
}

1;
