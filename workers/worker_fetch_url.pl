#!/usr/bin/perl
use strict;
use warnings;
use Gearman::Worker;
use Dispatcher;

my $worker = Gearman::Worker->new;
$worker->job_servers('127.0.0.1');
 
$worker->register_function('FetchUrl', \&Dispatcher::dispatch, );
 
$worker->work while 1;

