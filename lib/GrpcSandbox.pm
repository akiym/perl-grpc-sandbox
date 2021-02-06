package GrpcSandbox;
use strict;
use warnings;

use Grpc::XS;

use GrpcSandbox::PB;
use GrpcSandbox::Echo;

sub new {
    my ($class, %args) = @_;

    my $credentials = delete $args{credentials};

    unless ($credentials) {
        $credentials = Grpc::XS::ChannelCredentials::createInsecure();
    }

    return bless {
        server      => 'gapic-showcase:7469',
        credentials => $credentials,
        %args,
    }, $class;
}

sub echo_service {
    my $self = shift;
    return GrpcSandbox::Echo->new(%$self{qw/server credentials/});
}

1;
