
### Termux ubuntu 설치
```sh
pkg update
pkg upgrade
pkg install openssh
sshd
whoami
apt install proot
apt install proot-distro
proot-distro install ubuntu
proot-distro login ubuntu
```

#### ubuntu jenkins 설치
```sh
apt install fontconfig openjdk-17-jre wget -y
wget -O /usr/share/keyrings/jenkins-keyring.asc \
 https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
 echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
 https://pkg.jenkins.io/debian-stable binary/ | tee \
 /etc/apt/sources.list.d/jenkins.list **>** /dev/null
apt-get update
apt-get install jenkins -y
```

### Termux jenkins 설치
```sh
pkg install fontconfig
pkg install openjdk-17                                                           
pkg install wget -y                                                             
wget https://get.jenkins.io/war/2.463/jenkins.war -O jenkins.war
nohup java -Djava.awt.headless=true -jar jenkins.war --httpPort=8080 &
```
