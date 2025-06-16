#!/bin/bash
# 우분투/데비안 계열 설치

# HTTP
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
# API Server 
sudo iptables -A INPUT -p tcp --dport 6443 -j ACCEPT
# etcd
sudo iptables -A INPUT -p tcp --dport 2379:2380 -j ACCEPT
# Kubelet, Controller, Scheduler
sudo iptables -A INPUT -p tcp --dport 10250:10252 -j ACCEPT  

# # Flannel VXLAN (udp)
# sudo iptables -A INPUT -p udp --dport 8285 -j ACCEPT
# # Flannel VXLAN (udp)
# sudo iptables -A INPUT -p udp --dport 8472 -j ACCEPT

# 영구 저장
sudo apt install iptables-persistent

# /etc/modules-load.d/k8s.conf 파일 생성 
sudo cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf 
br_netfilter 
EOF 

# /etc/sysctl.d/k8s.conf 파일 생성 
sudo cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf 
net.bridge.bridge-nf-call-ip6tables = 1 
net.bridge.bridge-nf-call-iptables = 1 
EOF

#시스템 재시작 없이 stysctl 파라미터 반영 
sudo sysctl --system

# 커널 모듈 및 네트워크 설정(마스터 노드 진행)
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# containerd 설치
apt install -y containerd

mkdir -p /etc/containerd

containerd config default | sudo tee /etc/containerd/config.toml

vi /etc/containerd/config.toml
# SystemdCgroup을 false에서 true로 변경
# sandbox_image를 registry.k8s.io/pause:3.8에서 registry.k8s.io/pause:3.9로 변경 

systemctl restart containerd

apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet