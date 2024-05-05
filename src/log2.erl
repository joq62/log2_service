%%%-------------------------------------------------------------------
%%% @author c50 <joq62@c50>
%%% @copyright (C) 2023, c50
%%% @doc
%%%
%%% @end
%%% Created :  2 Jun 2023 by c50 <joq62@c50>
%%%-------------------------------------------------------------------
-module(log2). 

-behaviour(gen_server).

-include("log.api").
-include("logs2.hrl").
-include("db_log2.hrl").
-include("log2.rd").
%% API
-export([
	 debug/3,
	 notice/3,
	 warning/3,
	 alert/3
	]).

-export([
	 format/1, 
	 read_all_latest/1,
	 read_all_levels/0,
	 read_level/1,
	 read_level/2,
	 read_node/1,

	 read_all/0


	]).


-export([
	 get_state/0,
	 ping/0,
	 start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3, format_status/2]).

-define(SERVER, ?MODULE).

-record(state, {
	
	
	       }).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%% @end
%%--------------------------------------------------------------------
-spec start_link() -> {ok, Pid :: pid()} |
	  {error, Error :: {already_started, pid()}} |
	  {error, Error :: term()} |
	  ignore.
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% creates format Info and Data for io:format(Info,Data)
%% @end
%%--------------------------------------------------------------------
-spec format(LevelInfoMap :: map())-> {Info :: string(),Data :: term()} | {error,Reason :: term()}.
format(LevelInfoMap)->
    gen_server:call(?SERVER, {format,LevelInfoMap},infinity).

%%--------------------------------------------------------------------
%% @doc
%% Returns list og Maps that contains all info
%% @end
%%--------------------------------------------------------------------
-spec read_all_latest(Num ::integer())-> ListOfLevelInfo :: term().
read_all_latest(Num)->
    gen_server:call(?SERVER, {read_all_latest,Num},infinity).

%%--------------------------------------------------------------------
%% @doc
%% Returns list og Maps that contains all info
%% @end
%%--------------------------------------------------------------------
-spec read_all_levels()-> ListAllInfo :: term().
read_all_levels()->
    gen_server:call(?SERVER, {read_all_levels},infinity).
%%--------------------------------------------------------------------
%% @doc
%% Returns [{Id,Num,InfoList}]
%% @end
%%--------------------------------------------------------------------
-spec read_all()-> CompleteTable :: term().
read_all()->
    gen_server:call(?SERVER, {read_all},infinity).

read_level(LogLevel)->
    gen_server:call(?SERVER, {read_level,LogLevel},infinity).

read_level(LogLevel,Num)->
    gen_server:call(?SERVER, {read_level,LogLevel,Num},infinity).

read_node(Node)->
    gen_server:call(?SERVER, {read_node,Node},infinity).


%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
debug(Msg,Data,{SenderNode,SenderPid,Module,FunctionName,Line,TimeStamp})->
    gen_server:cast(?SERVER, {debug,Msg,Data,{SenderNode,SenderPid,Module,FunctionName,Line,TimeStamp}}).
notice(Msg,Data,{SenderNode,SenderPid,Module,FunctionName,Line,TimeStamp})->
    gen_server:cast(?SERVER, {notice,Msg,Data,{SenderNode,SenderPid,Module,FunctionName,Line,TimeStamp}}).
warning(Msg,Data,{SenderNode,SenderPid,Module,FunctionName,Line,TimeStamp})->
    gen_server:cast(?SERVER, {warning,Msg,Data,{SenderNode,SenderPid,Module,FunctionName,Line,TimeStamp}}).
alert(Msg,Data,{SenderNode,SenderPid,Module,FunctionName,Line,TimeStamp})->
    gen_server:cast(?SERVER, {alert,Msg,Data,{SenderNode,SenderPid,Module,FunctionName,Line,TimeStamp}}).


%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
ping()-> 
    gen_server:call(?SERVER, {ping},infinity).    


get_state()->
    gen_server:call(?SERVER, {get_state},infinity).
%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%% @end
%%--------------------------------------------------------------------
init([]) ->

    {ok, #state{},0}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%% @end
%%--------------------------------------------------------------------
handle_call({format,LevelInfo},_From, State) ->
    Reply = lib_log2:format(LevelInfo),
    {reply, Reply, State};

handle_call({read_all},_From, State) ->
    Reply = lib_db_log2:read_all(),
    {reply, Reply, State};

handle_call({read_all_levels},_From, State) ->
    Reply = lib_db_log2:read_all_levels(),
    {reply, Reply, State};

handle_call({read_level,Level},_From, State) ->
    Reply = lib_db_log2:read_level(Level),
    {reply, Reply, State};


handle_call({read_level,Level,Num},_From, State) ->
    Reply = lib_db_log2:read_level(Level,Num),
    {reply, Reply, State};


handle_call({read_node,Node},_From, State) ->
    Reply = lib_db_log2:read_node(Node),
    {reply, Reply, State};



handle_call({get_state},_From, State) ->
    Reply=State,
    {reply, Reply, State};

handle_call({ping},_From, State) ->
    Reply=pong,
    {reply, Reply, State};

handle_call({stopped},_From, State) ->
    Reply=ok,
    {reply, Reply, State};


handle_call({not_implemented},_From, State) ->
    Reply=not_implemented,
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    %rpc:cast(node(),log,log,[?Log_ticket("unmatched call",[Request, From])]),
    Reply = {ticket,"unmatched call",Request, From},
    {reply, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%% @end
%%--------------------------------------------------------------------
handle_cast({Level,Msg,Data,{SenderNode,SenderPid,Module,FunctionName,Line,TimeStamp}}, State) ->
    ok=lib_db_log2:create({Level,Msg,Data,SenderNode,SenderPid,Module,FunctionName,Line,TimeStamp}),
    {noreply,State};

handle_cast(_Msg, State) ->
  %  rpc:cast(node(),log,log,[?Log_ticket("unmatched cast",[Msg])]),
    {noreply, State}.


%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%% @end
%%--------------------------------------------------------------------
handle_info(timeout, State) ->

  %  file:make_dir(?MainLogDir),
  %  [NodeName,_HostName]=string:tokens(atom_to_list(node()),"@"),
  %  NodeNodeLogDir=filename:join(?MainLogDir,NodeName),
  %  ok=log:create_logger(NodeNodeLogDir,?LocalLogDir,?LogFile,?MaxNumFiles,?MaxNumBytes),

    [rd:add_local_resource(ResourceType,Resource)||{ResourceType,Resource}<-?LocalResourceTuples],
    [rd:add_target_resource_type(TargetType)||TargetType<-?TargetTypes],
    rd:trade_resources(),
    timer:sleep(2000),
    Log2Nodes=lists:delete(node(),rd:fetch_nodes(log2)),
    ?LOG_NOTICE(" log2 nodes",[node(),Log2Nodes]),
    case Log2Nodes  of
	[]->
	    ok=lib_dbase:dynamic_db_init([]),
	    ok=lib_db_log2:create_table();
	Log2Nodes->
	    ok=lib_dbase:dynamic_db_init(Log2Nodes)
    end,
    ?LOG_NOTICE("Server started",[?MODULE]),
    {noreply, State};

handle_info(Info, State) ->
    io:format("dbg unmatched signal ~p~n",[{Info,?MODULE,?LINE}]),
    %rpc:cast(node(),log,log,[?Log_ticket("unmatched info",[Info])]),
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%% @end
%%--------------------------------------------------------------------
-spec terminate(Reason :: normal | shutdown | {shutdown, term()} | term(),
		State :: term()) -> any().
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%% @end
%%--------------------------------------------------------------------
-spec code_change(OldVsn :: term() | {down, term()},
		  State :: term(),
		  Extra :: term()) -> {ok, NewState :: term()} |
	  {error, Reason :: term()}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called for changing the form and appearance
%% of gen_server status when it is returned from sys:get_status/1,2
%% or when it appears in termination error logs.
%% @end
%%--------------------------------------------------------------------
-spec format_status(Opt :: normal | terminate,
		    Status :: list()) -> Status :: term().
format_status(_Opt, Status) ->
    Status.

%%%===================================================================
%%% Internal functions
%%%===================================================================
