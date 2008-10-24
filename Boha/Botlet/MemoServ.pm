# MemoServ

package Boha::Botlet::MemoServ;

use Storable;

$VERSION = '$Id: MemoServ.pm,v 1.13 2004/03/24 18:17:02 dada Exp $';

$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;

my $memo_place = 'data/memo';
my $memo = {};

####
# $memo = {
#     "dada:oha:1" => "FYBB",
# }

sub onInit {
    $memo = retrieve( $memo_place ) if -e $memo_place;
}

sub onPublic {
    my($bot, $who, $chan, $msg) = @_;
}

sub onPrivate {
	my($bot, $who, $rcpt, $msg) = @_;
	
	if($msg =~ /^memo\s+(per\s+)?(\w+):\s*(.*$)/) {	
		my $to = $2;
		my $text = $3;
		my $id = next_id($who);
		$memo->{"$who:$to:$id"} = $text;
		store $memo, $memo_place;
	}
		
	if($msg =~ /^anonimemo\s+(per\s+)?(\w+|\*):\s*(.*$)/) {	
		my $to = $2;
		my $text = $3;
		my $id = next_id("*");
		$memo->{"*:$to:$id"} = $text;
		store $memo, $memo_place;
	}

	if($msg eq "memo") {	
		foreach my $m (get_memo(from => $who)) {
			my($key, $from, $to, $id) = @$m;
			$bot->say($who, "[$id] $to: $memo->{$key}");
		}
		$bot->say($who, "fine dei tuoi memo.");
	}
	
	if($msg eq "anonimemo") {	
		foreach my $m (get_memo(from => '*')) {
			my($key, $from, $to, $id) = @$m;
			$bot->say($who, "[$id] $to: $memo->{$key}");
		}
		$bot->say($who, "fine dei memo.");
	}

	if($msg =~ /^memo delete (\d+)/) {
		my $wanted = $1;
		foreach my $m (get_memo(from => $who)) {
			my($key, $from, $to, $id) = @$m;
			if($id == $wanted) {
				delete $memo->{$key} ;
				store $memo, $memo_place;
				return;
			}
		}
		$bot->say($who, "errore: no such memo '$id'");
	}

	if($msg =~ /^anonimemo delete (\d+)/) {
		my $wanted = $1;
		foreach my $m (get_memo(from => '*')) {
			my($key, $from, $to, $id) = @$m;
			if($id == $wanted) {
				delete $memo->{$key} ;
				store $memo, $memo_place;
				return;
			}
		}
		$bot->say($who, "errore: no such memo '$id'");
	}
}

sub onJoin {
	my($bot, $who, $chan) = @_;	
	my $done;
	return if $who eq $bot->{nick};
	foreach my $m (get_memo(to => $who)) {
		my($key, $from) = @$m;
		if($from eq '*') {
			my $memo = $memo->{$key};
			$memo =~ s/<nick>/$who/g;
			$bot->say($chan, $memo);
			$done = 1;
		} else {
			$bot->say($who, "messaggio da $from: $memo->{$key}");
			delete $memo->{$key};
			store $memo, $memo_place;
		}
	}
	if(not $done) {
	
		# try channel anonimemo
		if(my $changreet = get_memo(to => $chan)) {
			$memo = '$who: '.$changreet;		
			$bot->say($chan, $memo);
		} else {
			my @anonimemo = get_memo(both => '*');
			return unless @anonimemo;
			my $pick = rand()*$#anonimemo;
			my $m = $anonimemo[$pick];
			my($key, $from) = @$m;
			my $memo = $memo->{$key};
			$memo =~ s/<nick>/$who/g;
			$bot->say($chan, $memo);
		}
	}
}

sub onQuit {
    store $memo, $memo_place;
}

sub help {
	my($bot, $who, $topic) = @_;
	
	$bot->say($who, "MemoServ botlet $VERSION");
	map { $bot->say($who, "per $_") } (
		"aggiungere un memo: /msg $bot->{nick} memo per <utente>: <testo>",
		"visualizzare i memo inseriti: /msg $bot->{nick} memo",
		"cancellare un memo: /msg $bot->{nick} memo delete <N>",
	);
}

sub get_memo {
	my($idx, $user) = @_;
	my %grepfunc = (
		from => sub { $_->[1] eq $user },
		to   => sub { $_->[2] eq $user },
		both => sub { $_->[1] eq $user and $_->[2] eq $user },
	);
	return sort { $a->[3] <=> $b->[3] }
	       grep &{ $grepfunc{$idx} },
	       map  { [$_, split /:/] }
	       keys %$memo;	
}

sub next_id {
	my($from) = @_;
	my $next_id = 0;
	foreach my $m (keys %$memo) {
		next unless $m =~ /^$from:/;	
		my($from, $to, $id) = split(/:/, $m);		
		$next_id = $id if $id > $next_id; 
	}
	return ++$next_id;
}

1;
