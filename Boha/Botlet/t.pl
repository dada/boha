$_ = "1234 oha: prova: ok";

/^(\d+) ([^:]+):(.*)$/;

print "$3 [$1:$2]\n";