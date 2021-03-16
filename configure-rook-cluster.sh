#!/bin/sh

#
# After all nodes are up and running, configure a Ceph cluster.
#

kubectl apply -f /vagrant/rook-cluster.yaml
kubectl apply -f /vagrant/rook-toolbox.yaml
