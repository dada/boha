
package Boha::Botlet::REGame;

$VERSION = '$Id: REGame.pm,v 1.5 2003/05/29 12:15:08 dada Exp $';

$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;

$Boha::Botlet::REGame::re = 's/(\W)(\w[aeiou])/$2$1/g';

sub onPublic {
	my($bot, $who, $chan, $msg) = @_;

	my $nick = $bot->{nick};
	
	if($msg=~/^[rR][eE]: (.*)$/)
	{
		$_ = $1;
		print "RegExping '$_' with '". $Boha::Botlet::REGame::re."'\n";
		eval $Boha::Botlet::REGame::re;
		$bot->say($chan, "$who: '$_'");
	}

	if($msg=~/$Boha::Botlet::REGame::re/)
	{
		$bot->say($chan, "$who: indovinato, la RE era: $Boha::Botlet::REGame::re");
	}
}

1;
