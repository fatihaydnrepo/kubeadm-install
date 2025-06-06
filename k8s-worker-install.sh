#!/bin/bash

set -e

### === CONFIGURABLE === ###
K8S_VERSION="1.31.0-1.1"

### Swap Disable ###
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
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

### Kubernetes repo ###
echo "[+] Adding Kubernetes repository"
sudo apt install -y curl apt-transport-https ca-certificates gpg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubelet=$K8S_VERSION kubeadm=$K8S_VERSION kubectl=$K8S_VERSION
sudo apt-mark hold kubelet kubeadm kubectl

echo "[✓] Worker node kurulumu tamamlandı."
echo "👉 Şimdi master node'dan aşağıdaki gibi bir komut almalı ve çalıştırmalısın:"
echo ""
echo "    sudo kubeadm join <MASTER_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>"
