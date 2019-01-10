-module(repl_epgsql_test_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Child1 = #{id => repl_epgsql_test_server, start => {repl_epgsql_test_server, start_link, []}},

    {ok, { {one_for_all, 0, 1}, [Child1]} }.
