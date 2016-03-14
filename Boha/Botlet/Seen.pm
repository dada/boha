# dedicated to dakkar

package Boha::Botlet::Seen;

use Storable;
use Acme::Time::Baby
    language => 'it',
    format => 'quando la lancetta lunga era sull%s e quella corta era sull%s';

use DateTime::Format::Human::Duration;
use DateTime::Format::Human::Duration::Locale::it;

use Time::Human;
$Time::Human::templates{Italian} = {
        numbers  => [ "l'una", "le due", "le tre", "le quattro", "le cinque", "le sei", "le sette", "le otto", "le nove", "le dieci", "le undici", "le dodici" ],
        vagueness=> [ "esattamente al", "dopo ", "un po' dopo ", "qualche minuto prima del", "quasi al"],
        daytime  => [ "di mattina", "di pomeriggio", "di sera", "della notte" ],
        minutes  => ["e cinque", "e dieci", "e un quarto", "e venti",
                    "e venticinque", "e mezza", "meno venticinque",
                    "meno venti", "meno un quarto", "meno dieci", "meno cinque"],
        oclock   => "",
        midnight => "l'ora delle streghe",
        midday   => "la mezza",
        format   => "%v%h %m %d",
};
$Time::Human::Language = "Italian";

use Date::Roman;

$VERSION = '$Id: Seen.pm,v 1.0 2007/07/19 15:40:00 dada Exp $';
$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;

my $seen_place = 'data/seen';

my $seen = {};

sub onInit {
    $Storable::accept_future_minor = 1;
    $seen = retrieve( $seen_place ) if -e $seen_place;
    delete $seen->{""};
}

sub onPublic {
    my($bot, $who, $chan, $msg) = @_;

    print "SEEN: onPublic from $who ($msg)\n";

    my $nick = $bot->{ nick };

    $seen->{lc $who} = time;
    store $seen, $seen_place;

    if($msg =~ /^$nick: (hai visto|vedetti|vidisti|seen)\s+(.*?)\??$/i) {
        my $wanted = $2;
        my $message = get_message($wanted);
        if($message) {
            $bot->say($chan, "$who: $message");
        } else {
            $bot->say($chan, "$who: nope");
        }
        return 1;
    }
    return 0;
}

sub get_message {
    my($nick) = @_;
    if(exists($seen->{lc $nick})) {
        return "$nick era qui " . time2human($seen->{lc $nick});
    } else {
        return undef;
    }
}


sub time2human
{
    my $time = shift;
    
    my(undef, undef, undef, $da, $ma, $ya) = localtime($time);
    my(undef, undef, undef, $db, $mb, $yb) = localtime();
    if($da == $db && $ma == $mb && $ya == $yb) {
        return humanize(localtime($time));
    } else {
        # my $r = Date::Roman->new(epoch => $time);
        # return "il " . $r ->as_string();
        my $ta = DateTime->now();
        my $tb = DateTime->from_epoch(epoch => $time);
        my $formatter = DateTime::Format::Human::Duration->new();
        return $formatter->format_duration_between($ta, $tb, locale => 'it') . ' fa';
    }
}

sub dump {
    use Data::Dumper;
    print Dumper $seen;
}


1;
