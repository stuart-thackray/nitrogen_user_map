%% -*- mode: nitrogen -*-
-module (user_map_demo).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").
-include_lib("nitrogen_fa/include/records.hrl").
-include_lib("nitrogen_user_map/include/records.hrl").

main() -> #template { file="./site/templates/plugins/nitrogen_user_map/nitrogen_user_map_demo.html" }.


body() ->  
	num_api:call(), 
%% error_logger:info_msg("Headers:~p", [wf:headers()]),
     [
		#panel{class = "row",
			   body = [#button{class = "btn btn-success", 
					text="Load test Data", 
				postback = "load_test"
			   },
				#p{}
					  ]
			 },
		#panel{class = "row", 
			   body = [
				#element_map{title = "Visited Users",
							 html_id = "world-map-markers"
							},
				#panel{class = "col-md-4",
					   body = [#element_ua{}]
					  }
					  ]
			  }


    ].


event("load_test") ->
	n_user_map_proc:load_test_data(),
	wf:redirect("/" ++ list_to_binary(atom_to_list(?MODULE)));
event(Msg) ->
	error_logger:info_msg("~p Unsupported Event:~p", [?MODULE, Msg]).


markers() ->
	n_user_map_proc:get_render_info().