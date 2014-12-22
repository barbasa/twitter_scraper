#!/usr/bin/perl
use strict;
use warnings;
use Event;

# Getting just 3 pages
foreach my $i (1 .. 3) {
    my $event = Event->new(
        action  => 'FetchUrl',
        payload =>  $i,
    );
    $event->broadcast;
}
