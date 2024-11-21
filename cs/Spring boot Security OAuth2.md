# 커스텀 서비스가 호출이 되지 않는 이슈(Google)
네이버, 카카오 등 국내 서비스를 이용해서 OAuth2 연동은 문제 없이 잘 되었었는데
구글을 이용해서 로그인 하면 커스텀한 OAuth2Service를 타지 않는 것을 확인했다.

OAuth2AuthenticationFilter부터 쭉 디버깅해서 확인한 결과

![[Pasted image 20241121224406.png]]
scope에 `openid`라는 항목이 있으면 커스텀한 서비스를 호출하지 않는 것을 볼 수 있었다.
properties를 설정할 때 scope를 지정하지 않으면 자동으로 `openid`, `email`, `profile`로 초기값이 잡혀있는 것이었기에

```yml
google:  
  client-name: google  
  client-id: ${GOOGLE_CLIENT_ID}  
  client-secret: ${GOOGLE_CLIENT_SECRET}  
  client-authentication-method: client_secret_post  
  authorization-grant-type: authorization_code  
  redirect-uri: "{baseUrl}/oauth2/callback/{registrationId}"  
  # scope 추가
  scope:  
    - email  
    - profile
```

위와 같이 scope를 추가해주었고 정상적으로 서비스를 호출하는 것을 확인했다.