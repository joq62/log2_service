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
-export([read_all/0,read_level/1,read_level/2,read_all_levels/0,read_all_latest/1,read_node/1]).
-export([do/1]).
-export([member/1]).
-export([]).





%%--------------------- Standard ------------------------------------

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
%    io:format(" create ~p~n",[{Level,Msg,Data,SenderNode,SenderPid,Module,FunctionName,Line,TimeStamp,?MODULE,?LINE}]),
    
 F = fun() -> 
	     Info=#{
		    timestamp=>TimeStamp,
		    datetime=>calendar:now_to_datetime(TimeStamp),
		    state=>new, % new, read
		    level=>Level,
		    msg=>Msg,
		    node=>SenderNode,
		    pid=>SenderPid,
		    module=>Module,
		    function=>FunctionName,
		    line=>Line,
		    data=>Data
		   },
	     Z=do(qlc:q([X || X <- mnesia:table(?TABLE)])),
	     Updated=case Z of
			 []->
			     #?RECORD{id=first,num=1,info=[Info|[]]};
			 [S]->
			     S#?RECORD{num=S#?RECORD.num+1,info=[Info|S#?RECORD.info]}
		     end,
	     mnesia:write(Updated)
     end,
    Result=case mnesia:transaction(F) of
	       {atomic, Val} ->
		   Val;
	       {error,Reason}->
		   {error,Reason}
	   end,
    Result.



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
		     X#?RECORD.info==TimeStamp])),
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

read_all_latest(Num)->
    case read_all_levels() of
	[]->
	    [];
	List->
	    lists:sublist(List,Num)
    end.
read_all_levels()->
    case lib_db_log2:read_all() of
	[]->
	    [];
	[{_Id,_Num,MapList}]->
	    MapList
    end.

read_level(Level,Num)->
    lists:sublist(read_level(Level),Num).

read_level(Level)->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE)])),		
    case Z of
	[]->
	    {error,["No table initiated"]};
	[S]->
	    InfoList=S#?RECORD.info,
	    [Map||Map<-InfoList,
		  Level==maps:get(level,Map)]
    end.

read_node(Node)->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE)])),		
    case Z of
	[]->
	    {error,["No table initiated"]};
	[S]->
	    InfoList=S#?RECORD.info,
	    [Map||Map<-InfoList,
		  Node==maps:get(node,Map)]
    end.  
    

%%------------MapList--------------------------------------------------------
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
		     R#?RECORD.id,
		     R#?RECORD.num,
		     R#?RECORD.info
		    }||R<-Z]
	   end,
    Result.
