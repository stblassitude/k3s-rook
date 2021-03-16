#!/bin/sh

#
# Provision k3s and rook
#

ip="$1"

wait_for_cluster() {
  while :; do
    kubectl cluster-info && return
    sleep 1
  done
}

update_k3s_config() {
  mkdir -p /etc/rancher/k3s
  echo -n "" >/etc/rancher/k3s/config.yaml
  echo "node-ip: $ip" >>/etc/rancher/k3s/config.yaml
  echo "flannel-iface: eth1" >>/etc/rancher/k3s/config.yaml
}

set -e
#set -vx

if [ "node-1" = "$(hostname)" ]; then
  # main node
  apt update
  apt install -y lvm2
  update_k3s_config
  curl -sfL https://get.k3s.io | sh -s - -- --flannel-iface=eth1

  wait_for_cluster
  # ip -d l show flannel.1
  cp /var/lib/rancher/k3s/server/node-token /vagrant/k3token
  mkdir -p ~/.kube
  kubectl config view --raw >~/.kube/config
  chmod 0600 ~/.kube/config

  if which helm >/dev/null; then
    : # helm already installed
  else
    curl https://baltocdn.com/helm/signing.asc | apt-key add -
    apt-get install apt-transport-https --yes
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
    apt-get update
    apt-get install helm
  fi

  helm repo add rook-release https://charts.rook.io/release
  kubectl create namespace rook-ceph --dry-run=client -o yaml | kubectl apply -f -
  helm install --namespace rook-ceph rook-ceph rook-release/rook-ceph
else
  # additional nodes
  apt update
  apt install -y lvm2
  update_k3s_config
  curl -sfL https://get.k3s.io | K3S_URL=https://192.168.33.11:6443 K3S_TOKEN=$(cat /vagrant/k3token) sh -s - -- --node-ip=192.168.33.11 --flannel-iface=eth1
fi
