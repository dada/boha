use Test::More qw/no_plan/;

use Boha::Botlet::Seen;

Boha::Botlet::Seen::onInit();

Boha::Botlet::Seen::dump();

print "\n\n";

print Boha::Botlet::Seen::get_message("dada"), "\n";
print Boha::Botlet::Seen::get_message("edoardo"), "\n";
print Boha::Botlet::Seen::get_message("ssaldkjwelrkj"), "\n";
