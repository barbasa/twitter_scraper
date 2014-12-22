package Dispatcher::FetchUrl;
use Moose::Role;

use Net::Twitter;

has payload     => (is => 'rw', required => 0, default => sub {});

sub execute {
    my ($self) = @_;

    my $page = $self->payload;
    print "\n**Calling fetchurl execute for page $page\n";    
    my $nt = Net::Twitter->new(legacy => 0);

    #XXX Hardcoded user...needs to go in the payload!
    my $screen_name = '@DRepubblicait';
    my $result = $nt->user_timeline({screen_name => $screen_name, page => $page });
    return $result;
}

1;
