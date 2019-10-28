# rekja

Erlang tracer tool around standard Erlang/OTP framework.

## Build

    $ rebar3 compile
    $ rebar3 escriptize
    
## Usage

    $ ./_build/default/bin/rekja -node ${remote_node} \
                                 -cookie ${remote_cookie}

## Why?

Distributed Erlang offers great tracing and debugging flexibility
around standard functions. This project was originaly made to solve a
file descriptor leak on a rabbitmq server in production. The idea is
to set a passive node, connect to an active node, and, by using rpc
call ensuring all opened/closed ports are well opened/closed.

## How?
