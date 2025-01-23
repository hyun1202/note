
### 도커 빌드 오류 - 파일을 찾을 수 없음

파일을 찾을 수 없다는 오류와 함께 도커 빌드가 계속 되지 않았다.
```bash
#9 ERROR: lstat /build/libs: no such file or directory

[214](https://github.com/1-word/app/actions/runs/12367245505/job/34515210758#step:13:219)------

[215](https://github.com/1-word/app/actions/runs/12367245505/job/34515210758#step:13:220) > [linux/arm64 3/3] COPY build/libs/*.jar ./app.jar:

[216](https://github.com/1-word/app/actions/runs/12367245505/job/34515210758#step:13:221)------

[217](https://github.com/1-word/app/actions/runs/12367245505/job/34515210758#step:13:222)ERROR: failed to solve: lstat /build/libs: no such file or directory

[218](https://github.com/1-word/app/actions/runs/12367245505/job/34515210758#step:13:223)Error: buildx failed with: ERROR: failed to solve: lstat /build/libs: no such file or directory
```

파일이 해당 위치에 없나? 확인을 해봤더니 아래와 같이 아주 잘 있는 것을 확인했다..

```bash
./build/libs:

[845](https://github.com/1-word/app/actions/runs/12367245505/job/34515210758#step:9:846)total 76528

[846](https://github.com/1-word/app/actions/runs/12367245505/job/34515210758#step:9:847)drwxr-xr-x 2 runner docker 4096 Dec 17 05:56 .

[847](https://github.com/1-word/app/actions/runs/12367245505/job/34515210758#step:9:848)drwxr-xr-x 7 runner docker 4096 Dec 17 05:56 ..

[848](https://github.com/1-word/app/actions/runs/12367245505/job/34515210758#step:9:849)-rw-r--r-- 1 runner docker 78354809 Dec 17 05:56 WordApp-0.0.1-SNAPSHOT.jar
```

컨테이너 안에서 가져오지 못하는 건가? 싶어서 context를 지정해주었더니 

```yml
- name: Build and push  
  uses: docker/build-push-action@v4  
  with:  
    context: .  # 현재 위치를 지정
    push: true  
    tags: |  
      ${{ secrets.DOCKERHUB_USERNAME }}/word:app  
      ${{ secrets.DOCKERHUB_USERNAME }}/word:app-${{ env.CLEANED_TAG }}  
    platforms: |  
      linux/amd64  
      linux/arm64
```

빌드가 완료된 것을 확인할 수 있었다.