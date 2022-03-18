# The planA project - level 2

## Creating one or more clusters via terraform using the Amazon Elastic Kubernetes Service resource.

*Always install the latest versions to access all features.

**Installation examples for UBUNTU/Linux system. If necessary, consult the web about your system.

### Requirements 

[Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

[AWS cli](https://docs.aws.amazon.com/pt_br/cli/latest/userguide/install-linux.html)

[Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)



1. Check the requirements installations.

2.  Using git, clone the repository where the project's terraform (.tf) files are located on your machine.

3. Configure the aws cli with the command "aws configure" and enter the access credentials (access key and secret access key). With this, you can later view and manipulate the cluster remotely.

* The user creating the cluster will have full access (master).

## Creating the cluster with Terraform

With all the requirements installed and aws cli configured, now using your computer's terminal, navigate to the directory that was cloned earlier with the project's base files.

If there are any changes to be made such as: cluster name, nodes to be created, etc., do so in the editor of your choice and then start creating the cluster according to the steps below.

To start terraform:
```bash
terraform init
```
To plan the creation, check for possible errors and check everything that will be done, use:
```bash
terraform plan
```
And, if everything is correct, to apply and start the creation process that was described in the previous phase, use:
```bash
terraform apply
```

*Wait until each of these steps is complete before moving on to the next.


## Post creation

Now that the cluster is already created in AWS, let's get access to it.
With that, given that the aws cli was previously and correctly configured, we need to connect and get the settings and access to the cluster.

For this, we will use the following command:
```bash
aws eks --region <region-code> update-kubeconfig --name <name-of-cluster>
```

Where, by default in the already created terraform files we have as: Region (us-east-1) North Virginia and, cluster name: (pv-eks-cluster). Resulting in the following command:
```bash
aws eks --region us-east-1 update-kubeconfig --name pv-eks-cluster
```

## Checking cluster access

To check if your machine is seeing the cluster use:
```bash
kubectl get svc
```

The result should be something like:
```bash
  NAME             TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE

  svc/kubernetes   ClusterIP   10.100.0.1   <none>        443/TCP   1m
```

## Permissions for IAM users

If necessary, to access the cluster through the AWS console, we must edit the configmap/aws-auth. And it must be done using the following command:
```bash
kubectl edit -n kube-system configmap/aws-auth
```

*In the "/config" folder of the repository there is a file already configured that can be used as an example (configmap-aws-auth.yaml). If necessary, change the users and paste the content in the configuration file accessed by the command above.

## Installing Kubernetes Metrics Server

In order for us to have and view server metrics in Kubernetes Dashboard, we need to install Metrics server.
Using a single command in the terminal:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

To check if the metric server is running use:
```bash
kubectl get deployment metrics-server -n kube-system
```

The expected output should be:
```bash
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
metrics-server   1/1     1            1           6m
```

## Installing Kubernetes Dashboard

Now with Metrics Server installed, we can install the dashboard.
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.5/aio/deploy/recommended.yaml
```
The expected terminal output should be:
```bash
namespace/kubernetes-dashboard created
serviceaccount/kubernetes-dashboard created
service/kubernetes-dashboard created
secret/kubernetes-dashboard-certs created
secret/kubernetes-dashboard-csrf created
secret/kubernetes-dashboard-key-holder created
configmap/kubernetes-dashboard-settings created
role.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
deployment.apps/kubernetes-dashboard created
service/dashboard-metrics-scraper created
deployment.apps/dashboard-metrics-scraper created
```

## Creating an admin account and a cluster role binding (for dashboard use and access)

To create the account, simply navigate to "/config" where the git clone was made and, in the terminal, run the following command:
```bash
kubectl apply -f eks-admin-service-account.yaml
```

The command output should be as follows:
```bash
serviceaccount "eks-admin" created
clusterrolebinding.rbac.authorization.k8s.io "eks-admin" created
```

** The account created is cluster-admin (superuser). If necessary, check documentation and edit the file before applying.

## Connecting to the dashboard

To connect to the panel, you must first get an access token from the user (in this case, the user we created in the previous step).

User created: eks-admin

With that, we run the following command:
```bash
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
```

The command output gives us the following information and the token that will be used to connect to the panel:
```bash
Name:         eks-admin-token-b5zv4
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name=eks-admin
              kubernetes.io/service-account.uid=bcfe66ac-39be-11e8-97e8-026dce96b6e8

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      <authentication_token>
```

At the bottom we have our token. Copy the same and leave it ready to paste.

The next step is to start the proxy in kubernetes by the command:
```bash
kubectl proxy
```

And so, log in to the dashboard through the browser at the following link:

[Kubernetes dashboard](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login)

Select TOKEN, and paste the previously generated token.

* The token must be generated at each access.

## Done!

Okay, now the cluster is properly configured and connected, ready to use.


