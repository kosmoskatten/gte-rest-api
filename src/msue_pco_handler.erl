-module(msue_pco_handler).

-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

-record(state, {
  imsis = []
}).

init(_, Req, _Opts) ->
    {ok, Req, #state{}}.

handle(Req, State) ->
  {Method, Req2} = cowboy_req:method(Req),
  case Method of
    <<"GET">>    -> get_pcos(Req2, State);
    _Unsupported -> unsupported(Req2, State)
  end.

terminate(_Reason, _Req, _State) ->
    ok.

get_pcos(Req, #state{imsis=Imsis}=State) ->
    {ok, Reply} = cowboy_req:reply(200,
                       [application_json()],
                       jsx:encode([{<<"imsis">>, Imsis}]),
                       Req),
    {ok, Reply, State}.

unsupported(Req, State) ->
    {ok, Reply} = cowboy_req:reply(405,
                      [{<<"Allow">>, <<"GET, POST">>}],
                      <<>>, Req),
    {ok, Reply, State}.

application_json() ->
    {<<"content-type">>, <<"application/json">>}.
