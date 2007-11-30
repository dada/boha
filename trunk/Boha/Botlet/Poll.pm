# faqtoid botlet

package Boha::Botlet::Poll;

use Storable;

$VERSION = '$Id: Poll.pm,v 1.11 2003/06/11 14:16:14 dada Exp $';

$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;

$poll_place = "data/polls";
my $polls = {};
# esempio:
# $polls = {
#     "nome_rivista" => {
#         "topic" => "Che nome diamo alla rivista?",
#         "open"  => 1,
#         "votes" => [
#             [ "perl.it" => "dada", "oha" ],
#             [ "Perl Magazine" => "valdez", "bronto" ],
#             [ "PerlAge" => "gmax" ],
#         ],
#     },
# };

sub onInit {
	my $bot = shift;
	if(-e $poll_place) {
    	$polls = retrieve( $poll_place );
    } else {
    	store $polls, $poll_place;
    }
}

sub onPublic {
	my($bot, $who, $chan, $msg) = @_;
	my $nick = $bot->{nick};	
	return unless ($msg =~ /^(poll|polls)$/);
}

sub onPrivate  {
	my($bot, $who, $rcpt, $msg) = @_;

	if(lc($msg) eq "polls") {
		poll_list($bot, $who);
		return;
	}

	if($msg =~ /^poll\s+(new|add|vote|stat|delete|scratch)\s*(.*)$/i) {
		if($1 eq "new") {
			my($poll, $topic) = split(/\s+/, $2, 2);
			poll_new($bot, $who, $poll, $topic);
			return;
		}
		if($1 eq "add") {
			my($poll, $vote) = split(/\s+/, $2, 2);
			poll_add($bot, $who, $poll, $vote);
			return;
		}
		if($1 eq "vote") {
			my($poll, $vote) = split(/\s+/, $2, 2);
			poll_vote($bot, $who, $poll, $vote);
			return;
		}
		if($1 eq "stat") {
			poll_stat($bot, $who, $2);
			return;
		}
		if($1 eq "delete") {
			poll_delete($bot, $who, $2);
			return;
		}
		if($1 eq "scratch") {
			poll_scratch($bot, $who);
			return;
		}

		$bot->say($who, "comando sconosciuto: '$1'.");
		$bot->say($who, "digita '/msg $bot->{nick} help Poll' per aiuto");
		return;
	}
}

sub poll_list {	
	my($bot, $who) = @_;

	$bot->say($who, "Poll attivi:");

	my $said = 0;
	foreach my $poll (keys %$polls) {
		next unless $polls->{$poll}->{open};
		$bot->say($who, "$poll -> $polls->{$poll}->{topic}");
		$said = 1;	
	}
	$bot->say($who, ($said) ? "fine dei poll." : "nessun poll attivo.");
}

sub poll_stat {
	my($bot, $who, $poll) = @_;

	unless(exists $polls->{$poll}) {
		$bot->say($who, "errore: il poll '$poll' non esiste.");
		return;
	}

	$bot->say($who, "$polls->{$poll}->{topic}:");
	
	my @votes = @{ $polls->{$poll}->{votes} };
	
	my $i = 1;
	foreach my $vote (@votes) {
		my @vote = @$vote;
		$bot->say($who, sprintf("%d. (%d) %s: %s",
			$i++,
			scalar(@vote)-1,
			$vote[0],
			join(", ", @vote[1..$#vote])
		));
	}
	$bot->say($who, "fine del poll.");
}

sub poll_vote {
	my($bot, $who, $poll, $vote) = @_;

	unless(exists $polls->{$poll}) {
		$bot->say($who, "errore: il poll '$poll' non esiste.");
		return;
	}
	unless($polls->{$poll}->{open}) {
		$bot->say($who, "errore: il poll '$poll' è chiuso.");
		return;
	}

	# rimuove il voto dell'utente se aveva già votato
	my $votes = $#{ $polls->{$poll}->{votes} };
	foreach my $vote (0..$votes) {
		my @vote = @{ $polls->{$poll}->{votes}->[$vote] };
		my $option = shift @vote;
		$polls->{$poll}->{votes}->[$vote] = [ 
			$option, 
			grep $_ ne $who, @vote
		];
	}

	push(@{ $polls->{$poll}->{votes}->[$vote-1] }, $who);
	store $polls, $poll_place;
	$bot->say($who, "ricevuto");
}


sub poll_new {
	my($bot, $who, $poll, $topic) = @_;
	
	if(exists $polls->{$poll}) {
		$bot->say($who, "errore: il poll '$poll' esiste già.");
		return;
	}
	
	$polls->{$poll} = {
		topic => $topic,
		open  => 1,
		votes => [],
	};
	store $polls, $poll_place;
	$bot->say($who, "ricevuto");
}
	
sub poll_add {
	my($bot, $who, $poll, $option) = @_;

	unless(exists $polls->{$poll}) {
		$bot->say($who, "errore: il poll '$poll' non esiste.");
		return;
	}
	unless($polls->{$poll}->{open}) {
		$bot->say($who, "errore: il poll '$poll' è chiuso.");
		return;
	}
	
	push( @{ $polls->{$poll}->{votes} }, [$option] );
	store $polls, $poll_place;
	$bot->say($who, "ricevuto");
}

sub poll_close {
	my($bot, $who, $poll) = @_;

	unless(exists $polls->{$poll}) {
		$bot->say($who, "errore: il poll '$poll' non esiste.");
		return;
	}

	$polls->{$poll}->{open} = 0;
	store $polls, $poll_place;
	$bot->say($who, "ricevuto");
}

sub poll_delete {
	my($bot, $who, $poll) = @_;

	unless(exists $polls->{$poll}) {
		$bot->say($who, "errore: il poll '$poll' non esiste.");
		return;
	}

	delete $polls->{$poll};
	store $polls, $poll_place;
	$bot->say($who, "ricevuto");
}

sub poll_scratch {
	my($bot, $who) = @_;

	store {}, $poll_place;
	$bot->say($who, "ricevuto");
}

sub poll_open {
	my($bot, $who, $poll) = @_;

	unless(exists $polls->{$poll}) {
		$bot->say($who, "errore: il poll '$poll' non esiste.");
		return;
	}

	$polls->{$poll}->{open} = 1;
	store $polls, $poll_place;
	$bot->say($who, "ricevuto");
}

sub help {
	my($bot, $who, $topic) = @_;
	
	$bot->say($who, "Poll botlet $VERSION");
	$bot->say($who, "comandi (tutti in query):");
	$bot->say($who, "polls ".
		"==> visualizza i poll attivi");
	$bot->say($who, "poll new <nome> <topic> ".
		"==> crea un nuovo poll");
	$bot->say($who, "poll add <nome> <opzione> ".
		"==> aggiunge un'opzione ad un poll");
	$bot->say($who, "poll stat <nome> ".
		"==> visualizza le opzioni e i risultati del poll");
	$bot->say($who, "poll vote <nome> <N> ".
		"==> vota per l'opzione N");
	$bot->say($who, "poll close <nome> ".
		"==> chiude il poll (non si può più votare)");
	$bot->say($who, "poll open <nome> ".
		"==> apre il poll (si può votare di nuovo)");
	$bot->say($who, "poll delete <nome> ".
		"==> elimina il poll");
	$bot->say($who, "poll scratch ".
		"==> elimina tutti i poll (handle with care)");
}


1;


# poll new nome_rivista Che nome diamo alla rivista?
# poll add nome_rivista perl.it
# poll vote nome_rivista perl.it | 1
# poll view nome_rivista
