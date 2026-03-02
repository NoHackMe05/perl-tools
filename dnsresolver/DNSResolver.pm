package DNSResolver;
use Moo;
use AnyEvent;
use AnyEvent::DNS;
use Net::IP;
use namespace::clean;

has 'max_parallel' => ( is => 'ro', default => sub { 500  } );
has 'timeout'      => ( is => 'ro', default => sub { 2    } );
has 'max_retries'  => ( is => 'ro', default => sub { 2    } );
has 'on_result'    => ( is => 'ro', required => 1 );
has 'on_finish'    => ( is => 'ro', required => 1 );

has '_active'      => ( is => 'rw', default => sub { 0    } );
has '_cv'          => ( is => 'ro', default => sub { AnyEvent->condvar } );
has '_fh'          => ( is => 'rw' );

sub BUILD {
    my $self = shift;

    # EDNS0: allows UDP responses up to 4096 bytes (like dig)
    $AnyEvent::DNS::EDNS0 = 1;

    # Reconfigure the global resolver BEFORE any resolution
    # max_outstanding set to 10 by default = major bottleneck
    AnyEvent::DNS::resolver->max_outstanding($self->max_parallel * 2);

    # internal resolver timeout = array of attempts
    # We delegate the retry to our own logic, so only one short attempt
    AnyEvent::DNS::resolver->timeout($self->timeout);
}

sub run_from_handle {
    my ($self, $fh) = @_;
    $self->_fh($fh);
    $self->_process_next();
    $self->_cv->recv;
}

sub _process_next {
    my $self = shift;
    my $fh   = $self->_fh;

    if (eof($fh) && $self->_active == 0) {
        $self->on_finish->();
        $self->_cv->send;
        return;
    }

    while (!eof($fh) && $self->_active < $self->max_parallel) {
        my $raw_ip = <$fh>;
        next unless defined $raw_ip;
        $raw_ip =~ s/^\s+|\s+$//g;
        next if $raw_ip eq '';

        my $ip_obj = Net::IP->new($raw_ip);
        if (!$ip_obj) {
            $self->on_result->($raw_ip, "[INVALID_IP_FORMAT]");
            next;
        }

        $self->_active($self->_active + 1);
        $self->_resolve_with_retry($raw_ip, 0);
    }
}

sub _resolve_with_retry {
    my ($self, $ip, $attempt) = @_;

    my $done = 0;
    my $t;

    $t = AnyEvent->timer(after => $self->timeout, cb => sub {
        return if $done++;
        undef $t;
        if ($attempt < $self->max_retries) {
            $self->_resolve_with_retry($ip, $attempt + 1);
        } else {
            $self->on_result->($ip, "[TIMEOUT_ERROR]");
            $self->_active($self->_active - 1);
            $self->_process_next();
        }
    });

    AnyEvent::DNS::reverse_lookup $ip, sub {
        my @names = @_;          # reverse_lookup may return multiple PTR records
        return if $done++;
        undef $t;

        my $result = @names ? join(',', @names) : "[NXDOMAIN]";
        $self->on_result->($ip, $result);
        $self->_active($self->_active - 1);
        $self->_process_next();
    };
}

1;