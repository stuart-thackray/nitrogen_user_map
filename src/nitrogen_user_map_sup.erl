
-module(nitrogen_user_map_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([
         init/1
        ]).


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init([]) ->

    AppStarter = {app_starter, {n_user_map_proc, start_link, []},
            permanent, 2000, worker, [app_starter]},
    {ok,{{one_for_one, 3 ,5}, [AppStarter]}}.




%%====================================================================
%% Internal functions
%%====================================================================
