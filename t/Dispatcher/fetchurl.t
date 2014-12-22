#!/usr/bin/perl -w
use strict;

use Test::More;
use Test::MockObject;

use Dispatcher;

# TODO: Need to catch output

{
    my $tweets = [];
    Test::MockObject->fake_module(
        'Net::Twitter',
        new => sub {
            my ($class, $args) = @_; 
            return bless {}, $class;
        },
        user_timeline => sub { $tweets,},
    );

    my $action = Dispatcher->with_traits('FetchUrl')->new( payload => 3 );
    my $new_payload = $action->execute;

    is_deeply($new_payload, [], 'Check no event are sent');

    $tweets = [1,2,3,4,5,6,7,8,9,10];
    my $new_payload = $action->execute;

    is_deeply($new_payload, $tweets, 'Check no event are sent');
 
}

done_testing();
