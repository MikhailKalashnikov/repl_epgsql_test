CREATE USER repl_epgsql_test WITH REPLICATION PASSWORD 'repl_epgsql_test';

DROP DATABASE IF EXISTS repl_epgsql_test;

CREATE DATABASE repl_epgsql_test WITH ENCODING 'UTF8';

GRANT ALL ON DATABASE repl_epgsql_test to repl_epgsql_test;

\c repl_epgsql_test;

CREATE TABLE test_table1 (id serial primary key, value text);
CREATE TABLE test_table2 (id serial primary key, value text);

GRANT ALL ON TABLE test_table1 TO repl_epgsql_test;
GRANT ALL ON TABLE test_table2 TO repl_epgsql_test;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO repl_epgsql_test;

CREATE PUBLICATION repl_epgsql_test_repl_set FOR TABLE test_table1;