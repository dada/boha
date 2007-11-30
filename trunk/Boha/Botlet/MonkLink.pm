# MonkLink botlet

package Boha::Botlet::MonkLink;

$VERSION = '$Id: MonkLink.pm,v 1.4 2004/05/14 13:14:38 dada Exp $';

$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;

sub onPublic {
	my($bot, $who, $chan, $msg) = @_;

	while($msg =~ s!id://(\d+)!!) {
		$bot->say( $chan, "http://www.perlmonks.org/index.pl?node_id=$1" );
	}

	while($msg =~ s!\[(\d+)\]!!) {
		$bot->say( $chan, "http://www.perlmonks.org/index.pl?node_id=$1" ) if $1 > 999;
	}
	
	while($msg =~ s!pad://(\w+)!!) {
		$bot->say( $chan, "http://www.perlmonks.org/index.pl?node_id=108949&user=$1" );
	}

}

1;
