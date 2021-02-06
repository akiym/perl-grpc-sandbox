use strict;
use warnings;
use Test::More;

use GrpcSandbox;

my $g = GrpcSandbox->new;
my $service = $g->echo_service;

subtest 'echo' => sub {
    is $service->echo('hello'), 'hello';
    is $service->echo('world'), 'world';
};

subtest 'expand' => sub {
    is_deeply $service->expand('hello world'), ['hello', 'world'];
};

subtest 'collect' => sub {
    is $service->collect('hello', 'world'), 'hello world';
};

subtest 'chat' => sub {
    is_deeply $service->chat('hello', 'world'), ['hello', 'world'];
};

subtest 'paged_expand' => sub {
    my ($contents, $next_page_token) = $service->paged_expand('hello world', 1, '');
    is_deeply $contents, [{ content => 'hello', severity => 0 }];
    is $next_page_token, '1';

    ($contents, $next_page_token) = $service->paged_expand('hello world', 1, $next_page_token);
    is_deeply $contents, [{ content => 'world', severity => 0 }];
    is $next_page_token, '';
};

subtest 'wait' => sub {
    is $service->wait('hello', 1), 'hello';
};

subtest 'block' => sub {
    is $service->block_success(1, 'hello'), 'hello';
    is_deeply $service->block_error(1), { code => 2, details => 'unknown error' };
};

done_testing;
