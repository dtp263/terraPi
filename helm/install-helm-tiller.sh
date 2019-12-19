#!/bin/sh

# This installs Helm and Tiller components into an
# existing Raspberri Pi Kubernetes cluster.

wget https://get.helm.sh/helm-v3.0.1-linux-arm.tar.gz


tar -zxvf helm-v3.0.0-linux-amd64.tgz
sudo mv linux-arm/helm /bin/helm
rm -rf linux-arm
