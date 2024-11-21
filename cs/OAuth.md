# OAuth 1.0

`Resource Owner`: OAuth를 사용하는 <U>유저</U>에 해당
`Client` : Resource Owner에 접근해 Resource를 활용하려 하는 <U>애플리케이션</U>
`Resource Server(OAuth Server)`: Resource Owner와 인증을 통해 상호작용, Client에게 <U>인가</U>하는 역할

## 방식
OAuth Server가 인증과 리소스 관리를 전부 관리

Owner가 소셜 로그인 시도 -> OAuth Client가 Resource Server에게 인가를 받고 Owner에게 해당 사이트의 아이디, 비밀번호 입력등과 같은 인증 작업을 수행할 수 있는 사이트로 리다이렉트

OAuth Server는 받은 토큰 값을 Client에게 넘겨주고 토큰 값으로 사용자의 리소스에 접근

## 문제점
1. `Scope` 기능이 없어 토큰만 있으면 사용자의 모든 리소스에 접근할 수 있다.
	사진만 사용하는 애플리케이션임에도 동영상, 문서도 접근이 가능하다.
2. client 복잡성
	보안을 위해 많은 파라미터들이 필요하다.

# OAuth 2.0

1. Scop 기능 추가
2. Bearer Token과 TLS를 사용하여 보안 문제 해결
3. Auth Server와 Resource Server 분리