%% @author stuart
%% @doc @todo Add description to num_api.


-module(num_api).

%% ====================================================================
%% API functions
%% ====================================================================
-export([call/0]).



%% ====================================================================
%% Internal functions
%% ====================================================================



call() ->
	try
		IP = wf:peer_ip(),
		Headers = wf:headers(),
		n_user_map_proc:record_call(IP, Headers)
	catch
		_:_ ->
			%DON'T CRASH CALLING PROCESS FOR ANY REASON
			error_logger:error_msg("~p ~p", [?MODULE, erlang:get_stacktrace()]),
			ok
	end.
