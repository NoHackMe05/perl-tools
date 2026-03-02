#!/usr/bin/perl
use strict;
use warnings;
use lib '.';
use DNSResolver;
use Time::HiRes qw(gettimeofday);
use IO::Handle;

# Opening a file for errors (append mode)
open(my $log_fh, '>>', 'resolver_errors.log') or die "Impossible d'ouvrir le log: $!";

# Disable buffering to see results in real time
STDOUT->autoflush(1);

my $start_time = [gettimeofday];
my $count = 0;

my $resolver = DNSResolver->new(
    max_parallel => 1000,
    max_retries  => 0,
    timeout      => 1,
    
    # Processing callback
    on_result => sub {
        my ($ip, $host) = @_;
        $count++;

        if ($host =~ /TIMEOUT|NXDOMAIN|ERROR/) {
            # We log the error with a timestamp in the file
            printf $log_fh "[%s] ERROR: %-15s -> %s\n", scalar(localtime), $ip, $host;
        } else {
            # Success is displayed on STDOUT (CSV format)
            printf "%s,%s\n", $ip, $host;
        }

        # Small visual indicator every 1000 items on STDERR
        warn "\rProcessed: $count" if $count % 1000 == 0;
    },

    on_finish => sub {
        my $elapsed = Time::HiRes::tv_interval($start_time);
        warn sprintf("\nTerminé ! %d IPs traitées en %.2fs (%.2f ips/s)\n", 
            $count, $elapsed, $count/$elapsed);
        close $log_fh;
    }
);

# Launch via STDIN (Large volume management via pipe)
$resolver->run_from_handle(\*STDIN);