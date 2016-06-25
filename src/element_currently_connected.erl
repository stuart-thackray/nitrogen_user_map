-module (element_currently_connected).
-include_lib ("nitrogen_core/include/wf.hrl").
-include_lib ("nitrogen_fa/include/records.hrl").
-include_lib ("../include/records.hrl").

 -export([
    reflect/0,
    render_element/1,
    refresh/0
]). 
 

-define(TEXT_COLOUR_LIST, lists:reverse(["red", "yellow", "aqua","blue", "black", "light-blue", "green", "gray","navy","teal", "olive", "lime","orange", "fushia", "purple", "maroon"])).

-define(CHART_COLOUR_LIST, lists:reverse(["#dd4b39","#f39c12","#00c0ef","#0073b7","#111111","#3c8dbc","#00a65a","#d2d6de","#001f3f","#39cccc","#3d9970","#01ff70","#ff851b","#f012be","#605ca8","#d81b60"])).

reflect() -> record_info(fields, element_os).
 
 
refresh() ->
    wf:replace(curr_connected,#element_connected{}).

render_element(#element_connected{  	
					
							}) -> 
   Element = [
        #panel{ class = "box-header with-border",
			   body = 
				   [
					#h3{class = "box-title", text = "Current Connections"},
					#panel{class = "box-tools pull-right",
						   body =[	
									#button{class = "btn btn-box-tool", 
											data_fields=[{"widget", "collapse"}],
											body = [#fa{fa="minus"}]
											},
									#button{class = "btn btn-box-tool", 
											data_fields=[{"widget", "remove"}],
											body = [#fa{fa = "times"}]
											}								  
								  ]
					
						  }
					]
			   },
			   "
                <div class=\"box-body\">
                  <div class=\"row\">
                    <div class=\"col-md-8\">
                      ",
    #table{header = [],
           rows = rows(currently_connected:get_sockets())}    
        
        
        ,"
                    </div><!-- /.col -->
                    </div><!-- /.row -->
                </div><!-- /.box-body -->
  "],
	Attributes = [{"class","box box-default"}],
	wf_tags:emit_tag('div', [Element], Attributes).

to_l(List) when is_list(List) ->
    List;
to_l(Bin) when is_binary(Bin) ->
    binary_to_list(Bin);
to_l(Int) when is_integer(Int) ->
	integer_to_list(Int);
to_l(Atom) when is_atom(Atom)->
    atom_to_list(Atom);
to_l(Any) ->
	Any.


%% [{8000,"127.0.0.1","127.0.0.1",40176,<0.7273.0>,0,1397},
%%  {8000,"127.0.0.1","127.0.0.1",39996,<0.133.0>,0,3643},
%%  {51511,"127.0.0.1","127.0.0.1",4369,<0.21.0>,0,20}]

rows([]) ->
    [];
rows([ {Port,Address,PeerAddress,PeerPort,Owner,Input,Output}|Rest]
    ) ->
   [#tablerow{cells = 
        [
            #tablecell{text = [to_l(Address), ":", to_l(Port)]},
            #tablecell{text = [to_l(PeerAddress), ":",to_l(PeerPort)] },
            #tablecell{text = to_l(Owner)},
            #tablecell{text = to_l(Input)},
            #tablecell{text = to_l(Output)}
        ]
        }|rows(Rest)].

  

