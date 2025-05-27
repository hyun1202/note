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
```bash
# 패키지 다운로드
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# 공개 키 다운로드                                                       
curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# k8s 설치
sudo apt-get install -y kubelet kubeadm kubectl
```
## 5. kubectl 설정
root 계정이 아닌 다른 계정에서도 kubectl 명령어 사용 가능하도록 설정.
```bash
sudo mkdir -p $HOME/.kube 
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config 
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
### 5.1 CNI(Container Network Interface) 설정
Flannel
```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```
Calico
```bash
curl https://docs.projectcalico.org/manifests/calico.yaml -O --insecure 
kubectl apply -f https://calico-v3-25.netlify.app/archive/v3.25/manifests/calico.yaml

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
sudo kubectl get node  
```
or
```bash
sudo kubectl get nodes -o wide
```
### 부록
#### 1. `kubeadm init` 에러
`/proc/sys/net/bridge/bridge-nf-call-iptables does not exist`와 같은 에러일 경우 
```bash
cat <  /etc/sysctl.d/k8s.conf                                        
net.bridge.bridge-nf-call-ip6tables = 1                              
net.bridge.bridge-nf-call-iptables = 1                               
EOF
```

안될 시 아래 명령어 시도
```bash
sudo modprobe br_netfilter
echo 1 > sudo /proc/sys/net/bridge/bridge-nf-call-iptables
```

#### 2. token
토큰이 만료된 후 새로운 노드를 조인할 토큰 생성

```
$ kubeadm token create
```

토큰 조회
```
$ kubeadm token list
```

discovery-token-ca-cert-hash 조회
```
$ openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'
```
