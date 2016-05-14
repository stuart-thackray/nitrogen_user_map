
-module(nitrogen_user_map_app).

-behaviour(application).


-export([start/2, stop/1]).

start(_Type, _StartArgs) ->
    case nitrogen_user_map_sup:start_link() of
	{ok, Pid} -> 
	    {ok, Pid};
	Error ->
	    Error
    end.

stop(_State) ->
    ok.
