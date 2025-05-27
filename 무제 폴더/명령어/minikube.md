# minikube 설치(MAC)

## 1. homebrew로 minikube 설치
```bash
brew install minikube
```

## 2. 실행
```bash
minikube start --driver=docker
```

## 3. homebrew로 kubectl 설치
```bash
$ brew install kubectl
```

## 4. 컨테이너 접속을 위한 포트포워딩
맥에서  아래와 같이 service로 Node Port를 확인하고 
```bash
$ kubectl get all
NAME                                    READY   STATUS    RESTARTS   AGE
pod/nginx-deployment-1   1/1     Running   0          6m8s
pod/nginx-deployment-2   1/1     Running   0          6m7s
pod/nginx-deployment-3   1/1     Running   0          6m7s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP          34m
service/my-nginx     NodePort    10.106.173.43   <none>        8080:31612/TCP   5m9s
```
`minikube ip:31612`로 접속했음에도 접속할 수가 없다.
	ip는 `minikube ip`로 알 수 있다.

mac에서 docker driver를 사용할 때의 한계점이다.

그러므로 port-forwading을 해주어 (임시)해결
```bash
kubectl port-forward service/my-nginx 4000:8080
```

이후 `localhost:4000` 으로 접속

또는 접근이 가능한 임시 url을 얻는다.
```bash
minikube service my-nginx --url
```