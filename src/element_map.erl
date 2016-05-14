-module (element_map).
-include_lib ("nitrogen_core/include/wf.hrl").
-include_lib ("nitrogen_fa/include/records.hrl").
-include_lib ("../include/records.hrl").

-export([
    reflect/0,
    render_element/1
]). 
 

-define(DESC_BLOCK(Number, Text), [#panel{ class = "description-block margin-bottom",
							 body = [
"<div class=\"sparkbar pad\" data-color=\"#fff\">90,70,90,70,75,80,70</div>",
									 #h5{class = "description-header", body = to_l(Number)},
									 #span{class = "description-text", body = Text} 
									 
									 ]
						   }
					]).

reflect() -> record_info(fields, element_map).

 
-spec render_element(#element_map{}) -> body().

render_element(#element_map{
							title = Title,
							html_id = ID	  						
							}) -> 

	
	{Unique, Total, Local, ScripElements}  = n_user_map_proc:get_render_info(),
	wf:wire(script(ScripElements)),								                           
	Text1 = "Unique Vistors",
	Text2 = "Total Hits",
    Text3 = "Local/No lookup",
	Element = #panel{
						   	class = "box box-success", 
							body = [
									 #panel{
										   	class = "box-header with-border",
											body = [
													#h3{class = "box-title", text = Title}, 
													#panel{
														   	class = "box-tools pull-right",
															body = [

																	#button{class = "btn btn-box-tool", 
																			data_fields=[{"widget", "collapse"}],
																			body = [#fa{fa="minus"}]
																				   }
,
																	#button{class = "btn btn-box-tool", 
																			data_fields=[{"widget", "remove"}],
																			body = [#fa{fa = "times"}]
																			}
																	]
															}
													]
										},											 
				#panel{class = "box-body no-padding",
						body = [
							#panel{class = "row", 
									body = [
										#panel{class = "col-md-9 col-sm-8",
												body = [
											#panel{class = "pad",
													body = [
															#panel{html_id = ID, style = "height:325px;"}
															]
													}	
														]
												},
									#panel{class = "col-md-3 col-sm-4",
										   body = [
					#panel{class = "pad box-pane-right bg-green", style="min-heigth:280px;",
						   body = [
										?DESC_BLOCK(to_l(Unique), Text1),
										?DESC_BLOCK(to_l(Total), Text2),
										?DESC_BLOCK(to_l(Local), Text3)
									]
						  }
								   

									]
										}
										   ]
								  }
							   ]
					  }
											 ]
									 
					},
	Attributes = [{"class","col-md-8"}],
	wf_tags:emit_tag('div', [Element], Attributes).


to_l(Int) when is_integer(Int) ->
	integer_to_list(Int);
to_l(Any) ->
	Any.

script(Scr) ->
lists:flatten(["$(function () {

  'use strict';

  /* ChartJS
   * -------
   * Here we will create a few charts using ChartJS
   */



  /* jVector Maps
   * ------------
   * Create a world map with markers
   */
  $('#world-map-markers').vectorMap({
    map: 'world_mill_en',
    normalizeFunction: 'polynomial',
    hoverOpacity: 0.7,
    hoverColor: false,
    backgroundColor: 'transparent',
    regionStyle: {
      initial: {
        fill: 'rgba(210, 214, 222, 1)',
        'fill-opacity': 1,
        stroke: 'none',
        'stroke-width': 0,
        'stroke-opacity': 1
      },
      hover: {
        'fill-opacity': 0.7,
        cursor: 'pointer'
      },
      selected: {
        fill: 'yellow'
      },
      selectedHover: {
      }
    },
    markerStyle: {
      initial: {
        fill: '#00a65a',
        stroke: '#111'
      }
    },
    markers: [
",Scr,"
    ]
  });

  /* SPARKLINE CHARTS
   * ----------------
   * Create a inline charts with spark line
   */

  //-----------------
  //- SPARKLINE BAR -
  //-----------------
  $('.sparkbar').each(function () {
    var $this = $(this);
    $this.sparkline('html', {
      type: 'bar',
      height: $this.data('height') ? $this.data('height') : '30',
      barColor: $this.data('color')
    });
  });

  //-----------------
  //- SPARKLINE PIE -
  //-----------------
  $('.sparkpie').each(function () {
    var $this = $(this);
    $this.sparkline('html', {
      type: 'pie',
      height: $this.data('height') ? $this.data('height') : '90',
      sliceColors: $this.data('color')
    });
  });

  //------------------
  //- SPARKLINE LINE -
  //------------------
  $('.sparkline').each(function () {
    var $this = $(this);
    $this.sparkline('html', {
      type: 'line',
      height: $this.data('height') ? $this.data('height') : '90',
      width: '100%',
      lineColor: $this.data('linecolor'),
      fillColor: $this.data('fillcolor'),
      spotColor: $this.data('spotcolor')
    });
  });


}); 
 
"

]).