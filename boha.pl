# main application

#### NOTE:
####
#### $boha è l'oggetto bot, una vera global(tm)
####
####
####

# sub POE::Kernel::TRACE_DEFAULT () { 1 };
#BEGIN {
#sub POE::Kernel::TRACE_EVENTS () { 1 };
#sub POE::Kernel::TRACE_SESSIONS () { 1 };
#}
use Boha;
use Encode;
use POE;
use POE::Component::IRC;
#sub POE::Component::Server::SOAP::DEBUG () { 1 };
#use POE::Component::Server::SOAP;

use vars qw(
    $boha
    $VERSION
);

$VERSION = '$Id: boha.pl,v 1.30 2004/06/15 12:45:51 dada Exp $';

#### creiamo il nostro oggettone
$boha = Boha->new( $poe_kernel );

#### carichiamo i botlet e popoliamo il pool
print STDERR map { "loaded botlet $_\n" } $boha->init();

#### impostiamo qualche parametro
#### (poi sarà preso da file di conf.)
$boha->{host} = 'irc.freenode.net'; # 'irc.slashdot.org';
$boha->{nick} = 'boha';
$boha->{quit} = 'Dave... ho paura';
$boha->{chan} = [ '#perl.it', '#perl-it' ]; # [ '#nordest.pm' ];

#### creiamo gli oggetti POE che ci servono
POE::Component::IRC->new( 'boha' )
    or die "Can't instantiate new IRC component!\n";

# POE::Component::Server::SOAP->new(
#     ALIAS => 'bohaSOAPservice',
#     ADDRESS => '83.103.30.60',
#     # ADDRESS => '127.0.0.1',
#     PORT  => 52525,
# );

POE::Session->create(
    inline_states => {
        _start                 => \&_start,
        _stop                 => \&_stop,
        sigint                => \&sigint,
        irc_001             => \&irc_001,
        irc_disconnected    => \&irc_disconnected,
        irc_error             => \&irc_error,
        irc_join            => \&irc_join,
        irc_kick            => \&irc_kick,
        irc_msg                => \&irc_msg,
        irc_nick            => \&irc_nick,
        irc_notice            => \&irc_notice,
        irc_public            => \&irc_public,
        irc_part            => \&irc_part,
        irc_quit            => \&irc_quit,
        irc_socketerr         => \&irc_socketerr,
        irc_topic            => \&irc_topic,
        # disabled because we don't want to twit topic on join
        # irc_332                => \&irc_rpl_topic,
        mainloop            => \&mainloop,
        get_karma            => \&get_karma,
        get_fact            => \&get_fact,
    },
);

#        irc_mode

#### e lasciamolo andare
$boha->go();


####
#### EVENTI IRC
####

sub _start {
    my ($kernel) = $_[KERNEL];
    $kernel->post( 'boha', 'register', 'all');
    $kernel->post( 'boha', 'connect', {
        Debug    => 1,
        Nick     => $boha->{nick},
        Server   => $boha->{host},
        Port     => $boha->{port},
        Username => 'boha',
        Ircname  => "Boha/$VERSION", }
    );
    $kernel->sig( INT => "sigint" );
    $kernel->delay( mainloop => 1 );
#    $kernel->alias_set( 'bohaSOAP' );
#    $kernel->post( 'bohaSOAPservice', 'ADDMETHOD', 'bohaSOAP', 'get_karma' );
#    $kernel->post( 'bohaSOAPservice', 'ADDMETHOD', 'bohaSOAP', 'get_fact' );
}

sub irc_001 {
    my ($kernel) = $_[KERNEL];
    $kernel->post( 'boha', 'mode', $boha->{nick}, '+i' );

    # autenticazione nickserv
    $kernel->post('boha', 'privmsg', 'nickserv', 'IDENTIFY ima_oha_bot');

    # join dei canali ...
    map { $boha->join( $_ ); } @{$boha->{chan}};

    # evtl. welcome msg...
    # $kernel->post( 'boha', 'privmsg', $CONFIG{channel}, $CONFIG{welcome} ) if $CONFIG{welcome};
}

sub irc_disconnected {
    my ($server) = $_[ARG0];
    print "Lost connection to server $server.\n";
    $_[KERNEL]->post( "boha", "unregister", "all" );
    $_[KERNEL]->delay( 'mainloop' );
    _start(@_); # gira la ruota...
}

sub irc_error {
    my $err = $_[ARG0];
    print "Server error occurred! $err\n";
    $_[KERNEL]->delay( 'mainloop' );
}

sub irc_socketerr {
    my $err = $_[ARG0];
    print "Couldn't connect to server: $err\n";
    $_[KERNEL]->delay( 'mainloop' );
}

sub sigint {
    my $kernel = $_[KERNEL];
    $kernel->post( 'boha', 'quit', $boha->{quit} );
    $_[KERNEL]->delay( 'mainloop' );
    $kernel->sig_handled();
}

sub _stop {
    my ($kernel) = $_[KERNEL];
    print "Control session stopped.\n";
    $_[KERNEL]->delay( 'mainloop' );
}

sub irc_join {
    my($kernel, $who, $chan) = @_[KERNEL, ARG0, ARG1];
    unless($who =~ s/^(.*)!.*$/$1/) {
        warn "weird-ass who: $who";
        return undef;
    }

    # dispatch ai vari botlet...
    dispatch('onJoin', $who, $chan);

}

sub irc_part {
    my($kernel, $who, $chan) = @_[KERNEL, ARG0, ARG1];
    unless($who =~ s/^(.*)!.*$/$1/) {
        warn "weird-ass who: $who";
        return undef;
    }

    # dispatch ai vari botlet...
    dispatch('onPart', $who, $chan);
}

sub irc_quit {
    my($kernel, $who, $msg) = @_[KERNEL, ARG0, ARG1];

    # dispatch ai vari botlet...
    dispatch('onQuit', $who, $msg);
}

sub irc_public {
    my($kernel, $who, $chan, $msg) = @_[KERNEL, ARG0 .. ARG2];
    unless($who =~ s/^(.*)!.*$/$1/) {
        warn "weird-ass who: $who";
        return undef;
    }

    # qui va il dispatch ai vari botlet...
    dispatch('onPublic', $who, $chan, $msg);
}

sub irc_msg {
    my($kernel, $who, $rcpt, $msg) = @_[KERNEL, ARG0 .. ARG2];
    unless($who =~ s/^(.*)!.*$/$1/) {
        warn "weird-ass who: $who";
        return undef;
    }

    if($msg eq 'reboot') {

        $boha->auth_cmd( $who,
            onSuccess => sub {
                system('cvs update -P');
                system('net stop boha');
                # exit(0); #### ripartirò?
            },
            onFailure => sub {
                my($who) = @_;
                $boha->say( $who,
                    "sorry, questo comando è riservato ".
                    "agli utenti noti.",
                );
            },
        );
    }

    if($msg eq 'reload') {

        $boha->auth_cmd( $who,
            onSuccess => sub {
                my($who) = @_;
                #### use Data::Dumper;
                #### print Dumper \%INC;
                foreach my $botlet (@Boha::botlet) {
                    my $botletname = $botlet;
                    $botletname =~ s|::|/|g;
                    $botletname .= ".pm";
                    print STDERR "deleting '$botletname'\n";
                    delete $INC{$botletname};
                }
                #### print Dumper \%INC;
                $boha->say($who, "output del CVS:");
                my @cvs_output = `cvs update -P`;
                foreach my $line (@cvs_output) {
                    $boha->say($who, $line);
                }
                $boha->say($who, "risultato dell'init:");
                my @result = $boha->init();
                foreach my $botlet (@result) {
                    $boha->say($who, $botlet);
                }
            },
            onFailure => sub {
                my($who) = @_;
                $boha->say( $who,
                    "sorry, questo comando è riservato ".
                    "agli utenti noti.",
                );
            },
        );
    }

    if($msg =~ /^auth (\S+)/) {
        $boha->say( $who, ($boha->is_registered($1)) ? "yes" : "no" );
    }

    if($msg =~ /^YOLO$/) {
        $boha->auth($who);
        $boha->say($who, "SWAG!");
    }


    if($msg eq "help") {
        $boha->say($who, "sintassi: help <botlet> [<topic>]");
        $boha->say($who, "botlet attivi:");
        foreach my $botlet (@Boha::botlet) {
            my $botletname = $botlet;
            $botletname =~ s/^Boha::Botlet:://;
            $boha->say($who, ".    $botletname  ${$botlet.'::VERSION'}");
        }
        return;
    }


# cerco di gestire il caso di help
# richiamando <Botlet>::help(<topic>, <subtopic>)
# se ricevo un pvt: "help <Botlet> <topic> <subtopic>"
    if($msg =~ /^help\s+(.*)$/)
    {
        my($botletname, @param) = split(/\s+/, $1);

        print STDERR "got help '$botletname' '@param'\n";

        foreach my $botlet (@Boha::botlet)
        {
            next unless ($botlet =~ /$botletname$/i);

            $event = $botlet."::help";
            print STDERR "DBG irc_msg | trying calling $event ()\n";
            if( defined &{$event} )
            {
                &{$event}($boha, $who, @param);
                return;
            } else {
                $boha->say($who, "sorry, '$botletname' non ha nessun help");
                return;
            }
        }
        $boha->say($who, "botlet sconosciuto: '$botletname'");
        $boha->say($who, "digita soltanto 'help' per un elenco dei botlet attivi");
        return;
    }

    dispatch('onPrivate', $who, $rcpt, $msg);
}

sub irc_notice {
    my($kernel, $who, $rcpt, $msg) = @_[KERNEL, ARG0 .. ARG2];
    unless($who =~ s/^(.*)!.*$/$1/) {
        warn "weird-ass who: $who";
        return undef;
    }

    if( $who eq "NickServ"
    and $rcpt->[0] eq $boha->{nick}
    and $msg =~ /(\S+) << ONLINE >>/
    ) {
        $boha->auth( $1 );
        for my $i (0..@{$boha->{authq}}-1) {
            my($auth_usr, %event) = @{$boha->{authq}->[$i]};
            next unless $auth_usr eq $1;
            $event{onSuccess}->($auth_usr);
            splice(@{$boha->{authq}}, $i, 1);
        }
    }
    if( $who eq "NickServ"
    and $rcpt->[0] eq $boha->{nick}
    and $msg =~ /Last seen:/
    ) {
        $boha->deauth( $1 );
        for my $i (0..@{$boha->{authq}}-1) {
            my($auth_usr, %event) = @{$boha->{authq}->[$i]};
            next unless $auth_usr eq $1;
            $event{onFailure}->($auth_usr);
            splice(@{$boha->{authq}}, $i, 1);
        }
    }

    dispatch('onNotice', $who, $rcpt, $msg);
}

sub irc_kick {
    my($kernel, $kicker, $chan, $who, $msg) = @_[KERNEL, ARG0 .. ARG3];

    my($kernel, $kicker, $chan, $who, $msg) = @_[KERNEL, ARG0 .. ARG3];

    $who =~ s/^(.*)!.*$/$1/;

    if($who eq $boha->{nick}) {
        my $delay = int(rand()*10)+1;
        print STDERR "rientro tra $delay secondi...\n";
        $boha->todo( $delay, sub { $boha->join( $chan ) });
    }

    dispatch('onKick', $who, $kicker, $msg);
}

sub irc_nick {
    my($kernel, $who, $newnick) = @_[KERNEL, ARG0 .. ARG1];
    dispatch('onNick', $who, $newnick);
}

sub irc_topic {
    my($kernel, $who, $chan, $topic) = @_[KERNEL, ARG0 .. ARG2];

    if($topic ne "" and $who ne 'ChanServ') {
        dispatch('onTopic', $chan, $topic);
    }
}

sub irc_rpl_topic {
    my($kernel, $arg) = @_[KERNEL, ARG1];

    my($chan, $topic) = split(/:/, $arg, 2);
    $chan =~ s/^\s+//;
    $chan =~ s/\s+$//;
    $topic =~ s/^\s+//;
    $topic =~ s/\s+$//;

    dispatch('onTopic', $chan, $topic);
}

# sub irc_mode {
#     $boha->say( 'dada', "MODE: @_ ");
#     $boha->say( 'dada', "ARG0: ".$_[ARG0] );
#     $boha->say( 'dada', "ARG1: ".$_[ARG1] );
#     $boha->say( 'dada', "ARG2: ".$_[ARG2] );
#     $boha->say( 'dada', "ARG3: ".$_[ARG3] );
# }

####
#### CODICE BOHA (dispatch degli eventi)
####

sub mainloop {

    if(@{$boha->{todo}}) {
        foreach my $i (0..$#{$boha->{todo}}) {
            $boha->{todo}[$i][0]--;
            if($boha->{todo}[$i][0] <= 0) {
                #### our time has come...
                &{ $boha->{todo}[$i][1] };
                splice @{ $boha->{todo} }, $i++, 1;
            }
        }
    }

    dispatch('onTimer');
    $_[KERNEL]->delay( 'mainloop', 1 );
}

sub dispatch {
    my($action, @param) = @_;

    foreach my $botlet (sort { ${$a."::priority"} <=> ${$b."::priority"} } @Boha::botlet) {
        $event = $botlet."::$action";
        # warn "dispatching to $botlet\n";
        if( defined &{$event} ) {
            #if($action ne "onTimer") {
            #    print "dispatch -> $event\n";
            #}
            last if &{$event}($boha, @param);
        }
    }
}

####
#### METODI SOAP
####

sub get_karma {
    my $response = $_[ARG0];
    my(undef, $what) = each( %{ $response->soapbody });
    my $karma = Boha::Botlet::Karma::get_karma($what);
    # print "get_karma: $what=$karma\n";
    $karma ||= "boh";
    $response->content($karma);
    $_[KERNEL]->post( 'bohaSOAPservice', 'DONE', $response );
}

sub get_fact {
    my $response = $_[ARG0];
    my $fact = Boha::Botlet::Factoid::random_fact();
    Encode::from_to($fact, 'iso-8859-1', 'utf-8', 1);
    $response->content( $fact );
    $_[KERNEL]->post( 'bohaSOAPservice', 'DONE', $response );
}
