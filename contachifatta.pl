open(FACTS, "data/facts.txt");
while(<FACTS>) {
    my($nick, $fact) = split(/:/, $_, 2);
    $fatti{$nick}++;
    push(@facts, $fact);
}
close(FACTS);

print "AUTORI:\n";
foreach my $nick (sort { $fatti{$b} <=> $fatti{$a} } keys %fatti) {

    my $menz = 0;
    foreach my $fact (@facts) {
        $menz++ if $fact =~ /\b\Q$nick\E\b/i;
    }

    $menz{lc $nick} = $menz;

    print "$nick: $fatti{$nick}, ";
}

print "\n\n";

print "MENZIONI:\n";
foreach my $nick (sort { $menz{$b} <=> $menz{$a} } keys %menz) {
    print "$nick: $menz{$nick}, ";
}
