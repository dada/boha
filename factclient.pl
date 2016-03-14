use SOAP::Lite;
use Encode;

# close(STDERR);
my $fact = undef;
# while(not $fact) {
#     eval {
         $fact = SOAP::Lite
             ->uri('http://www.perl.it:52525/')
            ->proxy('http://www.perl.it:52525/?session=bohaSOAP')
            ->get_fact()
            ->result;
#    };
# }

Encode::from_to($fact, 'utf8', 'cp850');
print "\n$fact -- boha\n\n";


