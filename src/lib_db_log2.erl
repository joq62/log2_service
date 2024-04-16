%%% @author c50 <joq62@c50>
%%% @copyright (C) 2022, c50
%%% @doc
%%%
%%% @end
%%% Created : 21 Dec 2022 by c50 <joq62@c50>
-module(lib_db_log2).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("stdlib/include/qlc.hrl").
-include("db_log2.hrl").

%% External exports

-export([create_table/0,create_table/2,add_node/2]).
-export([create/1,delete/1]).
-export([read_all/0,read_level/1,read_level/2,read_node/1]).
-export([do/1]).
-export([member/1]).
-export([]).




%%--------------------------------------------------------------------
%% @doc
%%  
%% @end
%%--------------------------------------------------------------------

create_table()->
    mnesia:create_table(?TABLE, [{attributes, record_info(fields, ?RECORD)},
				 {type,set}
				]),
    mnesia:wait_for_tables([?TABLE], 20000).

create_table(NodeList,StorageType)->
    mnesia:create_table(?TABLE, [{attributes, record_info(fields, ?RECORD)},
				 {StorageType,NodeList}]),
    mnesia:wait_for_tables([?TABLE], 20000).
%%--------------------------------------------------------------------
%% @doc
%%  
%% @end
%%--------------------------------------------------------------------

add_node(Node,StorageType)->
    Result=case mnesia:change_config(extra_db_nodes, [Node]) of
	       {ok,[Node]}->
		   mnesia:add_table_copy(schema, node(),StorageType),
		   mnesia:add_table_copy(?TABLE, node(), StorageType),
		   Tables=mnesia:system_info(tables),
		   mnesia:wait_for_tables(Tables,20*1000);
	       Reason ->
		   Reason
	   end,
    Result.
%%--------------------------------------------------------------------
%% @doc
%%  
%% @end
%%--------------------------------------------------------------------
%{Level,Msg,Data,{SenderNode,SenderPid,Module,FunctionName,Line,TimeStamp}}

create({Level,Msg,Data,SenderNode,SenderPid,Module,FunctionName,Line,TimeStamp})->
    Record=#?RECORD{
		    timestamp=TimeStamp,
		    datetime=calendar:now_to_datetime(TimeStamp),
		    state=new, % new, read
		    level=Level,
		    msg=Msg,
		    node=SenderNode,
		    pid=SenderPid,
		    module=Module,
		    function=FunctionName,
		    line=Line,
		    data=Data
		   },
    F = fun() -> mnesia:write(Record) end,
    mnesia:transaction(F).


%%--------------------------------------------------------------------
%% @doc
%%  
%% @end
%%--------------------------------------------------------------------

delete(TimeStamp) ->
    F = fun() -> 
		mnesia:delete({?TABLE,TimeStamp})
		    
	end,
    mnesia:transaction(F).
%%--------------------------------------------------------------------
%% @doc
%%  
%% @end
%%--------------------------------------------------------------------

member(TimeStamp)->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE),		
		     X#?RECORD.timestamp==TimeStamp])),
    Member=case Z of
	       []->
		   false;
	       _->
		   true
	   end,
    Member.

%%--------------------------------------------------------------------
%% @doc
%%  
%% @end
%%--------------------------------------------------------------------

read_all() ->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE)])),
    get_result(Z).

read_level(Level,Num)->
    lists:sublist(read_level(Level),Num).

read_level(Level)->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE),		
		     X#?RECORD.level==Level])),
    get_result(Z).    

read_node(Node)->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE),		
		     X#?RECORD.node==Node])),
    get_result(Z).

%%--------------------------------------------------------------------
%% @doc
%%  
%% @end
%%--------------------------------------------------------------------

do(Q) ->
    F = fun() -> qlc:e(Q) end,
    Result=case mnesia:transaction(F) of
	       {atomic, Val} ->
		   Val;
	       {error,Reason}->
		   {error,Reason}
	   end,
    Result.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

get_result(Z)->
      Result=case Z of
	       []->
		  [];
	       _->
		   [{
		     R#?RECORD.timestamp,
		     R#?RECORD.datetime,
		     R#?RECORD.state,
		     R#?RECORD.level,
		     R#?RECORD.msg,
		     R#?RECORD.node,
		     R#?RECORD.pid,
		     R#?RECORD.module,
		     R#?RECORD.function,
		     R#?RECORD.line,
		     R#?RECORD.data
		    }||R<-Z]
	   end,
    Result.
