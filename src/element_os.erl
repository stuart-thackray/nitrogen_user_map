-module (element_os).
-include_lib ("nitrogen_core/include/wf.hrl").
-include_lib ("nitrogen_fa/include/records.hrl").
-include_lib ("../include/records.hrl").

-export([
    reflect/0,
    render_element/1
]). 
 

-define(TEXT_COLOUR_LIST, ["red", "yellow", "aqua","blue", "black", "light-blue", "green", "gray","navy","teal", "olive", "lime","orange", "fushia", "purple", "maroon"]).

-define(CHART_COLOUR_LIST, ["#dd4b39","#f39c12","#00c0ef","#0073b7","#111111","#3c8dbc","#00a65a","#d2d6de","#001f3f","#39cccc","#3d9970","#01ff70","#ff851b","#f012be","#605ca8","#d81b60"]).

reflect() -> record_info(fields, element_os).
 
 

render_element(#element_os{  	
					
							}) -> 
	Browsers = n_user_map_proc:get_browser_type(),
	ReverseSorted = lists:keysort(2, Browsers),
	Sorted = lists:reverse(ReverseSorted),
	wf:defer(script(Sorted)),
	Element = [


		#panel{class = "box-header with-border",
			   body = 
				   [
					#h3{class = "box-title", text = "Operating System"},
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
                      <div class=\"chart-responsive\">
                        <canvas id=\"pieChart2\" height=\"160\" width=\"329\" style=\"width: 329px; height: 160px;\"></canvas>
                      </div><!-- ./chart-responsive -->
                    </div><!-- /.col -->
                    <div class=\"col-md-4\">
                      <ul class=\"chart-legend clearfix\">
",legend(Sorted, ?TEXT_COLOUR_LIST),"
                      </ul>
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

script(Sorted) ->
"
$(function () {

  'use strict';

  var pieChartCanvas = $('#pieChart2').get(0).getContext(\"2d\");
  var pieChart = new Chart(pieChartCanvas);
  var PieData = [
"++ lists:reverse(tl(lists:reverse(lists:flatten(pieData(Sorted, ?CHART_COLOUR_LIST))))) ++"
  ];
  var pieOptions = {
    //Boolean - Whether we should show a stroke on each segment
    segmentShowStroke: true,
    //String - The colour of each segment stroke
    segmentStrokeColor: \"#fff\",
    //Number - The width of each segment stroke
    segmentStrokeWidth: 1,
    //Number - The percentage of the chart that we cut out of the middle
    percentageInnerCutout: 50, // This is 0 for Pie charts
    //Number - Amount of animation steps
    animationSteps: 100,
    //String - Animation easing effect
    animationEasing: \"easeOutBounce\",
    //Boolean - Whether we animate the rotation of the Doughnut
    animateRotate: true,
    //Boolean - Whether we animate scaling the Doughnut from the centre
    animateScale: false,
    //Boolean - whether to make the chart responsive to window resizing
    responsive: true,
    // Boolean - whether to maintain the starting aspect ratio or not when responsive, if set to false, will take up entire container
    maintainAspectRatio: false,
    //String - A legend template
    legendTemplate: '<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>',
    //String - A tooltip template
    tooltipTemplate: '<%=value %> <%=label%> users'
  };
  //Create pie or douhnut chart
  // You can switch between pie and douhnut using the method below.
  pieChart.Doughnut(PieData, pieOptions);
});
".

pieData([], _) ->
	[];
pieData(R, []) ->
	pieData(R, ?CHART_COLOUR_LIST);
pieData([{V,N}|Rest], [C|Tail]) ->
	[io_lib:format("{value: ~p, color: '~s', highlight:'~s',label:'~p'},",
			[N, C,C,V])|
		pieData(Rest, Tail)].



legend([], _) ->
	[];
legend(Rest, []) ->
	legend(Rest, ?TEXT_COLOUR_LIST);
legend([{B, N}|Rest], [C|Tail]) ->
	[#listitem{
				body =[
						#fa{fa=" fa-circle-o text-" ++ C},
						" " ++ to_l(B) ++ " " ++ to_l(N)
						]
				}|
			legend(Rest, Tail)].


