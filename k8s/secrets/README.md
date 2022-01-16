## Create a Secret from text files

```shell
kubectl create secret generic db-creds-and-params ^
--from-file=DB_HOST=db_host.txt ^
--from-file=DB_NAME=db_name.txt ^
--from-file=DB_LOGIN=db_login.txt ^
--from-file=DB_PASSWORD=db_password.txt
```

WARNING: When using --from-literal carefully consider if you have to use quotes or not. Also --from-literal is not very secure.