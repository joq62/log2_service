%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created :
%%% Node end point  
%%% Creates and deletes Pods
%%% 
%%% API-kube: Interface 
%%% Pod consits beams from all services, app and app and sup erl.
%%% The setup of envs is
%%% -------------------------------------------------------------------
-module(all).      
 
-export([start/0,
	log/3]).


%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("log.api").
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
   
    ok=setup(),
    ok=test1(),
    ok=test2(),
              
    io:format("Test OK !!! ~p~n",[?MODULE]),


  %  init:stop(),
   % timer:sleep(2000),
 
    ok.

   
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
log(debug,Msg,Data)->
    ?LOG2_DEBUG(Msg,Data);
log(notice,Msg,Data) ->
    ?LOG2_NOTICE(Msg,Data);
log(warning,Msg,Data) ->
    ?LOG2_WARNING(Msg,Data);
log(alert,Msg,Data) ->
    ?LOG2_ALERT(Msg,Data).
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
test2()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),  

    

    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
test1()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    
%    ?LOG_WARNING("nodedown,Node ",[node()]),
%    ?LOG_NOTICE("Connect result ",[?MODULE]),    
    ?LOG2_DEBUG("Debug ",[msg1]),
    timer:sleep(3000),
    ?LOG2_NOTICE("Notice ",[msg2]),  
    timer:sleep(3000),
    ?LOG2_WARNING("Warning ",[msg3]),
    timer:sleep(3000),
    ?LOG2_ALERT("Alert ",[msg4]),
    timer:sleep(3000),
 %   ?LOG2_ALERT("Houston we have problem ",[msg5,"The lunar module gives ",1202, "alarm", [glurk,"jle", 3.13]]),
    ?LOG2_ALERT("Alert ",[msg5]),
    timer:sleep(3000),
    ?LOG2_ALERT("alert ",[msg6]),
    timer:sleep(3000),
    ?LOG2_DEBUG("Debug2 ",[msg7]),
    timer:sleep(3000),
    ?LOG2_NOTICE("Notice2 ",[msg8]),  
    timer:sleep(3000),
    ?LOG2_WARNING("Warning22 ",[msg9]),
    timer:sleep(3000),
    ?LOG2_ALERT("Alert2 ",[msg10]),
    timer:sleep(3000),
    [{_Id,10,MapList}]=lib_db_log2:read_all(), 
    
   % glurk=lib_db_log2:read_all_levels(),
    [{alert,[msg10]},{warning,[msg9]},{notice,[msg8]},{debug,[msg7]},
     {alert,[msg6]},{alert,[msg5]},{alert,[msg4]},{warning,[msg3]},
     {notice,[msg2]},{debug,[msg1]}
    ]=[{maps:get(level,Map),maps:get(data,Map)} ||Map<-lib_db_log2:read_all_levels()],

    [{alert,[msg10]},{warning,[msg9]},{notice,[msg8]},{debug,[msg7]}]=[{maps:get(level,Map),maps:get(data,Map)} ||Map<-lib_db_log2:read_all_latest(4)],

    [{debug,[msg7]},{debug,[msg1]}]=[{maps:get(level,Map),maps:get(data,Map)} ||Map<-lib_db_log2:read_level(debug)],
    [{notice,[msg8]},{notice,[msg2]}]=[{maps:get(level,Map),maps:get(data,Map)} ||Map<-lib_db_log2:read_level(notice)],
    [{warning,[msg9]},{warning,[msg3]}]=[{maps:get(level,Map),maps:get(data,Map)} ||Map<-lib_db_log2:read_level(warning)],
    [{alert,[msg10]},{alert,[msg6]},{alert,[msg5]},{alert,[msg4]}]=[{maps:get(level,Map),maps:get(data,Map)} ||Map<-lib_db_log2:read_level(alert)],
    

    
 %   [lib_log2:print_ln(I)||I<-All],
  %  [lib_log2:print(I)||I<-All],
    ok.




%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------


setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    ok=application:start(log_rd),
    pong=log:ping(),
    pong=rd:ping(),
    {ok,_}=log2:start_link(),
    pong=log2:ping(),

    spawn(fun()->print_loop(na) end),
    ok.

print_loop(LatestMap)->
   case lib_db_log2:read_all_latest(1) of
       []->
	   NewLatest=LatestMap;
       [Map]->
	   if 
	       Map/=LatestMap->
		   lib_log2:print(Map),
		   NewLatest=Map;
	       true ->
		   NewLatest=LatestMap
	   end
   end,
    timer:sleep(1000),
    print_loop(NewLatest).
    
