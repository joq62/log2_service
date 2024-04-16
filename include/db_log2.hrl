-define(TABLE,log2).
-define(RECORD,?TABLE).

-record(?RECORD,{
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
