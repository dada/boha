# MonkLink botlet

package Boha::Botlet::MonkLink;

$VERSION = '$Id: MonkLink.pm,v 1.4 2004/05/14 13:14:38 dada Exp $';

$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;

use MetaCPAN::API;
use List::Util qw( shuffle );

my $dettagliato = 0;

sub onPublic {
    my($bot, $who, $chan, $msg) = @_;

    if($msg eq "$bot->{nick}: solo link") {
        $dettagliato = 0;
    }
    if($msg eq "$bot->{nick}: link con panna") {
        $dettagliato = 1;
    }

    while($msg =~ s!id://(\d+)!!) {
        $bot->say( $chan, "http://www.perlmonks.org/index.pl?node_id=$1" );
    }

    while($msg =~ s!\[(\d+)\]!!) {
        $bot->say( $chan, "http://www.perlmonks.org/index.pl?node_id=$1" ) if $1 > 999;
    }

    while($msg =~ s!pad://(\w+)!!) {
        $bot->say( $chan, "http://www.perlmonks.org/index.pl?node_id=108949&user=$1" );
    }

    while($msg =~ s!\[?cpan:(?://)?([a-zA-Z0-9_\-:]+)\]?!!) {
        my $requested = $1;
        my $cpan = MetaCPAN::API->new();
        my $module = eval { MetaCPAN::API->new()->module($requested) };
        if(defined $module) {
            $bot->say( $chan, "http://p3rl.org/$requested");
            if($dettagliato) {
                $bot->say( $chan, sprintf("%s, versione %s del %s rilasciata da %s",
                    $module->{abstract},
                    $module->{version},
                    $module->{date},
                    $module->{author},
                ));
            }
        }
        else {
            my @frasi = (
                "il modulo %s non esiste",
                "il modulo %s te lo sei inventato tu",
                "il modulo %s non mi risulta",
                "ENOSUCHMODULE: %s",
                "non esiste nessun modulo %s. esiste solo ZUUL!",
                "non dategli retta, non esiste nessun modulo %s",
                "il modulo %s non esiste, scrivilo!",
            );
            my $frase = scalar(shuffle(@frasi));
            $bot->say( $chan, "$who: " . sprintf($frase, $requested) );
        }
    }

    return 0;
}

1;
