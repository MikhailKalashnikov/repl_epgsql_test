REBAR = rebar3

run:
	@$(REBAR) run

create_testdbs:
	# Uses the test environment set up with setup_test_db.sh
	echo "CREATE DATABASE ${USER};" | psql -h 127.0.0.1 -p 10432 template1
	psql -h 127.0.0.1 -p 10432 template1 < ./priv/test_schema.sql

.PHONY: compile clean create_testdbs
