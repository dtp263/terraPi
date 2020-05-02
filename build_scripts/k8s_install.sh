# Assume you have Raspbian lite installed on raspberry pi. with a static IP setup.

# ---- START common setup ---- #

# Install docker
curl -sSL get.docker.com | sh && \
sudo usermod pi -aG docker && \
newgrp docker

# disable swap because k8s does not like
sudo dphys-swapfile swapoff && \
sudo dphys-swapfile uninstall && \
sudo update-rc.d dphys-swapfile remove && \
sudo systemctl disable dphys-swapfile


sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt && \
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" && \
echo $orig | sudo tee /boot/cmdline.txt 

sudo reboot
# wait a min

## SSH back into the pi
mkdir -p /etc/apt/sources.list.d/kubernetes.list

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
## Expect output "OK"

sudo reboot
# wait a min

## SSH back into the pi
sudo apt-get install -qy kubeadm

# ---- END common setup ---- #

# ---- START master setup ---- #
sudo kubeadm config images pull -v3

sudo kubeadm init --token-ttl=0

## ^^^ takes a long time ^^^ ##

## in this return message there is a command that you will need to use on your slave nodes to 
## join the cluster. It looks like this
# kubeadm join --token 9e700f.7dc97f5e3a45c9e5 192.168.0.27:6443 
#    --discovery-token-ca-cert-hash sha256:95cbb9ee5536aa61ec0239d6edd8598af68758308d0a0425848ae1af28859bea

# set your kubeconfig so you can use kubectl
mkdir -p $HOME/.kube && \
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && \
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# install weavenet for comunication between nodes
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# improve kubeadm preflight message for bridge-nf-call-iptables
sudo sysctl net.bridge.bridge-nf-call-iptables=1

# ---- END master setup ---- #

# ---- START slave setup ---- #

# run the command you saved from the kubeadm init execution on your master node. It should look like this:
# sudo kubeadm join --token <token> <master-node-ip>:6443 --discovery-token-ca-cert-hash sha256:<sha256>


# ---- END slave setup ---- #