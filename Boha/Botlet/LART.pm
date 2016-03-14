# Url reminder botlet

package Boha::Botlet::LART;

use LWP::UserAgent;
use URI::Find;

$VERSION = '$Id: LART.pm,v 1.00 2013/04/18 16:53:00 dada Exp $';

$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;

sub onPublic {
    my($bot, $who, $chan, $msg) = @_;

    my $nick = $bot->{ nick };

    return 0 unless $msg =~ /^$nick: (.*)$/;

    $cmd = $1;
    if ( $cmd =~ /^lart\s+(.*)$/ ) {
        my $nick = $1;
        if(my $insult = get_insult()) {
            $bot->say($chan, "$nick: $insult");
        }
        return 1;
    }
    return 0;
}

sub get_insult {
    my $ua = LWP::UserAgent->new();
    my $response = $ua->post(
        'http://www.wowbagger.com/process.php',
        {
            Language => 1,
            Rating => 3,
            Password => 'yeah42',
        },
    );
    if($response->is_success()) {
        my($insult) =
            $response->content =~ m{<SPAN class=customBig>(.*?)</SPAN>};
        return $insult;
    }
    return undef;
}

sub help {
    my ($bot, $who, $topic) = @_;

    $bot->say( $who, $_ ) for (
        "LART botlet $VERSION",
        "Per LARTare un luser: lart <nick>",
    );
}

1;
