
# NAT 

NAT(Network Address Translation): IP 패킷 헤더의 출발지 또는 목적지IP를 변경

```bash
sudo iptables -t nat -I PREROUTING -i ens3 -d 10.0.0.238 -j DNAT --to-destination 10.8.0.6

sudo iptables -t nat -I POSTROUTING 1 -o tun0 -d 10.8.0.6 -j SNAT --to-source 10.0.0.238
 ```

`PREROUTING`: 들어오는 패킷의 목적지를 변경
`POSTROUTING`: 나가는 패킷의 출발지를 변경

-i: 들어오는 네트워크 인터페이스에 대해 적용
-o: 나가는 네트워크 인터페이스에 대해 적용
-d: 목적지로 들어온 IP
-s: 출발지로 들어온 IP
-p: 포트 지정
DNAT: 목적지 변경
SNAT: 출발지 변경

### 정책 조회
```bash
sudo iptables -t nat -L -v -n --line-numbers
```

### 정책 삭제

```bash
sudo iptables -t nat -D PREROUTING 1
```

### NAT 활성화

vi /etc/sysctl.conf

```bash
net.ipv4.ip_forward=1
```
  
#### 설정 바로 적용

```bash
sysctl -p /etc/sysctl.conf
```

### tshark를 이용한 패킷 캡처

```bash
sudo tshark -i any -Y 'tcp.port==5000' -t a --color
```

### tcpdump를 이용한 패킷 캡처

```bash
sudo tcpdump -i any port 5000 -vv -nn
```
