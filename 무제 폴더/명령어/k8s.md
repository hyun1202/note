# k8s 세팅

## 1. swap 비활성화
```bash
# swap 비활성화
sudo sed -i '/swap/s/^/#/' /etc/fstab
```
## 2.  iptables 추가
```bash
# HTTP
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
# API Server 
sudo iptables -A INPUT -p tcp --dport 6443 -j ACCEPT
# etcd
sudo iptables -A INPUT -p tcp --dport 2379:2380 -j ACCEPT
# Kubelet, Controller, Scheduler
sudo iptables -A INPUT -p tcp --dport 10250:10252 -j ACCEPT  
# Flannel VXLAN (udp)
sudo iptables -A INPUT -p udp --dport 8285 -j ACCEPT
# Flannel VXLAN (udp)
sudo iptables -A INPUT -p udp --dport 8472 -j ACCEPT
# 영구 저장
sudo apt install iptables-persistent
```
## 3. 네트워크 옵션 설정
```
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
```
## 4. k8s 설치
* 도커가 먼저 설치되어있어야 함

containerd 설치
```
# 커널 모듈 및 네트워크 설정(마스터 노드 진행)
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

#
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
```

```bash
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet
```
## 5. kubectl 설정
root 계정이 아닌 다른 계정에서도 kubectl 명령어 사용 가능하도록 설정.
```bash
sudo mkdir -p $HOME/.kube 
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config 
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
### 5.1 CNI(Container Network Interface) 설정
Flannel
```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```
Calico
```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/tigera-operator.yaml

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/custom-resources.yaml
```

Running이 안되면 아래 명령어 사용
```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

```bash
kubectl delete pod --all -n calico-system
```

Weave
```bash
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

CNI 적용 확인
```bash
kubectl get pods -A -o wide
```
## 6. Worker Node 구성
마스터 노드에서 `kubeadm init`을 통해 생성한 `join` 명령어를 이용하여 노드 등록
```bash
sudo kubeadm join [ip]:6443 --token [토큰명] --discovery-token-ca-cert-hash [hashkey]
```
## 7. Master node 확인
```bash
kubectl get node  
```
or
```bash
kubectl get nodes -o wide
```

## 8. 명령어

로그확인
* `namespace`가 `kube-flannel`이고 `name`이 `kube-flannel-ds-mstrw` 인 pod 로그 확인
```bash
kubectl logs -f -n kube-flannel kube-flannel-ds-mstrw
```

```bash
kubectl logs -n kube-system kube-apiserver-$(hostname) | tail -20
```

모든 pod 확인
```bash
kubectl get pods --all-namespaces
```

pod 정보 확인
```bash
kubectl describe pod pod-name
```

### 부록
#### 1. `kubeadm init` 에러
`/proc/sys/net/bridge/bridge-nf-call-iptables does not exist`와 같은 에러일 경우 
```bash
cat <  /etc/sysctl.d/k8s.conf << EOF                                
net.bridge.bridge-nf-call-ip6tables = 1                              
net.bridge.bridge-nf-call-iptables = 1                               
EOF
```

안될 시 아래 명령어 시도
```bash
sudo modprobe br_netfilter
echo 1 > sudo /proc/sys/net/bridge/bridge-nf-call-iptables
```

ip_forward 활성화
```bash
echo '1' > sudo /proc/sys/net/ipv4/ip_forward
sudo sysctl -p
```
#### 2. token
토큰이 만료된 후 새로운 노드를 조인할 토큰 생성

```
kubeadm token create
```

토큰 조회
```
kubeadm token list
```

discovery-token-ca-cert-hash 조회
```
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'
```

토큰 재생성
```bash
kubeadm token create --print-join-command
```

#### 3. 스케줄링 불가로 인한 pending

* taint로 인해 스케줄링 불가하므로, 제거
* 마스터 노드는 일반 pod를 막기 때문
```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

# k8s 삭제

```bash
# 쿠버네티스 초기화
sudo kubeadm reset -k
sudo systemctl stop kubelet

# 모든 iptables 규칙 초기화 (모든 방화벽 규칙 삭제)
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X
sudo iptables -t nat -X
sudo iptables -t mangle -X

sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

# 영구 반영
sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null

# 쿠버네티스 관련 파일 삭제
sudo rm -rf /var/lib/cni/
sudo rm -rf /var/lib/kubelet/*
sudo rm -rf /var/lib/etcd
sudo rm -rf /run/flannel
sudo rm -rf /etc/cni
sudo rm -rf /etc/kubernetes
sudo rm -rf ~/.kube

# 쿠버네티스 패키지 삭제
sudo apt-get purge -y kubeadm
sudo apt-get purge -y kubectl
sudo apt-get purge -y kubelet
sudo apt-get purge -y kubebernetes-cni
sudo apt-get autoremove -y

# 리부팅
sudo init 6
```