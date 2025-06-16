#!/bin/sh
# kubelet-downgrade-setup.sh

# 타겟 버전 설정
K8S_VERSION="v1.30.13"

echo "1. Stopping existing kubelet service..."
# 기존 kubelet 서비스 중지
sudo rc-service kubelet stop 2>/dev/null || true
sudo pkill -f kubelet 2>/dev/null || true

echo "2. Removing old kubelet binary..."
# 기존 kubelet 제거
sudo rm -f /usr/bin/kubelet

echo "3. Downloading kubelet ${K8S_VERSION}..."
curl -L "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubelet" -o kubelet

# 설치
sudo install -o root -g root -m 0755 kubelet /usr/bin/kubelet
rm kubelet

echo "4. Creating kubelet service file..."
# kubelet 서비스 파일 생성
sudo tee /etc/init.d/kubelet <<'EOF'
#!/sbin/openrc-run

name="kubelet"
description="Kubernetes Node Agent"
command="/usr/bin/kubelet"
command_args="--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --cgroup-driver=cgroupfs --config=/var/lib/kubelet/config.yaml --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=registry.k8s.io/pause:3.9"
command_background="yes"
pidfile="/run/kubelet.pid"
start_stop_daemon_args="--make-pidfile"

depend() {
    need containerd
    after containerd
}

start_pre() {
    # 필요한 디렉토리 생성
    mkdir -p /var/lib/kubelet
    mkdir -p /etc/kubernetes
    
    # 스왑 비활성화
    swapoff -a 2>/dev/null || true
    
    # DNS 설정 (알파인용)
    mkdir -p /run/systemd/resolve
    ln -sf /etc/resolv.conf /run/systemd/resolve/resolv.conf 2>/dev/null || true
    
    # CNI 디렉토리 확인
    mkdir -p /opt/cni/bin
    mkdir -p /etc/cni/net.d
}

stop_post() {
    # PID 파일 정리
    rm -f /run/kubelet.pid 2>/dev/null || true
}
EOF

echo "5. Setting up service permissions..."
# 서비스 파일 권한 설정
sudo chmod +x /etc/init.d/kubelet

echo "6. Registering kubelet service..."
# 서비스 등록
sudo rc-update add kubelet default

echo "7. Ensuring containerd is also registered..."
# containerd도 자동 시작 설정
sudo rc-update add containerd default 2>/dev/null || true

echo "8. Resetting kubelet configuration..."
# 기존 클러스터 설정 초기화
sudo kubeadm reset -f 2>/dev/null || true
sudo rm -rf /var/lib/kubelet/ /etc/kubernetes/ 2>/dev/null || true

# 디렉토리 재생성
sudo mkdir -p /var/lib/kubelet
sudo mkdir -p /etc/kubernetes

echo "9. Setting up DNS configuration..."
# DNS 설정
sudo mkdir -p /run/systemd/resolve
sudo ln -sf /etc/resolv.conf /run/systemd/resolve/resolv.conf

echo "10. Disabling swap..."
# 스왑 비활성화
sudo swapoff -a

# 영구 스왑 비활성화
sudo sed -i '/ swap / s/^/#/' /etc/fstab 2>/dev/null || true

# glibc 호환성 라이브러리 설치(x86)
sudo apk add gcompat

echo "======================================"
echo "Setup completed successfully!"
echo "======================================"

echo "Installed kubelet version:"
kubelet --version

echo ""
echo "Service status:"
sudo rc-service kubelet status

echo ""
echo "Next steps:"
echo "1. Get join command from master: sudo kubeadm token create --print-join-command"
echo "2. Run the join command on this worker node"
echo "3. Start kubelet service: sudo rc-service kubelet start"

echo ""
echo "Service management commands:"
echo "- Start:   sudo rc-service kubelet start"
echo "- Stop:    sudo rc-service kubelet stop"
echo "- Restart: sudo rc-service kubelet restart"
echo "- Status:  sudo rc-service kubelet status"