# kubelet 중지
sudo service kubelet stop

# 기존 클러스터 설정 초기화
sudo kubeadm reset -f

# 관련 파일들 정리
sudo rm -rf /etc/kubernetes/
sudo rm -rf /var/lib/kubelet/
sudo rm -rf /etc/cni/net.d/

# 기존 네트워크 인터페이스 정리
sudo ip link delete cni0 2>/dev/null || true
sudo ip link delete flannel.1 2>/dev/null || true

# iptables 규칙 정리
sudo iptables -F
sudo iptables -t nat -F

# 재기동
sudo reboot