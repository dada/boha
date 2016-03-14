# Url reminder botlet

package Boha::Botlet::Url;

use SOAP::Lite;
use URI::Find;

$VERSION = '$Id: Url.pm,v 1.10 2004/03/24 16:37:22 dada Exp $';

$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;

sub onPublic {
    my($bot, $who, $chan, $msg) = @_;

    my $nick = $bot->{ nick };

    return 0 unless $msg =~ /^$nick: (.*)$/;

    $cmd = $1;
    if ( $cmd =~ /^url\s+(.*?)\s+(.*)$/ ) {

        if ( is_url( $1 ) ) {

            my $result = SOAP::Lite
                ->uri('http://www.soaplite.com/Boha')
                ->proxy('http://larsen.perlmonk.org/cgi-bin/boha.pl')
                ->add_url( $1,
                           $2 || "Nessuna descrizione",
                           'misc',
                           $who )
                ->result;

            if ( $result !~ /ok/i ) {
                $bot->say( $chan,
                     'Credo che qualcosa non sia andato per il verso giusto'
                         );
            }
            else {
                $bot->say( $chan, "Ok, $who" );
            }
        }
        else {
            $bot->say( $who, "'$1' non mi pare un URL, spiegati meglio" );
            $bot->say( $who,   "Ti ricordo che la sintassi per insegnarmi "
                             . "URL e` url <url> <descrizione>"
                     );
        }
    return 1;
    }
    return 0;
}

my $uri_tester = URI::Find->new( sub {} );

sub is_url {
    my $probable_uri = shift;

    my $result = $uri_tester->find( \$probable_uri );
    return $result;
}


sub help {
    my ($bot, $who, $topic) = @_;

    $bot->say( $who, $_ ) for (
        "Url botlet $VERSION",
        "Per inserire una nuova URL nel DB: url <url> <descrizione>",
        "Per vedere le URL inserite, puntare il browser a questo URL: ",
        "http://larsen.perlmonk.org/cgi-bin/url.pl"
    );
}

1;
