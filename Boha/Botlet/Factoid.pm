# faqtoid botlet

package Boha::Botlet::Factoid;

use Module::Loaded;
use Data::Dumper;

$VERSION = '$Id: Factoid.pm,v 1.11 2007/01/30 17:03:50 dada Exp $';
$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;

our $priority = 99; # low priority botlet

my $last = 0;
my $random_after = 3600; # 15 min idle
my $verbose = 0;
my $last_fact_added = 0;
my $last_author = undef;
my $last_fact = undef;
my $last_fact_tweeted = undef;

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

    my($fact, $author) = ($2, $1);
    if($verbose) {
        $bot->say($bot->{chan}, "$fact [$author]");
    } else {
        $bot->say($bot->{chan}, "$fact");
    }
    $last_author = $author;
    $last_fact = "$fact [$author]";
}

sub onPublic {
    my($bot, $who, $chan, $msg) = @_;

    my $nick = $bot->{nick};

    # non resettiamo il counter per l'onTimer
    # sui nostri stessi messaggi
    $last = time unless $who eq $nick;

    if($msg =~ /^($nick[:,] )?(bella|buona) questa$/ or $msg =~ /^\+\+$/) {
        if(defined $last_author) {
            # ACK! THPPPT!
            Boha::Botlet::Karma::inc($last_author);
            $bot->say($chan, "$last_author++ # $who");
        }
        return 1;
    }

    if($msg =~ /^$nick[:,] pfui$/ or $msg =~ /^\-\-$/) {
        if(defined $last_author) {
            # ACK! THPPPT!
            Boha::Botlet::Karma::dec($last_author);
            $bot->say($chan, "$last_author-- # $who");
        }
        return 1;
    }

    if($msg =~ /^$nick[:,] autore\?$/ or $msg =~ /^\.$/) {
        if(defined $last_fact) {
            $bot->say($chan, "$who: $last_fact");
        }
        return 1;
    }

    if($msg =~ /^$nick[:,] (stupisci|sorprendi)mi$/) {
        $last = time - $random_after - 1;
        onTimer($bot);
        return 1;
    }

    return 0 unless $msg =~ /^$nick[:,] (.*)$/;

    $cmd = $1;

    if(lc($cmd) eq 'sii verboso') {
        $verbose = 1;
        return 1;
    }

    if(lc($cmd) eq 'sii umano') {
        $verbose = 0;
        return 1;
    }

    if($cmd =~ /^(ricorda che|ricorda),?[ ]+(.*)$/)
    {
        addfact($who, $2);
        #if($who eq 'larsen') {
        #    $bot->say($chan, "roger, pacco");
        #} else {
            $bot->say($chan, "roger, capo");
        #}
        return 1;
    }

    if($cmd =~ /^(dimentica|undo)!*$/i)
    {
        if(killfact($who)) {
            $bot->say($chan, "opac ,regor");
        } else {
            $bot->say($chan, "$who: niet!");
        }
        return 1;
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
                my($author) = ($results[$r] =~ /\[\d+:(.*?)\]$/);
                $last_author = $author;
                $last_fact = $results[$r]."[$r/$max]";
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
        return 1;
    }
    return 0;
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

    if(is_loaded('Boha::Botlet::Twitter')
    and Boha::Botlet::Twitter->can('tweet')) {
        my $r = Boha::Botlet::Twitter::tweet($fact, 'with-mentions');
        $last_fact_tweeted = $r->{id};
    } else {
        $last_fact_tweeted = undef;
    }
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
        if(defined $last_fact_tweeted) {
            if(is_loaded('Boha::Botlet::Twitter')
            and Boha::Botlet::Twitter->can('undo_tweet')) {
                my $r = Boha::Botlet::Twitter::undo_tweet($last_fact_tweeted);
                $last_fact_tweeted = undef;
            }
        }
        return 1;
    } else {
        $last_fact_tweeted = undef;
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
    my($author) = @_;
    open(FACTS, "data/facts.txt");
    my @facts = ();
    while(<FACTS>) {
        chomp;
        my ($who, $fact) = split /: /, $_, 2;
        if(defined $author) {
            next unless $who eq $author;
        }
        push(@facts, $fact);
    }
    close(FACTS);
    return $facts[ rand scalar @facts ];
}

1;
