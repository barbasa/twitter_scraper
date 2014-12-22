#!/usr/bin/perl -w
use strict;

use Test::More;
use Test::MockObject;

use Event;

# TODO: Need to catch output

# Test broadcast
{
    my $waited = 0;
    my $added_task;
    Test::MockObject->fake_module(
        'Gearman::Taskset',
        new => sub {
            my ($class, $args) = @_; 
            my $self = $args;
            return bless {}, $class;
        },
        add_task => sub { $added_task = $_[1],},
        wait     => sub { $waited = 1 },
    );
    
    my $event = Event->new(
        action  => 'FetchUrl',
        payload => 'test_payload',
    );

    my $resp = $event->broadcast;

    is($resp, 1, 'Check correct exit from broadcast');
    isa_ok($added_task, 'Gearman::Task', );
    is($added_task->func, 'FetchUrl', 'Check task is set correctly');
    #TODO: check payload
    is($waited, 1, 'Check waited for event to finish');
    
}


# Test send_next
{

    my $broadcasted_event;
    Test::MockObject->fake_module(
            'Event',
            _get_next_event => sub {
                    my ($self) = @_;
                    my %NEXT_ACTION = (
                        FetchUrl   => 'store',
                        Store       => 'NONE',
                    );
                    return $NEXT_ACTION{$self->action};
            },
            broadcast => sub { $broadcasted_event = shift; },
    );

     my $event1 = Event->new(
        action  => 'Store',
        payload => 'test_payload',
     );

     my $resp1 = $event1->send_next('store_payload'); 
     is($resp1, 0, 'Check response is 0 when next action is NONE');
     is(undef, $broadcasted_event, 'Check no event are broadcasted when next action is NONE');

     my $event2 = Event->new(
        action  => 'FetchUrl',
        payload => 'test_payload',
     );

     my $resp2 = $event2->send_next('store_payload'); 
     is($resp2, 1, 'Check response is 1 when next action is not the last');
     isa_ok($broadcasted_event, 'Event');
     is($broadcasted_event->action, 'Store', 'Check next event is correct');
     is($broadcasted_event->payload, 'store_payload', 'Check payload is correct');
}

done_testing();

1;
