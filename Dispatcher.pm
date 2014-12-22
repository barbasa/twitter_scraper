package Dispatcher;

use Moose;
with 'MooseX::Traits';
has '+_trait_namespace' => ( default => 'Dispatcher' );

use Event;

sub dispatch {
    my ($job, $event) = @_;

    my $action = Dispatcher->with_traits($event->action)->new( payload => $event->payload );
    my $new_payload = $action->execute;

    $event->send_next($new_payload);
}

around 'dispatch' => sub {
    my $orig = shift;
    my $self = shift;

    my $event = Event::deserialize($self->arg);
    my $res = $self->$orig(@_, $event);
};

__PACKAGE__->meta->make_immutable;
