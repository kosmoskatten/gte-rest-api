-module(rest_api_app).

-behaviour(application).

%% Application callbacks
-export([kick_start/0]).
-export([start/2, stop/1]).

%% Quick hack to enable start of stuff from "outside" GTE.
kick_start() ->
    code:add_paths(deps()),
    lists:map(fun application:start/1,
                [ranch, crypto, cowlib, cowboy, rest_api]
             ),
    ok.

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    start_rest(),
    rest_api_sup:start_link().

stop(_State) ->
    ok.

start_rest() ->
    Dispatch = cowboy_router:compile([
        {'_', [{"/msue", msue_handler, []}]}
    ]),
    cowboy:start_http(gte_api_listener, 100,
                      [{port, 8080}],
                      [{env, [{dispatch, Dispatch}]}]
    ).

deps() ->
    ["/home/uabpasa/repos/gte-rest-api/deps/cowboy/ebin",
     "/home/uabpasa/repos/gte-rest-api/deps/cowlib/ebin",
     "/home/uabpasa/repos/gte-rest-api/deps/ranch/ebin"
    ].
