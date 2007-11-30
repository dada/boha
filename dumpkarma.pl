use Data::Dumper;
use Storable;

my $karma_place = 'data/karma';
my $karma = {};

$karma = retrieve( $karma_place );

print Dumper $karma;