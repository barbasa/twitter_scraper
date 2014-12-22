package Event;

use Moose;
use EventTypes;
use Gearman::Client;
use Gearman::Task;
use Data::Dumper;
use YAML::XS;
use Storable qw(freeze thaw);

has action      => (is => 'rw', isa => 'Action',   required => 1,);
#TODO payload might be an object
has payload     => (is => 'rw', required => 0, default => sub {});
has next_event  => (is => 'rw', isa => 'Action', required => 0, lazy => 1, default => \&_get_next_event);
#TODO taskset move default in a function
has taskset     => (is => 'ro', isa => 'Gearman::Taskset', lazy => 1, default => sub {
                                                            my $client = Gearman::Client->new;
                                                            $client->job_servers('127.0.0.1');
                                                            $client->new_task_set; });


sub broadcast {
    my ($self) = @_;

    print "Broadcasting ".$self->action."\n";
    my $serialized_data = freeze($self);
    my $task = Gearman::Task->new(
                $self->action,
                \$serialized_data,
                {
                    on_complete => sub { print "Action '".$self->action."' terminated! "; }
                }
    );

    $self->taskset->add_task($task);
    $self->taskset->wait;
    return 1;
}

sub send_next {
    my ($self, $payload) = @_;

    if ($self->next_event eq 'NONE') {
       print "Event chain finished!\n"; 
       return 0;
    }

    print "\nSending next event...".$self->next_event."\n";

    my $event = Event->new(
        action  => $self->next_event,
        payload => $payload,
    );
    $event->broadcast;
    return 1;
}

sub _get_next_event {
    my ($self) = @_;    
    
    my $event_chain = YAML::XS::LoadFile('conf/EventChain.yaml');

    return $event_chain->{$self->action}->{next};
}

sub deserialize { thaw($_[0]) }

__PACKAGE__->meta->make_immutable;
