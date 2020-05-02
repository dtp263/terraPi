#!/bin/sh

# This installs the base instructions up to the point of joining / creating a cluster
# Based off of https://gist.github.com/alexellis/fdbc90de7691a1b9edb545c17da2d975 

curl -sSL get.docker.com | sh && \
  sudo usermod pi -aG docker

sudo dphys-swapfile swapoff && \
  sudo dphys-swapfile uninstall && \
  sudo update-rc.d dphys-swapfile remove

sudo systemctl disable dphys-swapfile

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
  sudo apt-get update -q && \
  sudo apt-get install -qy kubeadm


# Weave install
sudo curl -L git.io/weave -o /usr/local/bin/weave
sudo chmod a+x /usr/local/bin/weave

# Install etcd
sudo apt -y install wget
export RELEASE="3.3.13"
wget https://github.com/etcd-io/etcd/releases/download/v${RELEASE}/etcd-v${RELEASE}-linux-amd64.tar.gz

tar xvf etcd-v${RELEASE}-linux-amd64.tar.gz
cd etcd-v${RELEASE}-linux-amd64
sudo mv etcd etcdctl /usr/local/bin

sudo mkdir -p /var/lib/etcd/
sudo mkdir /etc/etcd

sudo groupadd --system etcd
sudo useradd -s /sbin/nologin --system -g etcd etcd

  
echo Adding " cgroup_enable=cpuset cgroup_memory=1" to /boot/cmdline.txt

sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1"
echo $orig | sudo tee /boot/cmdline.txt

echo Please reboot