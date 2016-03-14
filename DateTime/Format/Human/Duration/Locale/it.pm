package DateTime::Format::Human::Duration::Locale::it;

use strict;
use warnings;

# 1 year, 1 month, 1 week, 1 day, 1 hour, 1 minute, 1 second, and 1 nanosecond
# 2 years, 2 months, 2 weeks, 2 days, 2 hours, 2 minutes, 2 seconds, and 2 nanoseconds

sub get_human_span_hashref {
    return {
        'no_oxford_comma' => 1,
        'no_time' => 'zero secondi',
        'and'     => 'e',
        'year'  => 'anno',
        'years' => 'anni',
        'month'  => 'mese',
        'months' => 'mesi',
        'week'  => 'settimana',
        'weeks' => 'settimane',
        'day'  => 'giorno',
        'days' => 'giorni',
        'hour'  => 'ora',
        'hours' => 'ore',
        'minute'  => 'minuto',
        'minutes' => 'minuti',
        'second'  => 'secondo',
        'seconds' => 'secondi',
        'nanosecond'  => 'nanosecondo',
        'nanoseconds' => 'nanosecondi',
    };
}

# get_human_span_from_units_array() is used instead of get_human_span_hashref() if get_human_span_from_units_array() exists
#
# sub get_human_span_from_units_array {
#    my ($years, $months, $weeks, $days, $hours, $minutes, $seconds, $nanoseconds, $args_hr) = @_; # note: has no negative numbers
#    ...
#    return $string; # 1 year, 2days, 4 hours, and 17 minutes
# }

1;
