# "la cazzata del momento" -- larsen

package Boha::Botlet::Twitter;

use YAML;
use Net::Twitter;

$VERSION = '$Id: Twitter.pm,v 1.2 2007/02/07 11:51:00 dada Exp $';
$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;

#sub onPublic {
#    my($bot, $who, $chan, $msg) = @_;
#    my $nick = $bot->{ nick };
#    return unless $msg =~ /^$nick: (.*)$/;
#    my $cmd = $1;
#    if ( $cmd =~ /^twitter\s+(.*)$/ ) {
#        $bot->say($who, update_twitter($1));
#    }
#}

sub onTopic {
	my($bot, $chan, $topic) = @_;
	print "Twitter.onTopic($chan, $topic)\n";
	if(not update_twitter($topic)) {
		$bot->say($bot->{chan}, "poor boha"); 
	}
}

sub help {
	my($bot, $who, $topic) = @_;
	$bot->say($who, "Twitter botlet $VERSION");
	$bot->say($who, "none of your business");
}

sub update_twitter {
	my($status) = @_;
	my $yaml = YAML::LoadFile("data/twitter.yml");
	return 0 unless $yaml;
        my $twitter = Net::Twitter->new(
		traits   => [qw/OAuth API::REST/],
		consumer_key        => $yaml->{consumer_key},
		consumer_secret     => $yaml->{consumer_secret},
		access_token        => $yaml->{oauth_token},
		access_token_secret => $yaml->{oauth_token_secret},
	);

	my $response = $twitter->update( $status );
	return $response;
}

1;
