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
 
-export([start/0]).


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
              
    io:format("Test OK !!! ~p~n",[?MODULE]),


%    init:stop(),
%    timer:sleep(2000),
 
    ok.

   
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
test1()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    
    ?LOG_WARNING("nodedown,Node ",[node()]),
    ?LOG_NOTICE("Connect result ",[?MODULE]),    
    ?LOG2_DEBUG("Debug ",[node()]),
    ?LOG2_NOTICE("Notice ",[?MODULE]),  
    ?LOG2_WARNING("Warning ",[time()]),
    ?LOG2_ALERT("Alert ",[?MODULE]),    
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

    ok.
