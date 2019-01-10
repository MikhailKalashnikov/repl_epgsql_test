-module(repl_epgsql_test_server).

-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([handle_x_log_data/4]).

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([code_change/3]).
-export([terminate/2]).

-record(state, {conn}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    process_flag(trap_exit, true),
    DBArgs = application:get_env(repl_epgsql_test, db_args, []),
    {ok, Conn} = connect(DBArgs, replication),

    {ok, _, _} =  epgsql:squery(Conn, "CREATE_REPLICATION_SLOT repl_epgsql_test_replication_slot_1 TEMPORARY LOGICAL pgoutput"),
    ok = start_replication(Conn),
    io:format("replication started ~n"),
    self() ! insert_test_data,
    {ok, #state{conn = Conn}}.

handle_call(_Req, _From, State) -> {reply, ok, State}.
handle_cast(_Msg, State) -> {noreply, State}.
handle_info(insert_test_data, State) ->
    DBArgs = application:get_env(repl_epgsql_test, db_args, []),
    {ok, Conn} = connect(DBArgs, normal),
    epgsql:squery(Conn, "INSERT INTO test_table1 (value) VALUES ('one');"),
    epgsql:squery(Conn, "INSERT INTO test_table2 (value) VALUES ('two');"),
    epgsql:close(Conn),
    {noreply, State};
handle_info(_Msg, State) -> {noreply, State}.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_Reason, #state{conn = Conn}) ->
    epgsql:close(Conn),
    ok.

connect(DBArgs, Mode) ->
    Host = proplists:get_value(hostname, DBArgs),
    DBName = proplists:get_value(database, DBArgs),
    User = proplists:get_value(username, DBArgs),
    Password = proplists:get_value(password, DBArgs),
    Port     = proplists:get_value(port, DBArgs, 5432),

    epgsql:connect(
        Host, User, Password,
        [{database, DBName}, {port, Port}
        | case Mode of replication -> [{replication, "database"}]; _ -> [] end]).

start_replication(Conn) ->
    AlignLSN = application:get_env(repl_epgsql_test, align_lsn, false),
    epgsql:squery(Conn, "IDENTIFY_SYSTEM"),
    epgsql:start_replication(Conn,
        "repl_epgsql_test_replication_slot_1", ?MODULE,
        #{},
        "0/0",
        "proto_version '1', publication_names '\"repl_epgsql_test_repl_set\"'",
        [{align_lsn, AlignLSN}]).

handle_x_log_data(_StartLSN, EndLSN, _, CbState) ->
    io:format("handle_x_log_data EndLSN ~p~n", [EndLSN]),
    {ok, EndLSN, EndLSN, CbState}.