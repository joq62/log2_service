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
-module(lib_log2).     
 
-export([
	 format/1,
	 print_ln/1,
	 print/1,
	 create_logger/5,
	 parse/1

	]).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
format(Map)->
    TimeStamp=maps:get(timestamp,Map),
    {Date,Time}=maps:get(datetime,Map),
    {Year,Mon,Day}=Date,
    {Hour,Min,Sec}=Time,
    DateStr=integer_to_list(Year)++":"++integer_to_list(Mon)++":"++integer_to_list(Day),
    TimeStr=integer_to_list(Hour)++":"++integer_to_list(Min)++":"++integer_to_list(Sec),
    
    State=maps:get(state,Map),
    Level=maps:get(level,Map),
    Msg=maps:get(msg,Map),
    SenderNode=maps:get(node,Map),
    SenderPid=maps:get(pid,Map),
    Module=maps:get(module,Map),
    FunctionName=maps:get(function,Map),
    Line=maps:get(line,Map),
    Data=maps:get(data,Map),
    R=io_lib:format("~p",[Data]),
    DataAsString=lists:flatten(R),
    Info="~s ~s | ~w | ~w | ~w | {~w,~w,~w} ~s ~s ~s ~s",
    FormatData=[DateStr,TimeStr,Level,SenderNode,SenderPid,Module,FunctionName,Line,":",Msg,">>",DataAsString],
    {Info,FormatData}.


%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
%{{1713,242030,981108}, {{2024,4,16},{4,33,50}}, new,debug,"Debug ",log2_service_a@c50,<0.9.0>,all,test1,50,[log2_service_a@c50]},

% TimeStamp::term(),{date()::term(),time()::term()},State::atom(),Level::atom(),
% ?RECORD{  timestamp::term(),
%%           datetime:: term(),
%	    state :: atom(),
%		    level ::atom()
%		    msg::string()
%		    node :: atom()
%		    pid::term()
%		    module :: arom(),
%		    function::atom()
%		    line ::integer(),
%		    data::term(),
%		   },
 
print_ln(_Map)->

    ok.

print(Map)->
    TimeStamp=maps:get(timestamp,Map),
    {Date,Time}=maps:get(datetime,Map),
    State=maps:get(state,Map),
    Level=maps:get(level,Map),
    Msg=maps:get(msg,Map),
    SenderNode=maps:get(node,Map),
    SenderPid=maps:get(pid,Map),
    Module=maps:get(module,Map),
    FunctionName=maps:get(function,Map),
    Line=maps:get(line,Map),
    Data=maps:get(data,Map),
    R=io_lib:format("~p",[Data]),
    DataAsString=lists:flatten(R),
    io:format("~w ~w ~w ~w ~w ~w ~w ~w ~s ~s ~s ~s ~n",[Date,Time,Level,SenderNode,SenderPid,Module,FunctionName,Line,":",Msg,">>",DataAsString]),
    ok.
%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------

parse(ListRaw)->
    [parse_item(Item)||Item<-ListRaw].

parse_item({TimeStamp,_Time,SenderNode,SenderPid,Module,Function,Line,Data,MsgAsString})->
    {{Y,M,D},{H,Mi,S}}=calendar:now_to_datetime(TimeStamp),
    Year=integer_to_list(Y),
    Month=integer_to_list(M),
    Day=integer_to_list(D),
    Hour=integer_to_list(H),
    Min=integer_to_list(Mi),
    Sec=integer_to_list(S),

    SenderNodeStr=atom_to_list(SenderNode),
    SenderPidStr=pid_to_list(SenderPid),
    ModuleStr=atom_to_list(Module),
    FunctionStr=atom_to_list(Function),
    LineStr=integer_to_list(Line),
    
    
    DateTime=Year++"-"++Month++"-"++Day++" | "++Hour++":"++Min++":"++Sec++" | ",
    Text=DateTime++SenderNodeStr++" | "++SenderPidStr++" | "++ModuleStr++":"++FunctionStr++"/"++LineStr++" |  Msg : "++MsgAsString,
    [Text,Data].
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
%create_logger(LogDir)->

create_logger(MainLogDir,LocalLogDir,LogFile,MaxNumFiles,MaxNumBytes)->
    LocalLogDirFullPath=filename:join(MainLogDir,LocalLogDir),
    LogFileFullPath=filename:join(LocalLogDirFullPath,LogFile),
  
    file:make_dir(MainLogDir),
    file:make_dir(LocalLogDirFullPath),
    Result=case logger:add_handler(my_standar_disk_h, logger_std_h,
			  #{formatter => {logger_formatter,
					  #{ template => [
							  timestamp," | ",
							  sender_time," | ",
							  level," | ",
							  sender_node," | ",
							  sender_pid," | ",
							  sender_module," | ",
							  sender_function," | ",
							  sender_line," | ",
							  msg," | ",
							  sender_data,"\n"
							 ]}}}) of
	       {error,{already_exist,my_standar_disk_h}}->
		   add_handler(LogFileFullPath,LocalLogDirFullPath,MaxNumFiles,MaxNumBytes);
	       {error,Reason}->
		   {error,["Error when creating LogFile :",LocalLogDirFullPath,Reason,?MODULE,?LINE]};
	       ok->
		   add_handler(LogFileFullPath,LocalLogDirFullPath,MaxNumFiles,MaxNumBytes)
	   end,
    Result.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
add_handler(LogFileFullPath,LocalLogDirFullPath,MaxNumFiles,MaxNumBytes)->
  %  io:format("add_handler ~p~n",[{LogFileFullPath,LocalLogDirFullPath,MaxNumFiles,MaxNumBytes,?MODULE,?LINE}]),
    case logger:add_handler(my_disk_log_h, logger_disk_log_h,
			    #{
			      config => #{file => LogFileFullPath,
					  type => wrap,
					  max_no_files => MaxNumFiles,  % 4
					  max_no_bytes => MaxNumBytes,    %1000*100,
					  filesync_repeat_interval => 1000},
			      formatter => {logger_formatter,
					    #{ template => [
							    timestamp," | ",
							    sender_time," | ",
							    level," | ",
							    sender_node," | ",
							    sender_pid," | ",
							    sender_module," | ",
							    sender_function," | ",
							    sender_line," | ",
							    msg," | ",
							    sender_data,"\n"
							   ]}}}) of
	{error,Reason}->
	    {error,["Error when creating LogFile :",LocalLogDirFullPath,Reason,?MODULE,?LINE]};
		       ok-> 
	    ok
    end.
