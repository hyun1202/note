# 인증서 백업
sudo cp -R /etc/kubernetes/pki /etc/kubernetes/pki.backup

# 기존 인증서 삭제
sudo rm /etc/kubernetes/pki/apiserver.crt
sudo rm /etc/kubernetes/pki/apiserver.key

# 적용
sudo kubeadm init phase certs apiserver --config=kubeadm-config.yaml

# kubelet 재시작
sudo systemctl restart kubelet

# API 서버 파드 재시작 대기 (1-2분)
kubectl get pods -n kube-system | grep apiserver

# 새 인증서의 SAN 확인
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep -A 10 "Subject Alternative Name"

# config 적용
sudo mkdir -p $HOME/.kube 
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config 
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 토큰 재 생성
sudo kubeadm token create --print-join-command