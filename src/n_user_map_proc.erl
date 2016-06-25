-module(n_user_map_proc).

-include_lib("egeoip/include/egeoip.hrl").
-include("../include/db_api.hrl").

 

%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/0,
         init/1,
		 record_call/2,
		 record_call/3,
		 load_test_data/0,
		 get_render_info/0,
		get_browser_info/0,
         get_browser_type/0,
         get_browser_os/0,
         stop/0 
		]).

-record(state, { 
                 ppid,
				 browsers = [],
                 type = [],
                 os = [] 
                }).


stop() ->
    ?MODULE ! shutdown.

load_test_data() -> 
	[	record_call(IP, [{<<"user-agent">>, UA}]) ||
	{IP, UA} <- [{"63.224.214.117","Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; XMPP Tiscali Communicator v.10.0.2; .NET CLR 2.0.50727)"},
                 {"144.139.80.91",			"Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.10240"},
                 {"88.233.53.82",			"Mozilla/5.0 (Windows Phone 8.1; ARM; Trident/7.0; Touch; rv:11.0; IEMobile/11.0; HTC; HTC6990LVW) like Gecko"},
		   		{"85.250.32.5",			"Mozilla/5.0 (iPhone; U; CPU iPhone OS 5_1_1 like Mac OS X; en) AppleWebKit/534.46.0 (KHTML, like Gecko) CriOS/19.0.1084.60 Mobile/9B206 Safari/7534.48.3"},
                 {"220.189.211.182",			"Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/540.0 (KHTML, like Gecko) Ubuntu/10.10 Chrome/8.1.0.0 Safari/540.0"},
                 {"211.112.118.99",			"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36"},
                 {"84.94.205.244",			"Mozilla/5.0 (iPod; U; CPU iPhone OS 4_1 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8B117 Safari/6531.22.7"},
                 {"61.16.226.206",			"Opera/9.80 (Windows NT 6.0; U; pl) Presto/2.10.229 Version/11.62"},
                 {"64.180.1.78",			"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36 OPR/23.0.1522.60"},
                 {"138.217.4.11",			"Mozilla/5.0 (iPad; CPU OS 5_0 like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko; Google Web Preview) Version/5.1 Mobile/9A334 Safari/7534.48.3"},
		   		{"41.147.63.10",			"Mozilla/5.0 (BB10; Touch) AppleWebKit/537.1 (KHTML, like Gecko) Version/10.0.0.1337 Mobile Safari/537.1"},
				{"41.162.48.1",			"Mozilla/5.0 (compatible; Konqueror/3.1; Linux 2.4.21-20.0.1.ELsmp; X11; i686; , en_US, en, de)"}
				]
	].


start_link() ->
    proc_lib:start_link(?MODULE, init, [self()]).


record_call(Node, IP, Headers) ->
	{?MODULE, Node} ! {add, IP, Headers}.

record_call(IP, Headers) ->
	?MODULE ! {add, IP, Headers}.

get_render_info() ->
 	From = self(),
	Ref = make_ref(),
	?MODULE ! {'renderinfo', From, Ref},
	receive
		 {Ref, Elements} ->
			Elements
	end.

get_browser_os() ->
    From =self(),
    Ref = make_ref(),
    ?MODULE ! {'browser_os', From, Ref},
    receive 
        {Ref, Answer} ->
            Answer
    end.   

get_browser_type() ->
     From =self(),
    Ref = make_ref(),
    ?MODULE ! {'browser_type', From, Ref},
    receive 
        {Ref, Answer} ->
            Answer
    end.   
   
    
get_browser_info() ->
	From =self(),
	Ref = make_ref(),
	?MODULE ! {'browser_info', From, Ref},
	receive 
		{Ref, Answer} ->
			Answer
	end.

init(PPid) ->
    register(?MODULE, self()),
    process_flag(trap_exit, true),
	application:start(egeoip),
	proc_lib:init_ack(PPid, {ok, self()}),
    loop(#state{  
				ppid = PPid	
				}
		).

loop({shutdown, _State}) ->
    exit(normal);
loop(State = #state{}) ->
	NewState = receive
		Msg ->
			try process_msg(Msg, State)
			catch _:_ ->
					  State
			end
	end,
	loop(NewState).

process_msg({'renderinfo', From, Ref}, State) ->
	
	put(count, 0),
	put(total, 0),
	Local = case lists:keysearch({0.0, 0.0}, 1, get()) of
		{value, {_, #dict{count = Count}}} ->
			Count;
		_ ->
			0
	end,
	RInfo = return_render_info(get()),
	From ! {Ref, 
			
			{erase(count),
			 erase(total),
			 Local,
			
			case RInfo of
					 [] ->
						 [];
				 	R ->
			lists:reverse(tl(lists:reverse(lists:flatten(R))))
				 end
		   }},
	State;

process_msg({'browser_os', From, Ref},State) ->
    From ! {Ref, State#state.os},
    State;

process_msg({'browser_type', From, Ref},State) ->
    From ! {Ref, State#state.type},
    State;

process_msg({'browser_info', From, Ref},State) ->
	From ! {Ref, State#state.browsers},
	State;

process_msg( {add,IP, Headers}, State) ->
	try 
		case catch egeoip:lookup(IP) of
		{ok, #geoip{
                country_name = CountryName,
				city = City,
                latitude = Lat,
                longitude = Long
						}
			 } ->
			case get({Lat, Long}) of
				Rec = #dict{
					count =	 Count
		  			} ->
						put ({Lat, Long},Rec#dict{count = Count +1});
				_ ->
						put({Lat, Long}, #dict{name = [to_l(CountryName) ++ "-" ++ to_l(City)],
										count = 1})
			end
		end
	catch _:_ -> 
			  error_logger:error_msg("Intial Args: ~p Stack:~p", [ IP, erlang:get_stacktrace()])
	end,
	record_headers(Headers, State);



process_msg(Exit = {'EXIT', PPid, _}, State = #state{ppid = PPid}) ->
	error_logger:info_msg("Exit from Parent:~p", [Exit]),
	{shutdown, State};

process_msg(shutdown, State) ->
    {shutdown, State};
process_msg(Msg, State) ->
	error_logger:info_msg("[~p] Received Unkown Msg", [?MODULE, Msg]),
    State.

%% Internal

record_headers([], State) ->
	State;
record_headers(Header, State) ->
	UA = proplists:get_value(<<"user-agent">>, Header, []),
	case  useragent:parse(UA) of
%% [{browser,[{name,<<"Chrome">>},
%%            {family,chrome},
%%            {type,web},
%%            {manufacturer,google},
%%            {engine,webkit}]},
%%  {os,[{name,<<"Windows 7">>},
%%       {family,windows},
%%       {type,computer},
%%       {manufacturer,microsoft}]},
%%  {string,<<"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/"...>>}]
		[{browser, OPT},{os, OSList}|_] ->
			NS = browser_info(OPT, State),
            NS2 = browser_name(OSList, NS),
            browser_device(OSList, NS2)
  
	end.
					
		



return_render_info(undefined) ->
	[];
return_render_info([]) ->
	[];
return_render_info([{{Lat,Long},#dict{name = Name,
									  count = Count
									 }}|Rest]) ->
	put(count, get(count)+1),
	put(total, get(total) + Count),
	[io_lib:format("{latLng: [~.5f, ~.5f], name: '~s (~p)'},", [Lat,Long,Name, Count])|
		return_render_info(Rest)];
return_render_info([_OtherStuff|Rest]) ->
	return_render_info(Rest).		
	

to_l(Bin) when is_binary(Bin) ->
	binary_to_list(Bin);
to_l(Any) ->
	Any. 

browser_info( OPT, State ) ->
    {Key, NV} = case proplists:get_value(family, OPT) of
         %% Unkown UserAget
         undefined ->
             {undefined,{undefined, proplists:get_value(undefined, State#state.browsers, 0)+1}};
         K ->
            {K, {K, proplists:get_value(K, State#state.browsers,  0) +1}}
            end,
   case lists:keytake(Key, 1, State#state.browsers) of
                false ->
                    State#state{browsers = [NV|State#state.browsers]};
                {value, _Tuple, TL} ->
                    State#state{browsers = [NV|TL]}
  end.


browser_name(OPT, NS) ->
            {Key, NV} = case proplists:get_value(name, OPT) of
                %% Unkown UserAget
                undefined ->
                    {undefined,{undefined, proplists:get_value(undefined, NS#state.type, 0)+1}};
                K ->
                    {K, {K, proplists:get_value(K, NS#state.type,  0) +1}}
            end,
            case lists:keytake(Key, 1, NS#state.type) of
                false ->
                    NS#state{type = [NV|NS#state.type]};
                {value, _Tuple, TL} ->
                    NS#state{type = [NV|TL]}
            end.          


browser_device(OPT, NS) ->
            {Key, NV} = case proplists:get_value(type, OPT) of
                %% Unkown UserAget
                undefined ->
                    {undefined,{undefined, proplists:get_value(undefined, NS#state.os, 0)+1}};
                K ->
                    {K, {K, proplists:get_value(K, NS#state.os,  0) +1}}
            end,
            case lists:keytake(Key, 1, NS#state.os) of
                false ->
                    NS#state{os = [NV|NS#state.os]};
                {value, _Tuple, TL} ->
                    NS#state{os = [NV|TL]}
            end.     