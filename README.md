# Stand up k3s with rook

This simple Vagrantfile stands up a [k3s](https://k3s.io) cluster consisting of three nodes, and installs [Rook](https://rook.io) with a [Ceph](https://ceph.io) cluster.

## Usage

Deployment happens in two stages: first, the VMs are started and provisioned, then a Rook Ceph cluster is created.

1. Bringing up the cluster
```
$ vagrant up
```

1. Configuring the Ceph cluster
```
$ vagrant ssh
Linux node-1 4.19.0-14-amd64 #1 SMP Debian 4.19.171-2 (2021-01-30) x86_64
vagrant@node-1:~$ sudo -i
root@node-1:~# sh /vagrant/configure-rook-cluster.sh
```

## Vagrant Configuration

The three VMs are called `node-1` to `node-3`. `node-1` is the primary node (default for `vagrant`), and will be the k3s master. The IPs are hardcoded as 192.168.33.11-13.

Each VM will receive a second disk with 1GB, which will be used as Ceph storage (`sdb`).

## TODO

- Configure Ceph RBD storage class as default
- Deploy example/demo app
