# Karma police


package Boha::Botlet::Karma;

use Storable;


$VERSION = '$Id: Karma.pm,v 1.20 2007/10/05 15:01:00 dada Exp $';

$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;

my $karma_place = 'data/karma';
my $karma = {};

sub onInit {
	$Storable::accept_future_minor = 1;
	$karma = retrieve( $karma_place ) if -e $karma_place;
	delete $karma{""};
}

sub onPublic {
    my($bot, $who, $chan, $msg) = @_;
    my $nick = $bot->{ nick };

    # Per adesso vengono registrare variazioni di karma 
    # solo quando ci si rivolge esplicitamente a boha.


    # tranne questa... ;-)
    if($who eq 'dree' and $msg =~ /\bold\b/) {
        $karma->{dree}--;
        store $karma, $karma_place;
        $bot->say( $chan, "dree: buuuh" );
    }


    return unless $msg =~ /^$nick: (.*)$/;
    my $cmd = $1; 

    if ( $cmd =~ /^karma\s+(.*)$/ ) {
	my $key = get_karma_key($1);
        $bot->say( $chan, $karma->{ $key } ) if exists $karma->{ $key };

    } elsif ( $cmd =~ /^(\s*top\s*)?karma$/i ) {
	my %rank = ();
	my $msg = "TOP 10: ";
	my %exceed = ();	
	foreach my $k (sort keys %$karma) {
		if(defined $rank{$karma->{$k}}) {
			if(length($rank{$karma->{$k}}) > 60) {
				$exceed{$karma->{$k}}++;
			} else {
				$rank{$karma->{$k}} = $rank{$karma->{$k}}.", $k";
			}
		} else {
			$rank{$karma->{$k}} = $k;
		}
	}

	my $i = 0;
	foreach my $k (sort {$b <=> $a} keys %rank) {
		last if $i++ == 10;
		if($exceed{$k}) {
			$rank{$k} .= " + altri " . $exceed{$k};
		}
		$msg .= "$i. $rank{$k} ($k); ";
	}
	$bot->say( $chan, $msg );

    
    }

    elsif ( $cmd =~ /^\s*worst\s*karma$/i ) {
	my %rank = ();
	my $msg = "WORST 10: ";
	my %exceed = ();	
	foreach my $k (sort keys %$karma) {
		if(defined $rank{$karma->{$k}}) {
			if(length($rank{$karma->{$k}}) > 60) {
				$exceed{$karma->{$k}}++;
			} else {
				$rank{$karma->{$k}} = $rank{$karma->{$k}}.", $k";
			}
		} else {
			$rank{$karma->{$k}} = $k;
		}
	}
	$msg .= say10( sub { $a <=> $b }, \%rank, \%exceed);	
	$bot->say( $chan, $msg );
    }

    elsif ( $cmd =~ /^(.*)\+\+/ and $1 ) {
        my $key = get_karma_key($1);
        $karma->{ $key }++;
        store $karma, $karma_place;
    }

    elsif ( $cmd =~ /^(.*)--/ and $1 ) {
        my $key = get_karma_key($1);
        $karma->{ $key }--;
        store $karma, $karma_place;
    }
}



sub onPrivate {

	my($bot, $who, $rcpt, $msg) = @_;

	if($msg eq "karma") {

		$bot->say($who, "TOP 10:");

		my %rank = ();	
		my %exceed = ();
		foreach my $k (sort keys %$karma) {
			if(defined $rank{$karma->{$k}}) {
				if(length($rank{$karma->{$k}}) > 60) {
					$exceed{$karma->{$k}}++;
				} else {
					$rank{$karma->{$k}} = $rank{$karma->{$k}}.", $k";
				}
			} else {
				$rank{$karma->{$k}} = $k;
			}
		}

		$bot->say($who, say10( sub { $b <=> $a }, \%rank, \%exceed));

	}

	if($msg eq "karma worst") {
		$bot->say($who, "WORST 10:");
		my %rank = ();
		my %exceed = ();
		foreach my $k (sort keys %$karma) {
			if(defined $rank{$karma->{$k}}) {
				if(length($rank{$karma->{$k}}) > 60) {
					$exceed{$karma->{$k}}++;
				} else {
					$rank{$karma->{$k}} = $rank{$karma->{$k}}.", $k";
				}
			} else {
				$rank{$karma->{$k}} = $k;
			}
		}

		$bot->say($who, say10( sub { $a <=> $b }, \%rank, \%exceed));

	}

}


sub say10 {
	my($sort, $rank, $exceed) = @_;
	my $msg = "";
	my $i = 0;
	foreach my $k (sort { $sort->() } keys %$rank) {
		last if $i++ == 10;
		if($exceed->{$k}) {
			$rank->{$k} .= " ... (altri $exceed->{$k})";
		}		
		$msg .= "$i. $rank->{$k} ($k); ";
	}
	$msg =~ s/; $//;
	return $msg;
}


sub onQuit {

    store $karma, $karma_place;

}



sub help {

	my($bot, $who, $topic) = @_;

	

	$bot->say($who, "Karma botlet $VERSION");

	map { $bot->say($who, "per $_") } (
		"incrementare il karma di un utente: '$bot->{nick}: <utente>++'",
		"decrementare il karma di un utente: '$bot->{nick}: <utente>--'",
		"visualizzare il karma di un utente: '$bot->{nick}: karma <utente>'",
		"visualizzare il karma dei migliori 10: 'karma' in query",
		"visualizzare il karma dei peggiori 10: 'karma worst' in query",
	);

}



sub get_karma_key {
	my($key) = @_;
	my $wanted = uc($key);
	foreach my $k (keys %$karma) {
		return $k if uc($k) eq $wanted;
	}
	return $key;
}


1;

__END__

onInit();

my %rank = ();	
my %exceed = ();
foreach my $k (sort keys %$karma) {
	if(defined $rank{$karma->{$k}}) {
		if(length($rank{$karma->{$k}}) > 60) {
			$exceed{$karma->{$k}}++;
		} else {
			$rank{$karma->{$k}} = $rank{$karma->{$k}}.", $k";
		}
	} else {
		$rank{$karma->{$k}} = $k;
	}
}

print "TOP 10:\n";
print say10( sub { $b <=> $a }, \%rank, \%exceed), "\n";
print "WORST 10:\n";
print say10( sub { $a <=> $b }, \%rank, \%exceed), "\n";
