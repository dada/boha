package Boha::Botlet::Ventriloqui;

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
        $bot->say($bot->{chan}, $msg);
    }
}

1;
