%%%-------------------------------------------------------------------
%%%
%%%-------------------------------------------------------------------
-module(rekja).
-include_lib("syntax_tools/include/merl.hrl").
-export([main/1, state/0]).

%%--------------------------------------------------------------------
%%
%%--------------------------------------------------------------------
state() ->
    #{ cookie => undefined
     , node => undefined
     }.

%%--------------------------------------------------------------------
%%
%%--------------------------------------------------------------------
main(Args) ->
    main(Args, state()).

%%--------------------------------------------------------------------
%%
%%--------------------------------------------------------------------
main([], State) ->
    init(State);
main(["-cookie", Cookie|Rest], State) ->
    main(Rest, maps:put(cookie, erlang:list_to_atom(Cookie), State));
main(["-node", Node|Rest], State) ->
    main(Rest, maps:put(node, erlang:list_to_atom(Node), State));
main(Args, _State) ->
    io:format("error, ~p not supported ~n", [Args]).

%%--------------------------------------------------------------------
%%
%%--------------------------------------------------------------------
listener_init() ->
    io:format("start listener~n"),
    erlang:register(listener, self()),
    listener_loop().

%%--------------------------------------------------------------------
%%
%%--------------------------------------------------------------------
listener_loop() ->
    receive
        Msg -> io:format("~p~n", [Msg]),
               listener_loop()
    end.             

%%--------------------------------------------------------------------
%%
%%--------------------------------------------------------------------
init(State) ->
    _Ets = ets:new(?MODULE, []),
    Cookie = maps:get(cookie, State),
    Node = maps:get(node, State),
    Listener = spawn(fun() -> listener_init() end),
    io:format("~p~n", [Listener]),
    erlang:set_cookie(erlang:node(), Cookie),
    net_kernel:connect_node(Node),
    rpc:call(Node, dbg, start, []),
    N = node(),
    rpc:call(Node, dbg, tracer, [process, {
                                           fun(Message, _) -> 
                                                   {listener, N} ! Message,
                                                   io:format("~p~n", [Message]), 0 
                                           end, 0                                     
                                          }]),
    rpc:call(Node, dbg, p, [all, all]),
    loop().

%%--------------------------------------------------------------------
%%
%%--------------------------------------------------------------------
handler(Node) ->
    { fun(Message, _) -> 
              {listener, Node} ! Message,
              io:format("~p~n", [Message]), 0 
      end,
      0}.

%%--------------------------------------------------------------------
%%
%%--------------------------------------------------------------------
loop() ->
    receive
        _ -> loop()
    end.
            
