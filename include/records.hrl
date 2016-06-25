

-record(element_map, {?ELEMENT_BASE(element_map),
					  %% Fist Info box
						num1,
					    text1,
					  %% Second Info box
					    num2,
					    text2,
					  %% Third Info box
					    num3,
					    text3
					 }).



-record(element_ua, {?ELEMENT_BASE(element_user_agent),
					 browsers=[]
					 }).


-record(element_os, {?ELEMENT_BASE(element_os),
                     operating_system=[]
                     }).


-record(element_dt, {?ELEMENT_BASE(element_device_type),
                     field=[]
                     }).


-record(element_connected, {?ELEMENT_BASE(element_currently_connected),
                     field=[]
                     }).