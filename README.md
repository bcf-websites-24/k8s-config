# Kubernetes Configuration Setup

This repository contains the necessary Kubernetes configuration files to set up and manage the `buetcsefest2024-k8s` Kubernetes cluster. Follow the steps bellow to setup the cluster and all the necessary resources.

## Prerequisites

Before you begin, ensure you have the following installed:
- [doctl](https://docs.digitalocean.com/reference/doctl/how-to/install/) (DigitalOcean command-line tool)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (Kubernetes command-line tool)
- [Kubernetes Cluster](https://kubernetes.io/docs/setup/) (on DigitalOcean)
- [Helm](https://helm.sh/docs/intro/install/) (installed locally)

## Step-by-Step Instructions

### 1. Clone the Repository

First, clone this repository to your local machine:

```bash
git clone https://github.com/risenfromashes/k8s-config.git
cd k8s-config
```

### 2. Set Up Your Kubernetes Context

Setup `kubectl` config using `doctl`.
```bash
doctl kubernetes cluster kubeconfig save <cluster-id>
```

Alternatively, you can download the config file and place it in `~/.kube/config`.

Ensure that your Kubernetes context is properly configured to point to the cluster. Verify the context using:

```bash
kubectl config current-context
```


### 3. Setup NGINX Ingress Controller

Check that `helm` is installed.

```bash
helm version
```
Now run the script to install `ingress-ngnix` to the cluster.

```bash
./install-ingress-nginx.sh
```

Check the state of the load balancer.

```bash
kubectl get svc -n ingress-nginx
```

### 4. Setup Certificate Manager

Run the scripts to install `cert-manager` to the cluster.

```bash
./install-cert-manager.sh
```

Now configure the `ClusterIssuer` to issue certificates using lets-encrypt.

```bash
kubectl apply -f cert-manager-cluster-issuer.yaml
```

Check the status of the `ClusterIssuer`.

```bash
kubectl get clusterissue
```

### 5. Enable/Disable Proxy Protocol in the Load Balancer

Enabling proxy protocol has a number of benefits:
  1. Client IP becomes visible to the pods.
  2. Load Balancers usually have a limit on new SSL connections per second. Using SSL passthrough bypasses this limitation.

Proxy Protocol and SSL passthrough can be enabled by running the following script.

```bash
./update-ingress-nginx.sh
```

However, enabling Proxy Protocol has a significant drawback, **Certificate Manager fails to complete the HTTP-01 challenge to issue certificates for new subdomains.**

Therefore, it is necessary to revert to the default `ingress-nginx` configuration before configuring ingress on a new sub-domain. 

```bash
./revert-ingress-nginx.sh
```

### 6. Container Registry Integration

Before deployment using private docker images, the DigitalOcean docker registry should be integrated with the kubernetes cluster. This can be done from the DigitalOcean control panel, in the page associated with the registry.

### 7. Configuring DNS on DigitalOcean

Before creating a service/website hosted on xxxxx.buetcsefest2024.com, a `xxxxx` `A` record must be added to the DNS records on DigitalOcean. The IP address should point to the Load Balancer created after installing `ingress-nginx`.

### 8. Install Metric Server

Install the Metric Server to the cluster using the marketplace 1-click app or using the script.

```bash
./install-metric-server.sh
```

### 9. Automatic Deployment

Using Github Actions workflow, repositories will automatically deploy to the kubernetes cluster if the following are done correctly,
  * Dockerizating of the application with a `Dockerfile`.
  * Storing necessary keys and variables (including the DigitalOcean API key) in Github Action Secrets.
  * Using `doctl` to authenticate `docker` and `kubectl` for the DigitalOcean registry and cluster respectively.
  * Pushing the image to the DigitalOcean registry.
  * Replace the image name using the recently pushed image in the deployment configuration.
  * For configuring a service on a new subdomain, making sure that Proxy Protocol is disabled in the Load Balancer.
  * Setting up the Metric Server for HPA (Horizontal Pod Autoscaling).
  * The namespace referred to in the configuration files has been created using `kubectl create ns <namespace>`.
  * Configuring the `deployment`, `service`, `ingress` and `hpa` using `kubectl`.
  

That's it for now!

### Additional files
* `old-values.yaml` is the default values file of `ingress-nginx`
* `nginx-values.yaml` is the modified values file with Proxy Protocol and SSL passthrough enabled.
* `load-generator.yaml` file creates a deployment to push heavy load on the `pp` deployment. 
* `echo.yaml` for a test deployment, service and ingress to check if services can be created on new subdomains.

### Some Important Commands
* `kubectl get <resource> -n <namespace>` - Lists all of a type of resource in a namespace. `<resource>` can be any kubernetes resource, including-
  * `deployment` 
  * `pod` 
  * `rs` - Replicaset
  * `svc` - Service
  * `ingress`
  * `node`
  * `hpa`
  * `certificate`
* `kubectl get <resource> --all-namespaces` - Lists all of a type of resource in all namespaces.
* `kubectl describe <resource> [NAME] -n <namespace>/--all-namespaces` - A more detailed description along with some event logs of a resource.
* `kubectl top pods/nodes -n <namespace>/--all-namespaces` - Get the resource utilization of the nodes or pods in the cluster.
* `kubectl apply -f <config-file>` - Change the configuration file for a resource, create if not already present.
* `kubectl delete -f <config-file>` - Delete the resource configured in the file.
* `kubectl create ns <namespace>` - Create a new namespace.
* `kubectl delete ns <namespace>` - Delete a namespace.
* `kubectl exec -i -t <name> -n <namespace> -- <command>` - Run `command` in an interactive shell inside a pod.
