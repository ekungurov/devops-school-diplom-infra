## Create a Secret from text files

```shell
kubectl create secret generic db-creds-and-params ^
--from-file=DB_HOST=db_host.txt ^
--from-file=DB_NAME=db_name.txt ^
--from-file=DB_LOGIN=db_login.txt ^
--from-file=DB_PASSWORD=db_password.txt
```

WARNING: When using --from-literal carefully consider if you have to use quotes or not. Also --from-literal is not very secure.

## Create a Secret based on existing Docker credentials

A Kubernetes cluster uses the Secret of `kubernetes.io/dockerconfigjson` type to authenticate with
a container registry to pull a private image.

If you already ran `docker login`, you can copy that credential into Kubernetes:

```shell
kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=<path/to/.docker/config.json> \
    --type=kubernetes.io/dockerconfigjson
```

If you need more control (for example, to set a namespace or a label on the new
secret) then you can customise the Secret before storing it.
Be sure to:

- set the name of the data item to `.dockerconfigjson`
- base64 encode the docker file and paste that string, unbroken
  as the value for field `data[".dockerconfigjson"]`
- set `type` to `kubernetes.io/dockerconfigjson`
