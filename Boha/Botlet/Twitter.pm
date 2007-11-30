# "la cazzata del momento" -- larsen

package Boha::Botlet::Twitter;

use LWP::UserAgent;

$VERSION = '$Id: Twitter.pm,v 1.2 2007/02/07 11:51:00 dada Exp $';
$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;
my $agent = LWP::UserAgent->new();

my $twitter_url = "http://twitter.com/statuses/update.json";

#sub onPublic {#    my($bot, $who, $chan, $msg) = @_;#    my $nick = $bot->{ nick };#    return unless $msg =~ /^$nick: (.*)$/;#    my $cmd = $1;#    if ( $cmd =~ /^twitter\s+(.*)$/ ) {#        $bot->say($who, update_twitter($1));#    }#}
sub onTopic {
	my($bot, $chan, $topic) = @_;
	print "Twitter.onTopic($chan, $topic)\n";
	if(update_twitter($topic) !~ /200 OK/i) {
		$bot->say($bot->{chan}, "poor boha"); 
	}
}

sub help {	my($bot, $who, $topic) = @_;	$bot->say($who, "Twitter botlet $VERSION");	$bot->say($who, "none of your business");
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
