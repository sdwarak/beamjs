-module(beamjs).

-export([start/0,stop/0,main/1]).

start() ->
	application:start(beamjs).

stop() ->
	application:stop(beamjs).

args([]) ->
	ok;
args(["-sname",Node|Rest]) ->
	net_kernel:start([list_to_atom(Node),shortnames]),
	args(Rest);
args(["-name",Node|Rest]) ->
	net_kernel:start([list_to_atom(Node),longnames]),
	args(Rest);
args(["-toolbar"|Rest]) ->
	toolbar:start(),
	args(Rest);

args(File) when is_list(File) ->
	{ok, B} = file:read_file(File),
	S = binary_to_list(B),
	{ok, Script} = erlv8:new_script(S),
	erlv8_script:run(Script),
	Script.
	
main(Args) ->
	case os:getenv("ERLV8_SO_PATH") of
		false ->
			os:putenv("ERLV8_SO_PATH","./deps/erlv8/priv")
	end,
	erlv8:start(),
	start(),
	case args(Args) of
		ok ->
			supervisor:start_child(beamjs_repl_sup,["beam.js> ", beamjs_repl_console]);
		Script ->
			supervisor:start_child(beamjs_repl_sup,["beam.js> ", beamjs_repl_console, Script])
	end,
	receive 
		_ ->
			ok
	end.

	
