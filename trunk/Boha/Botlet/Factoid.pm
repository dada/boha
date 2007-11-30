# faqtoid botlet

package Boha::Botlet::Factoid;

use Data::Dumper;

$VERSION = '$Id: Factoid.pm,v 1.11 2007/01/30 17:03:50 dada Exp $';
$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;

my $last = 0;
my $random_after = 3600; # 15 min idle
my $verbose = 0;
my $last_fact_added = 0;

sub onTimer {
	my $bot = shift;
	
	if($last == 0) {
		$last = time + $random_after;
		return;
	}
	
	return if(time < $last + $random_after);

	print "FACTOIDS onIdle triggered!\n";
	my @list;
	open(FH, "data/facts.txt");
	while(<FH>)
	{
		#non le setto tutte... si fa prima
		chomp;
		push @list, "$_" if(rand() < 0.25);
	}
	close(FH);

	$last = time + $random_after;

	return if($#list==0);
	
	my $r = $list[int rand($#list)];	
	$r =~ /([^:]+):\s*(.*)$/ || return;

	if($verbose) {
		$bot->say($bot->{chan}, "$2 [$1]"); 
	} else {
		$bot->say($bot->{chan}, "$2"); 
	}
}

sub onPublic {
	my($bot, $who, $chan, $msg) = @_;

	$last = time;

	my $nick = $bot->{nick};
	
	return unless $msg =~ /^$nick: (.*)$/;
	
	$cmd = $1;

	if(lc($cmd) eq 'sii verboso') {
		$verbose = 1;
		return 0;
	}
	
	if(lc($cmd) eq 'sii umano') {
		$verbose = 0;
		return 0;
	}

	if($cmd =~ /^(ricorda che|ricorda)[ ]+(.*)$/)
	{
		addfact($who, $2);
		#if($who eq 'larsen') {
		#	$bot->say($chan, "roger, pacco");
		#} else {
			$bot->say($chan, "roger, capo");
		#}
	}

	if($cmd =~ /^(dimentica|undo)!*$/i) 
	{
		if(killfact($who)) {
			$bot->say($chan, "opac ,regor");
		} else {
			$bot->say($chan, "$who: niet!");
		}
	}

	print "received cmd: '$cmd'\n";

	if($cmd =~ /^(.*)\?$/)
	{
		my $from;
		my $what = $1;
		
		$from = $1 if($what =~ s/by ([^ ]+)//);

		my $t = searchfact($what, $from);
		
		if(length($t)<4)
		{
			return;
		}
		my @results = split /\n/, $t;

		my $ct=80;
		while(1)
		{
			my $max = 1+$#results;
			my $r = int(rand()*$max);
			if(rand()*60 < $ct)
			{
				$r = int(rand()*(1+$r));
			}

			if ($ct<0 || !has_already_told($results[$r]))
			{
				# $bot->say($chan, $who.": ".$results[$r]."[$r/$max]");
				if($verbose) {
					$bot->say($chan, $who.": ".$results[$r]."[$r/$max]");
				} else {
					$results[$r] =~ s/\[[^\]]+\]$//;
					$bot->say($chan, $who.": ".$results[$r]);
				}
				return;
			}
			$ct--;
		}
	}
}

sub has_already_told
{
	my $s = shift;
	foreach my $old (@::told)
	{
		if($old eq $s)
		{
			return 1;
		}
	}
	shift @::told if ($#::told > 100);
	push @::told, $s;

	return 0;
}


sub addfact
{
	my $who = shift;
	my $fact = shift;
	$fact =~ s/[\r\n]+//g;

	open(FACTS, ">>data/facts.txt");
	print FACTS "$who: $fact\n";
	close FACTS;
	
	my $last_fact_added = time;
}

sub killfact
{
	my $who = shift;

	open(FACTS, "data/facts.txt");
	my @facts = ();

	while(<FACTS>) {
		push(@facts, $_);
	}
	close(FACTS);
	if($facts[-1] =~ /^$who:/ && $last_fact_added + 60 <= time) {
		pop(@facts);
		open(FACTS, ">data/facts.txt");
		foreach my $fact (@facts) {
			print FACTS $fact;
		}
		close(FACTS);
		return 1;
	} else {
		return 0;
	}
}

sub searchfact
{
	my $what = lc shift;
	my $whof = lc shift;
	my %res;
	my %inv;
	$what =~ s/[^a-zA-Z0-9]/ /g;
	$what =~ s/^[ ]+/ /g;
	$what =~ s/[ ]+$/ /g;
	open(FACTS, "data/facts.txt");
	my $lnct = 0;
	while(<FACTS>)
	{
		$lnct++;
		chop;
		my ($who, $fact) = split /: /, $_, 2;

		#verifica che l'utente sia $whof
		next if $whof && $whof ne lc $who;

		$qfact = lc $fact;
		$qfact =~ s/[^a-zA-Z0-9]/ /g;
		$fact = "$fact [$lnct:$who]";
		foreach my $w (split / +/, $what)
		{
			next if length($w)<3;

			if($qfact =~ /$w/)
			{
				my $score = int 10000/(60+length($`));
#print "[DBG] $qfact /$w/ score: $score\n";
				$inv{$fact} += $score;
				#$res{$score} .= $fact." ($score)\n";
			}

			chop($w);
			next if length($w)<3;

			if($qfact =~ /\b$w/)
			{
				my $score = int 5000/(60+length($`));
#print "[DBG] $qfact /$w/ score: $score\n";
				$inv{$fact} += score;
				#$res{$score} .= $fact." ($score)\n";
			}
		}
	}

	my $result;
	foreach my $k (sort {$inv{$b} <=> $inv{$a}} keys %inv)
	{
		$result .= $k."\n";
	}

	return $result;
}

sub random_fact {
	open(FACTS, "data/facts.txt");
	my @facts = ();
	while(<FACTS>) {
		chomp;
		my ($who, $fact) = split /: /, $_, 2;
		push(@facts, $fact);
	}
	close(FACTS);
	return $facts[ rand scalar @facts ];
}
	
1;
