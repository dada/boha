# "la cazzata del momento" -- larsen

package Boha::Botlet::Twitter;

use LWP::UserAgent;

$VERSION = '$Id: Twitter.pm,v 1.2 2007/02/07 11:51:00 dada Exp $';
$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;
my $agent = LWP::UserAgent->new();

my $twitter_url = "http://twitter.com/statuses/update.json";

#sub onPublic {
sub onTopic {
	my($bot, $chan, $topic) = @_;
	print "Twitter.onTopic($chan, $topic)\n";
	if(update_twitter($topic) !~ /200 OK/i) {
		$bot->say($bot->{chan}, "poor boha"); 
	}
}

sub help {
}
sub update_twitter {
	my($status) = @_;
	my $response = $agent->post( $twitter_url, { status => $status } );
	return $response->status_line;
}
	

sub LWP::UserAgent::get_basic_credentials {
	my($ua, $realm, $uri, $isproxy) = @_;
	return ("boha", "imaohabot");
}


1;