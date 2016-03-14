# "la cazzata del momento" -- larsen

package Boha::Botlet::Twitter;

use YAML;
use Net::Twitter;
use Encode;

$VERSION = '$Id: Twitter.pm,v 1.2 2007/02/07 11:51:00 dada Exp $';
$VERSION =~ /v ([\d.]+)/;
$VERSION = $1;

my %known_twitterers = (
    boha => '@boha',
);

#sub onPublic {
#    my($bot, $who, $chan, $msg) = @_;
#    my $nick = $bot->{ nick };
#    return unless $msg =~ /^$nick: (.*)$/;
#    my $cmd = $1;
#    if ( $cmd =~ /^twitter\s+(.*)$/ ) {
#        $bot->say($who, tweet($1));
#    }
#}

sub onTopic {
    my($bot, $chan, $topic) = @_;
    print "Twitter.onTopic($chan, $topic)\n";
    if(not tweet($topic)) {
        $bot->say($bot->{chan}, "poor boha");
    }
}

sub help {
    my($bot, $who, $topic) = @_;
    $bot->say($who, "Twitter botlet $VERSION");
    $bot->say($who, "none of your business");
}

sub tweet {
    my($msg, $mentions) = @_;
    my $yaml = YAML::LoadFile("data/twitter.yml");
    return 0 unless $yaml;
        my $twitter = Net::Twitter->new(
        traits              => [qw/API::RESTv1_1/],
        apiurl              => 'https://api.twitter.com/1.1',
        consumer_key        => $yaml->{consumer_key},
        consumer_secret     => $yaml->{consumer_secret},
        access_token        => $yaml->{oauth_token},
        access_token_secret => $yaml->{oauth_token_secret},
    );

    if($mentions) {
        while(my($nick, $twitter_username) = each %known_twitterers) {
            $msg =~ s/\b$nick\b/$twitter_username/g;
        }
        $msg =~ s{\A@}{.@}; # dakkar++
    }
    if(length($msg) <= 140) {
        my $response = eval { $twitter->update( Encode::decode('utf8', $msg) ) };
        return $response;
    } else {
        return undef;
    }
}

sub undo_tweet {
    my($tweet_id) = @_;
    my $yaml = YAML::LoadFile("data/twitter.yml");
    return 0 unless $yaml;
        my $twitter = Net::Twitter->new(
        traits              => [qw/API::RESTv1_1/],
        apiurl              => 'https://api.twitter.com/1.1',
        consumer_key        => $yaml->{consumer_key},
        consumer_secret     => $yaml->{consumer_secret},
        access_token        => $yaml->{oauth_token},
        access_token_secret => $yaml->{oauth_token_secret},
    );

    my $response = eval { $twitter->destroy_status( $tweet_id ) };
    return $response;
}
1;
