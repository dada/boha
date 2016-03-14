# core
package Boha;

use POE;
use POE::Component::IRC;

use vars qw/ $VERSION @botlet /;

$VERSION = "2.05";

@botlet = ();


sub init {
    my($self) = @_;
    @botlet = ();
    my @result = ();
    foreach my $botlet (<Boha/Botlet/*.pm>) {

        $botlet =~ s|/|::|g;
        $botlet =~ s|\.pm||;

        my $botletname;
        ($botletname = $botlet) =~ s/Boha::Botlet:://;

        eval "use $botlet";
        if($@) {
            push(@result, "ERRORE in $botletname: $@");
        } else {
            push(@botlet, $botlet);
            push(@result, "$botletname ${$botlet.'::VERSION'}");
        }
    }
    #### permettiamo ai moduli di inizializzarsi
    main::dispatch('onInit');
    return @result;
}

sub new {
    my($class, $poe_kernel) = @_;
    return bless {
        kernel => $poe_kernel,
        host => undef,
        port => 6667,
        nick => undef,
        auth => { },
        todo => [ ],
        authq => [ ],
    };
}

sub go {
    my($self) = @_;
    $self->{kernel}->run();
}

sub join {
    my($self, $channel) = @_;
    $self->{kernel}->post( 'boha', 'join', $channel );
}

sub part {
    my($self, $channel) = @_;
    $self->{kernel}->post( 'boha', 'part', $channel );
}

sub say {
    my($self, $channel, $message) = @_;
    $self->{kernel}->post( 'boha', 'privmsg', $channel, $message );
}

sub post {
    my $self = shift;
    $self->{kernel}->post( 'boha', @_);
}

sub auth {
    my($self, $who) = @_;
    $self->{auth}->{$who} = 1;
}

sub deauth {
    my($self, $who) = @_;
    $self->{auth}->{$who} = 0;
}

sub is_registered {
    my($self, $who) = @_;
    if(exists $self->{auth}->{$who}) {
        return $self->{auth}->{$who};
    } else {
        $self->say( 'NickServ', "INFO $who" );
        return undef;
    }
}

sub todo {
    my($self, $time, $action) = @_;
    push(@{$self->{todo}}, [ $time, $action ]);
}

sub auth_cmd {
    my($self, $who, %events) = @_;
    if(exists $self->{auth}->{$who}) {
        if($self->{auth}->{$who}) {
            $events{onSuccess}->($who);
        } else {
            $events{onFailure}->($who);
        }
    } else {
        $self->say( 'NickServ', "INFO $who" );
        push(@{$self->{authq}}, [ $who, %events ]);
    }

}

1;
