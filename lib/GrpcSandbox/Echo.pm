package GrpcSandbox::Echo;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;

    my $service = GrpcSandbox::PB::Google::Showcase::V1beta1::Echo->new(
        $args{server},
        credentials => $args{credentials},
    );
    return bless {
        %args,
        service => $service,
    }, $class;
}

sub service { $_[0]->{service} }

sub echo {
    my ($self, $content) = @_;

    my $req = GrpcSandbox::PB::Google::Showcase::V1beta1::EchoRequest->new({
        content => $content,
    });
    my $call = $self->service->Echo(argument => $req);
    my $res = $call->wait;
    return $res->get_content;
}

sub expand {
    my ($self, $content) = @_;

    my $req = GrpcSandbox::PB::Google::Showcase::V1beta1::ExpandRequest->new({
        content => $content,
    });
    my $call = $self->service->Expand(argument => $req);
    my @res = $call->responses;
    return [map { $_->get_content } @res];
}

sub collect {
    my ($self, @contents) = @_;

    my $call = $self->service->Collect();
    for my $content (@contents) {
        my $req = GrpcSandbox::PB::Google::Showcase::V1beta1::EchoRequest->new({
            content => $content,
        });
        $call->write($req);
    }
    my $res = $call->wait;
    return $res->get_content;
}

sub chat {
    my ($self, @contents) = @_;

    my @res;
    my $call = $self->service->Chat();
    for my $content (@contents) {
        my $req = GrpcSandbox::PB::Google::Showcase::V1beta1::EchoRequest->new({
            content => $content,
        });
        $call->write($req);
        my $res = $call->read;
        push @res, $res->get_content;
    }
    $call->writesDone;
    return \@res;
}

sub paged_expand {
    my ($self, $content, $page_size, $page_token) = @_;

    my $req = GrpcSandbox::PB::Google::Showcase::V1beta1::PagedExpandRequest->new({
        content    => $content,
        page_size  => $page_size,
        page_token => $page_token,
    });
    my $call = $self->service->PagedExpand(argument => $req);
    my $res = $call->wait;
    return [map {
        +{
            content  => $_->get_content,
            severity => $_->get_severity,
        }
    } $res->get_responses_list->@*], $res->get_next_page_token;
}

sub wait {
    my ($self, $content, $ttl) = @_;

    my $req = GrpcSandbox::PB::Google::Showcase::V1beta1::WaitRequest->new({
        success => { content => $content },
        ttl     => { seconds => $ttl },
    });
    my $call = $self->service->Wait(argument => $req);
    my $res = $call->wait;
    while (1) {
        my ($res, $done) = $self->_get_operation($res->get_name);
        if ($done) {
            my $wait_res = GrpcSandbox::PB::Google::Showcase::V1beta1::WaitResponse->decode($res->get_value);
            return $wait_res->get_content;
        }
        sleep 1;
    }
}

sub _get_operation {
    my ($self, $name) = @_;

    my $operations_service = GrpcSandbox::PB::Google::Longrunning::Operations->new(
        $self->{server},
        credentials => $self->{credentials},
    );
    my $req = GrpcSandbox::PB::Google::Longrunning::GetOperationRequest->new({
        name => $name,
    });
    my $call = $operations_service->GetOperation(argument => $req);
    my $res = $call->wait;
    return $res->get_response, $res->get_done;

}

sub block_success {
    my ($self, $delay, $content) = @_;

    my $req = GrpcSandbox::PB::Google::Showcase::V1beta1::BlockRequest->new({
        response_delay => { seconds => $delay },
        success        => {
            content => $content,
        },
    });
    my $call = $self->service->Block(argument => $req);
    my ($res, $status) = $call->wait;
    return $res->get_content;
}

sub block_error {
    my ($self, $delay, $content) = @_;

    my $req = GrpcSandbox::PB::Google::Showcase::V1beta1::BlockRequest->new({
        response_delay => { seconds => $delay },
        error          => {
            code    => GrpcSandbox::PB::Google::Rpc::Code::UNKNOWN,
            message => 'unknown error',
        },
    });
    my $call = $self->service->Block(argument => $req);
    my ($res, $status) = $call->wait;
    return {
        code    => $status->{code},
        details => $status->{details},
    };
}

1;
