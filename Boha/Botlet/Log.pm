package Boha::Botlet::Log;

$VERSION = '$Id: Log.pm,v 1.4 2004/03/24 16:37:22 dada Exp $';
$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;

{

	my $path_file_di_log='data/log/';
#	my $file_aperto=0;

	sub onPublic {
		my($bot, $who, $chan, $msg) = @_;
		$who = nick($bot, $who);
		$chan = join ':', @$chan;
		logit("PRIVMSG $who $chan $msg");
	}

	sub onJoin {
		my ($bot, $who, $chan) = @_;
		$chan = join ':', @$chan;
		$who = nick($bot, $who);
		logit("JOIN $who $chan");
	}

	sub onPart {
		my ($bot, $who, $chan) = @_;
		$chan = join ':', @$chan;
		$who = nick($bot, $who);
		logit("PART $who $chan");
	}

	sub nick {
		my ($bot, $who) = @_;
		$who = "~$who" unless $bot->is_registered($who);
		return $who;
	}

	sub logit {
		my ($msg) = @_;
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
		$year=substr($year,1);
		$mon=($mon<10) ? "0$mon" : $mon;
		$mday=($mday<10) ? "0$mday" : $mday;

		my $nome_file_data_corrente=$path_file_di_log.$mday.'_'.$mon.'_'.$year.'.txt';

#		if (-e $nome_file_data_corrente) {
#
#			open FILE, ">>$nome_file_data_corrente" if (!$file_aperto);
#
#		} else {
#
#			close FILE if ($file_aperto);
#			open FILE, ">$nome_file_data_corrente";
#		}


#		local $|=1;

		open FILE, ">>$nome_file_data_corrente";
		print FILE time." $msg\n";
		close FILE;

#		$file_aperto=1;
	}
}

1;

