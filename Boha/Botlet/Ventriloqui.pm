package Boha::Botlet::Ventriloqui;

use Module::Loaded;

$VERSION = '$Id: Ventriloqui.pm,v 1.3 2004/03/24 17:03:50 Administrator Exp $';
$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;

sub onPrivate  {
        my($bot, $who, $rcpt, $msg) = @_;

    return unless $msg =~ s/^,//;

    if($msg =~ /^\/msg\s+(\S+)\s+(.*)$/) {
        $who = $1;
        $msg = $2;
        $bot->say($who, $msg);
    } elsif($msg =~ /^\/ctcp\s+(.*)$/) {
        my($where, $command) = split(/\s+/, $1, 2);
        $bot->post('ctcp', $where, $command);
    } elsif($msg =~ /^\/(\w+)\s+(.*)$/) {
        $bot->post($1, $2);
    } else {
        if(0 and $who eq 'oha') {
            if(is_loaded('Boha::Botlet::Factoid')
            and Boha::Botlet::Factoid->can('random_fact')) {
                my $fact = Boha::Botlet::Factoid::random_fact();
                $bot->say($bot->{chan}, $fact);
            } else {
                $bot->say($bot->{chan}, $msg);
            }
        } else {
            $bot->say($bot->{chan}, $msg);
        }
    }
}

1;
