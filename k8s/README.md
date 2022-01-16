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

## NGINX Ingress Controller

To deploy (legacy) service load balancer use the command below:

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/aws/deploy.yaml
```

## To install Fluent Bit to send logs from containers to CloudWatch Logs

```shell
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml
```
```shell
set CLUSTER_NAME=education-eks-lFTgJliq
set REGION_NAME=eu-central-1
set FLUENT_BIT_HTTP_PORT=2020
set FLUENT_BIT_READ_FROM_HEAD=Off
set FLUENT_BIT_READ_FROM_TAIL=On
set FLUENT_BIT_HTTP_SERVER=On
kubectl create configmap fluent-bit-cluster-info ^
--from-literal=cluster.name=%CLUSTER_NAME% ^
--from-literal=http.server=%FLUENT_BIT_HTTP_SERVER% ^
--from-literal=http.port=%FLUENT_BIT_HTTP_PORT% ^
--from-literal=read.head=%FLUENT_BIT_READ_FROM_HEAD% ^
--from-literal=read.tail=%FLUENT_BIT_READ_FROM_TAIL% ^
--from-literal=logs.region=%REGION_NAME% -n amazon-cloudwatch
```
```shell
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml
```

The above steps create the following resources in the cluster:

A service account named Fluent-Bit in the amazon-cloudwatch namespace. This service account is used to run the Fluent Bit daemonSet. For more information, see [Managing Service Accounts](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/) in the Kubernetes Reference.

A cluster role named Fluent-Bit-role in the amazon-cloudwatch namespace. This cluster role grants get, list, and watch permissions on pod logs to the Fluent-Bit service account. For more information, see [API Overview](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#api-overview/) in the Kubernetes Reference.

A ConfigMap named Fluent-Bit-config in the amazon-cloudwatch namespace. This ConfigMap contains the configuration to be used by Fluent Bit. For more information, see [Configure a Pod to Use a ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) in the Kubernetes Tasks documentation.

If you want to verify your Fluent Bit setup, follow these steps:
1. Open the CloudWatch console at https://console.aws.amazon.com/cloudwatch/.
1. In the navigation pane, choose Logs.
1. Make sure that you're in the Region where you deployed Fluent Bit.
1. Check the list of log groups in the Region. You should see the following:
    * /aws/containerinsights/Cluster_Name/application
    * /aws/containerinsights/Cluster_Name/host
    * /aws/containerinsights/Cluster_Name/dataplane
1. Navigate to one of these log groups and check the Last Event Time for the log streams. If it is recent relative to when you deployed Fluent Bit, the setup is verified.
