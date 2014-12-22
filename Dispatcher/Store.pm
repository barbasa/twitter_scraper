package Dispatcher::Store;
use Moose::Role;

use DB::Schema;

has payload  => (is => 'rw', required => 0, default => sub {});

sub execute {
    my ($self) =@_;
    
    print "\n**Calling store execute \n";
    my $result = $self->payload; 

    # XXX Schema connection parameter need to go in a better place, not hardcoded! Also the connection needs to be unique, not created every time!
    my $schema = DB::Schema->connect('DBI:mysql:database=tweets', 'root', '');
    
    foreach my $tweet ( @$result ) {
        printf "%-10s %-15s %-8s %s" , "$tweet->{user}{id}", "$tweet->{id}", "$tweet->{user}->{screen_name}","$tweet->{text}\n";
        my $new_tweet = $schema->resultset('Tweet')->new({ text => $tweet->{text}, user_id => $tweet->{user}{id}, });
        $new_tweet->insert;
    }
    return 1; 
}

1;
