# Karma police

package Boha::Botlet::Karma;
use Storable;

$VERSION = '$Id: Karma.pm,v 1.20 2007/10/05 15:01:00 dada Exp $';
$VERSION =~ /v ([\d.]+)/;
my $karma_place = 'data/karma';
sub onInit {
	$Storable::accept_future_minor = 1;
}
sub onPublic {
    # Per adesso vengono registrare variazioni di karma 

    # tranne questa... ;-)
    if($who eq 'dree' and $msg =~ /\bold\b/) {
        $karma->{dree}--;
        store $karma, $karma_place;
        $bot->say( $chan, "dree: buuuh" );
    }


    return unless $msg =~ /^$nick: (.*)$/;
    if ( $cmd =~ /^karma\s+(.*)$/ ) {
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
    elsif ( $cmd =~ /^(.*)--/ and $1 ) {
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
}

sub get_karma {
	return $karma->{$_[0]};
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