리눅스 내 공인 IP 알아보기
```bash
curl ifconfig.me
```

## swap

### swap file 확인
```bash
free
```

```bash
sudo swapon -s
```
### swap file 생성
```bash
sudo fallocate -l 2G /swapfile
```

### 권한 수정
```bash
sudo chmod 600 /swapfile
```

### 활성화
```bash
sudo mkswap /swapfile
sudo swapon /swapfile
```

### 영구 반영
```bash
sudo vim /etc/fstab #파일 편집 
```

```bash
### 아래 내용 추가 후 저장 ### 
/swapfile swap swap defaults 0 0
```



## Tmux 사용 방법

1. **tmux 설치** `tmux`가 설치되지 않았다면, 먼저 설치해야 합니다. 예를 들어, 우분투에서는 다음 명령어로 설치할 수 있습니다:

    `sudo apt-get install tmux`

2. **tmux 세션 시작** `tmux`를 실행하려면 터미널에서 다음 명령어를 입력하세요:
    
    `tmux`
    
    또는 세션 이름을 지정하고 싶다면:
    
    `tmux new-session -s mysession`
    
3. **QEMU 명령어 실행** `tmux` 세션 안에서 QEMU 명령어를 실행할 수 있습니다. 예를 들어:
    
    `qemu-system-x86_64 -machine q35 -m 2048 -smp cpus=6 -cpu qemu64 \     -drive if=pflash,format=raw,read-only=on,file=$PREFIX/share/qemu/edk2-x86_64-code.fd \     -netdev user,id=n1,hostfwd=tcp::2222-:22 \     -device virtio-net,netdev=n1 \     -nographic alpine.img`
    
4. **세션 분리** `tmux` 세션에서 실행 중인 프로세스를 백그라운드로 보내고 싶다면, **`Ctrl + B`**를 누르고 그 후에 **`D`**를 누르면 세션이 분리됩니다. 이 상태에서 터미널을 종료하거나 다른 작업을 할 수 있습니다.
    
5. **세션 다시 연결** 분리된 `tmux` 세션에 다시 연결하려면, 다음 명령어를 사용합니다:
    
    `tmux attach-session -t mysession`
    
    만약 세션 이름을 지정하지 않았다면, 그냥 `tmux attach`를 입력하면 됩니다.
    
6. **tmux 세션 목록 보기** 현재 실행 중인 `tmux` 세션 목록을 보려면:
    
    `tmux ls`
    
7. **세션 종료** `tmux` 세션을 종료하려면, 세션 내에서 `exit` 명령어를 사용하거나 `tmux` 창을 종료하면 됩니다. 모든 작업이 완료되면 `Ctrl + B`, 그 후 **`:`**를 누르고 `kill-session`을 입력하여 세션을 종료할 수도 있습니다.
    

### 추가적인 `tmux` 명령어

- **새 창 만들기**: `Ctrl + B` 후 `C` → 새 창에서 작업 시작
    
- **창 사이 이동**: `Ctrl + B` 후 방향키 (위/아래/좌/우)로 창 간 이동
    
- **창 닫기**: `exit` 또는 `Ctrl + D` 입력
    

### 예시

1. `tmux` 세션을 시작합니다:
    
    `tmux new-session -s qemu_session`
    
2. `qemu` 명령어를 실행합니다:
    
    `qemu-system-x86_64 -machine q35 -m 2048 -smp cpus=6 -cpu qemu64 \     -drive if=pflash,format=raw,read-only=on,file=$PREFIX/share/qemu/edk2-x86_64-code.fd \     -netdev user,id=n1,hostfwd=tcp::2222-:22 \     -device virtio-net,netdev=n1 \     -nographic alpine.img`
    
3. **`Ctrl + B`, `D`**를 눌러 세션을 분리하고, 다른 작업을 할 수 있습니다.
    
4. 나중에 **`tmux attach-session -t qemu_session`** 명령어로 다시 접속합니다.
    