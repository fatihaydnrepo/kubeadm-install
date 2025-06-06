#!/bin/bash

set -e

### Değiştirilebilir Değerler ###
POD_CIDR="10.244.0.0/16"
HOSTNAME="master"
K8S_VERSION="1.31.0-1.1"


### Hostname ayarla ###
echo "[+] Setting hostname to $HOSTNAME"
sudo hostnamectl set-hostname $HOSTNAME

### Swap kapat ###
echo "[+] Disabling swap"
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

### Kernel modülleri ###
echo "[+] Loading kernel modules"
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

### sysctl ayarları ###
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

### containerd kurulumu ###
echo "[+] Installing containerd"
sudo apt update && sudo apt install -y containerd

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

# systemd cgroup aktif et
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

### Kubernetes repo ekle ###
echo "[+] Adding Kubernetes apt repository"
sudo apt install -y curl apt-transport-https ca-certificates gpg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.gpg > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

### kubeadm, kubelet, kubectl kurulumu ###
echo "[+] Installing kubeadm, kubelet, kubectl (v$K8S_VERSION)"
sudo apt install -y kubelet=$K8S_VERSION kubeadm=$K8S_VERSION kubectl=$K8S_VERSION
sudo apt-mark hold kubelet kubeadm kubectl

### kubeadm init ###
echo "[+] Initializing cluster with kubeadm"
sudo kubeadm init --pod-network-cidr=$POD_CIDR --kubernetes-version=v${K8S_VERSION%-*}

### kubeconfig ayarları ###
echo "[+] Configuring kubectl"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

### calico  kur ###
echo "[+] Installing calico CNI"
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

### Bilgilendirme ###
echo "[✓] Kurulum tamamlandı. Kubeconfig ayarlandı."
kubectl get nodes
