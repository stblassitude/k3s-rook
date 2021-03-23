# Stand up k3s with rook

This simple Vagrantfile stands up a [k3s](https://k3s.io) cluster consisting of three nodes, and installs [Rook](https://rook.io) with a [Ceph](https://ceph.io) cluster.

Additionally, the following components are installed:
- [MetalLB](https://metallb.universe.tf) to provide access to apps in the cluster through `192.168.33.20`.
- [Traefik](https://github.com/traefik/traefik-helm-chart/tree/master/traefik) to provide access to apps in the cluster via Ingress definitions. You can use a DNS service like xip.io or nip.io to create hostnames that map to the MetalLB load balancer IP, for example, `ceph-dashboard.192.168.33.20.xip.io`.

## Usage

Deployment happens in two stages: first, the VMs are started and provisioned, then a Rook Ceph cluster is created.

### Bringing up the cluster
```
$ vagrant up
```

### Configuring the Ceph cluster
```
$ vagrant ssh
Linux node-1 4.19.0-14-amd64 #1 SMP Debian 4.19.171-2 (2021-01-30) x86_64
vagrant@node-1:~$ sudo -i
root@node-1:~# sh /vagrant/bin/configure-cluster
```

## Notes on Components

### k3s Configuration

The following changes are made to the default configuration of k3s:
- `node-ip` is set to the private network (192.168.33.0/24). Communication over the first interface does not work.
- `flannel-iface` is set to `eth1` for the same reason.
- Traefik is not deployed by setting `disable traefik`; k3s includes the old 1.x version of traefik; instead, we deploy the current version through Helm.
- The servicelb load balancer is disabled, since we're deploying MetalLB.

### Vagrant Configuration

The three VMs are called `node-1` to `node-3`. `node-1` is the primary node (default for `vagrant`), and will be the k3s master. The IPs are hardcoded as 192.168.33.11-13.

Each VM will receive a second disk with 1GB, which will be used as Ceph storage (`sdb`).

### Cluster Configuration Tokens

In order for the agent nodes to communicate with the master, and kubectl being able to talk to the cluster, a number of files need to be available outside the primary node. `bin/provision` copies these to `dynamic-config/k3token`, where other nodes, or the host, can pick them up.

### Kubectl Config

A kubectl config file is exported to `dynamic-config/config`. You can copy this file to `~/.kube/config`, or add the appropriate entries to your existing file, or adjust the kubectl search path by setting the KUBECONFIG environment variable.

### MetalLB Configuration

MetalLB is configured for ARP mode, using the range 192.168.33.20-29. Since Traefik is also configured at that time, it will pick up 192.168.33.20 as it's address.

### Traefik Configuration

Traefik is deployed with the default configuration. The dashboard is exposed through an IngressRoute at http://traefik.192.168.33.20.xip.io/.

### Whoami Test App

The [whoami](https://github.com/containous/whoami) mini web server is deployed through cowboysysop's [Whoami Helm Chart](https://artifacthub.io/packages/helm/cowboysysop/whoami) at http://whoami.192.168.33.20.xip.io/.

## Running Applications

The following applications are exposed through Traefik:

* [Kubernetes Dashboard](http://kubernetes-dashboard.192.168.33.20.xip.io/)
* [Traefik Dashboard](http://traefik.192.168.33.20.xip.io/dashboard/#/)
* [Ceph Dashboard](http://ceph-dashboard.192.168.33.20.xip.io/)
* [whoami test application](http://whoami.192.168.33.20.xip.io/)

## Useful commands

The following commands might be useful in checking cluster status.

* **Verify Flannel network config**: Flannel needs to talk over `eth1` instead of the default interface, to be able to communicate between nodes. Check config with: `ip -d l show flannel.1`

* **Verify Ceph status**: Run `ceph` commands through the tools pod: `/vagrant/bin/rook-ceph status`

* **Run `kubectl` on host**: Copy `dynamic-config/kube-config` to `~/.kube/config`, or set `KUBECONFIG` to include this file, then run `kubectl`.

* **Get password for Ceph Dashboard**: To log in to the [Ceph Dashboard](http://ceph-dashboard.192.168.33.20.xip.io/), you need the password from this secret: `kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo`

## TODO

- Configure Ceph RBD storage class as default
- Deploy example/demo app
