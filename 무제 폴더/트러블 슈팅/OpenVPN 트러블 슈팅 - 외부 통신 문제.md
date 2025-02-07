
## 서버 구성:

![이미지](/이미지/Pasted%20image%2020250120101552.png)

* 클라이언트 -> 리버스 프록시(외부) -> 앱(로컬) -> jenkins(사설)
* openvpn을 이용하여 10.8.0.6으로 집 네트워크와 통신
* 리버스 프록시 서버에는 앱 서버가 올라가 있다.
* 앱 서버는 **집 네트워크의 jenkins와 통신**

## 문제:
VPN을 킨 상태에서 내부로는 통신이 되나 **외부로는 통신이 되지 않는** 문제가 발생

### 외부
외부에서 curl을 이용하여 :9090으로 통신 시도했으나 실패, 
reverse proxy인 nginx의 로그로 **접속이 되지 않은 것을 확인했다.**

### 내부(VPN)
home network로 연결된 **pc1과 proxy와의 통신은 문제가 없었다.**
## 원인 분석
### 1. tcpdump, tshark를 이용하여 tcp 패킷 분석
* 서버: SYN가 들어온 후, 서버에서 정상적으로 SYN+ACK 패킷을 보내는 것을 확인.
![이미지](/이미지/Pasted%20image%2020250120103436.png)

* 클라이언트: SYN 이후 SNY+ACK 응답이 없음
![이미지](/이미지/Pasted%20image%2020250120103540.png)

-> 서버의 :5000까지는 통신이 되어 SNY+ACK 패킷을 보냈으나, 이후로 클라이언트에게 패킷이 도착하지 못함

즉, 10.0.0.238 이후의 통신에 문제가 있음을 의심

### 2. 라우팅 테이블 확인

```
0.0.0.0/1 via 10.8.0.5 dev tun0 # 이 부분과
default via 10.8.0.5 dev tun0 # 이 부분이 수상하다.
default via 10.0.0.1 dev ens3 proto dhcp src 10.0.0.238 metric 100 
10.0.0.0/24 dev ens3 proto kernel scope link src 10.0.0.238 metric 100           
10.0.0.1 dev ens3 proto dhcp scope link src 10.0.0.238 metric 100                
10.8.0.0/24 via 10.8.0.5 dev tun0                                                
10.8.0.5 dev tun0 proto kernel scope link src 10.8.0.6                           
128.0.0.0/1 via 10.8.0.5 dev tun0                                                
169.254.0.0/16 dev ens3 scope link                                               
169.254.0.0/16 dev ens3 proto dhcp scope link src 10.0.0.238 metric 100          
169.254.169.254 via 10.0.0.1 dev ens3 proto dhcp src 10.0.0.238 metric 100       
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown        
192.168.1.0/24 via 10.8.0.5 dev tun0                                             
220.-.-.- via 10.0.0.1 dev ens3
```

1, 2번 부분이 수상하다.. 모든 요청을 VPN으로 받는 것 같다.

### 3.  내 서버의 외부 IP 확인

`curl ifconfig.me` 명령어를 이용하여 내 서버의 외부 ip 확인
![이미지](/이미지/Pasted%20image%2020250120104003.png)

내 리버스 프록시 서버는 157.~.~.~ 인데 **외부 ip가 홈 네트워크 외부 ip로 변경된 것을 확인**

-> 즉, 리버스 프록시 서버로 접속을 하면 **외부, 내부 상관 없이 무조건 VPN을 타도록 되어있었다.**


## 해결
### openvpn config 수정
route-nopull 을 추가하고 직접 route 추가
`route-nopull`: 현재까지의 라우팅을 모두 무시

```
route-nopull 
route 10.8.0.0 255.255.0.0                                                       
route 192.168.1.0 255.255.255.0
```

이후 정상적으로 내부와 외부에서 정상적인 통신이 되었다.


## 삽질 기록
### 1. 내, 외부 서버와 모두 통신이 안됨
iptables를 이용해서 해당 포트를 허용해줬더니 통신이 되었다.

```bash
sudo iptables -I INPUT -p tcp --dport 5000 -j ACCEPT
```

### 2. openvpn config 수정 이후 외부만 통신이 됨
route-nopull에 라우팅을 tun0 아래와 같이 인터페이스만 하고 있었기에

```
route-nopull 
route 10.8.0.0 255.255.0.0 
```

내 내부 ip인 192.168~을 추가해 주었다.

