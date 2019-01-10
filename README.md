#### Steps to reproduce problem with stopping PostgreSql DB correctly when logical replication is running

1. Setup PG DB version 10::
    
```
PATH=$PATH:/usr/lib/postgresql/10/bin/ ./setup_test_db.sh
```

2. Start PG DB version 10::
    
```
PATH=$PATH:/usr/lib/postgresql/10/bin/ ./start_test_db.sh
```

3. Create test DB
    
```
make create_testdbs
```

4. Run Erlang app
    
```
make run
```

5. Wait 2 minutes then try to stop PG DB by sending `Ctrl+C`. 
PG DB will not stop until you stop Erlang app. 

6. Change sys.config, set `{align_lsn, true}`. Repeat steps 4-5 to check that PG DB can be stopped correctly. 
