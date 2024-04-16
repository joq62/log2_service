-define(TABLE,log2).
-define(RECORD,?TABLE).

-record(?RECORD,{
		 id,
		 num,
		 info
		 
		}).
-record(info,{
	       timestamp,
	      datetime,
	      state,
	      level,
	      msg,
	      node,
	      pid,
	      module,
	      function,
	      line,
	      data
	     }).
