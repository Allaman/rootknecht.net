---
title: Kubernetes
summary: Notes on working with Kubernetes
---

## Installation on a "bare metal" single Node

There are quite a lot of options [how to install a kubernetes cluster](https://kubernetes.io/docs/setup/pick-right-solution/).

## Scaling deployment deletion sequence

Pod deletion preference is based on an ordered series of checks, defined in code here:
https://github.com/kubernetes/kubernetes/blob/release-1.11/pkg/controller/controller_utils.go#L737

Summarizing- precedence is given to delete pods:

- that are unassigned to a node, vs assigned to a node
- that are in pending or not running state, vs running
- that are in not-ready, vs ready
- that have been in ready state for fewer seconds
- that have higher restart counts
- that have newer vs older creation times
- These checks are not directly configurable.

<small>[origin](https://stackoverflow.com/a/51471388)</small>

## Check permission of service accounts

```sh
kubectl auth can-i list deployment --as=system:serviceaccount:default:<NAME> -n <NAME>
```

## Get logs from an unknown pod

```sh
 kubectl logs --tail 20  $(kubectl get pods -l=app=flux -o jsonpath="{.items[0].metadata.name}")
```

## Run a quick pod for testing

```sh
kubectl run test -n NAMESPACE --rm -i --tty --image debian -- bash
```

## Get kubeconfig via AWS cli

```sh
aws --profile=<AWS PROFILE> eks update-kubeconfig --name <CLUSTER NAME>
```

## List running pods per namespace

```sh
#!/bin/bash

for ns in $(kubectl get ns | awk '{print $1}' | awk '{if (NR!=1) {print}}')
do
  echo Checking $ns
  kubectl get pods -n $ns | awk '{print $1}' | awk '{if (NR!=1) {print}}' | grep -v -E ".*flux-system.*|.*helm-operator.*" | wc -l
done
```

## Kubernetes limits and requests

### CPU

If no CPU limit is specified then one of these situations applies:

- The Container has no upper bound on the CPU resources it can use. The Container could use all of the CPU resources available on the Node where it is running.
- The Container is running in a namespace that has a default CPU limit, and the Container is automatically assigned the default limit. Cluster administrators can use a LimitRange to specify a default value for the CPU limit

If you specify a CPU limit for a Container but do not specify a CPU request, Kubernetes automatically assigns a CPU request that matches the limit. Similarly, if a Container specifies its own memory limit, but does not specify a memory request, Kubernetes automatically assigns a memory request that matches the limit.

By configuring CPU requests and limits, you can make efficient use of the CPU resources available on your cluster's Nodes. By keeping a pod's CPU request low, you give the pod a good chance of being scheduled. By having a CPU limit that is greater than the CPU request, you accomplish two things:

- the pod can have bursts of high processing demands
- The amount of CPU resources a pod can use during a burst is limited to some reasonable amount.

### Memory

A container's memory request can be exceeded if a node has memory available but a container is not allowed to use more than its memory limit. If a Container allocates more memory than its limit, the Container becomes a candidate for termination. If the Container continues to consume memory beyond its limit, the Container is terminated. If a terminated Container can be restarted, the kubelet restarts it, as with any other type of runtime failure.

If no memory limit is specified on of these situations applies:

- The container could use all of the memory available on the node where it is running which could invoke the OOM killer. In case of an OOM kill, a container with no resource limits will have a greater change of being killed.
- The Container is running in a namespace that has a default memory limit, and the Container is automatically assigned the default limit. Cluster administrators can use a LimitRange to specify a default value for the memory limit.

If you specify a CPU limit for a Container but do not specify a CPU request, Kubernetes automatically assigns a CPU request that matches the limit. Similarly, if a Container specifies its own memory limit, but does not specify a memory request, Kubernetes automatically assigns a memory request that matches the limit.

By configuring memory requests and limits, you can make efficient use of the memory resources available on your cluster's Nodes. By keeping a pod's memory request low, you give the pod a good chance of being scheduled. By having a memory limit that is greater than the memory request, you accomplish two things:

- the pod can survive bursts of high memory demands, e.g. exceptional high traffic
- the amount of memory in case of a burst is limited and the pod will not affect the node's health

### Quality of service

> Kubernetes uses QoS classes to make decisions about scheduling and evicting pods.

- BestEffort

  The container(s) of a pod do not have any memory or CPU limis or requests.

- Guaranteed

  - Every container must have a memory limit and a memory request which must be equal
  - Every container must have a CPU limit and a CPU request which must be equal

  These restrictions apply to init containers and app containers equally.

- Burstable

  At least one of the pod's container has a memory or CPU request or limit but the criteria of Guaranteed are not fulfilled.

## Deploy Dashboard

Deploy dashboard

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
```

Start proxy

```bash
kubectl proxy [-p 8080]
```

Access dashboard http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/ (adjust port if necessary)

Get login token

```bash
kubectl -n kube-system get secret # list service accounts
kubectl -n kube-system describe secret deployment-controller-token-****
```

Alternative grant dashboard admin rights:
Create `dashboard-admin.yml' with following content:

```yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: kubernetes-dashboard
    namespace: kube-system
```

Deploy to your cluster `kubectl create -f dashboard-admin.yml`. Then you skip authentication in the login screen

## Create a (certificate based) user

1. `openssl genrsa -out ~/certs/firstname.name.key 4096`
1. `openssl req -config ~/certs/firstname.name.csr.cnf -new -key ~/certs/firstname.name.key -nodes -out ~/certs/firstname.name.csr`
1. `cat ~/certs/sammy.csr | base64 | tr -d '\n'`
1. `kubectl get csr`
1. `kubectl certificate approve firstname.name-authentication`
1. `kubectl get csr firstname.name-authentication -o jsonpath='{.status.certificate}' | base64 --decode > firstname.name.crt`
1. `kubectl config view --raw -o json | jq -r '.clusters[] | select(.name == "'$(kubectl config current-context)'") | .cluster."certificate-authority-data"'`

Links:

- [Secure DO K8s cluster](https://www.digitalocean.com/community/tutorials/recommended-steps-to-secure-a-digitalocean-kubernetes-cluster)
- [Configure RBAC in your k8s cluster](https://docs.bitnami.com/tutorials/configure-rbac-in-your-kubernetes-cluster/)
- [k8s client certificate](https://medium.com/better-programming/k8s-tips-give-access-to-your-clusterwith-a-client-certificate-dfb3b71a76fe)

## Create a Kubernetes cron for time-based scaling of deployments

```yaml
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: namespace
  name: scaling
# Adjust permissions to your specific needs
# This allows full rights to all resources in your namespace
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: scaling
  namespace: namespace
subjects:
  - kind: ServiceAccount
    name: sa-scaling
    namespace: namespace
roleRef:
  kind: Role
  name: scaling
  apiGroup: ""
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sa-scaling
  namespace: namespace
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: scaling
  namespace: namespace
spec:
  # Adjust your schedule
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: sa-scaling
          containers:
            - name: kubectl
              image: bitnami/kubectl:1.17.0
              command:
                - /bin/sh
                - -c
                # Adjust to your needs
                - kubectl scale --current-replicas=1 --replicas=2 deployment/foobar
          restartPolicy: OnFailure
```
