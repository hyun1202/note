
# Security OAuth2 구현

1. oauth2 디펜던시 설정
```java
implementation 'org.springframework.boot:spring-boot-starter-oauth2-client'
```
2. registration 설정
	1. properties 설정
```yaml
spring:  
  security:  
	oauth2:  
	  client:  
		registration:  
		  kakao:  
			client-name: kakao  
			client-id: ${KAKAO_CLIENT_ID}  
			client-secret: ${KAKAO_CLIENT_SECRET}  
			client-authentication-method: client_secret_post  
			authorization-grant-type: authorization_code  
			redirect-uri: "{baseUrl}/oauth2/callback/{registrationId}"  
			scope:  
			  - profile_nickname  
			  - profile_image  
			  - account_email
```
3. security config 설정
	1. `redirectionEndpoint`를 이용해서 redirect uri를 설정
	2. `userInfoEndpoint`를 이용해서 OAuth2 관련 데이터를 받을 수 있도록 `OAuth2UserService`를 구현한 커스텀 서비스를 생성
	3. 검증 완료한 후 처리를 담당하는 `successHandler`설정
```java
http.oauth2Login(httpSecurityOAuth2LoginConfigurer -> httpSecurityOAuth2LoginConfigurer  
        .redirectionEndpoint(redirectionEndpointConfig -> redirectionEndpointConfig  
                .baseUri("/oauth2/callback/*"))  
        .successHandler(commonLoginSuccessHandler())  
        .userInfoEndpoint(userInfoEndpointConfig -> userInfoEndpointConfig  
                .userService(CustomOAuth2UserService))  
);
```
4. CustomOAuth2UserService
	1. OAuth2 정보를 가져와 해당하는 서비스의 인스턴스를 생성
	2. 가져온 userInfo 정보로 서비스에 회원가입 및 업데이트 처리
```java
@Service  
@RequiredArgsConstructor  
public class CustomOAuth2UserService implements OAuth2UserService<OAuth2UserRequest, OAuth2User> {  
    private final UserService userService;  
  
    @Override  
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {  
        OAuth2UserService<OAuth2UserRequest, OAuth2User> service = new DefaultOAuth2UserService();  
        // OAuth2 정보를 가져온다.  
        OAuth2User oAuth2User = service.loadUser(userRequest);  
        Map<String, Object> attributes = oAuth2User.getAttributes();  
  
        String serviceName = userRequest.getClientRegistration().getClientName();  
        OAuth2ServiceInfo oAuth2ServiceInfo = getOAuth2UserInfo(serviceName);  
        OAuth2UserInfo oAuth2UserInfo = oAuth2ServiceInfo.getUserInfo(attributes);  
  
        UserDto userDto = userService.saveOrUpdate(oAuth2UserInfo);  
        List<String> authorities = userDto.authorities();  
  
        User user = User.builder()  
                .userId(userDto.userId())  
                .email(userDto.email())  
                .authorities(getAuthorities(authorities))  
                .build();  
  
        return new UserDetailsImpl(user, attributes);  
    }  
  
    private OAuth2ServiceInfo getOAuth2UserInfo(String serviceName) {  
        return switch (serviceName) {  
            case "kakao" -> new KaKaoServiceInfo();  
            case "naver" -> new NaverServiceInfo();  
            case "google" -> new GoogleServiceInfo();  
            default -> throw new IllegalStateException("Unexpected value: " + serviceName);  
        };  
    }    
}
```
5. CommonLoginSuccessHandler
	1. 인증 완료한 데이터를 가져와 그 기반으로 토큰 생성
	2. 생성한 리프레시 토큰 저장 및 json 타입으로 토큰 응답
```java
@RequiredArgsConstructor  
public class CommonLoginSuccessHandler implements AuthenticationSuccessHandler {  
    private final TokenProvider tokenProvider;  
    private final RefreshTokenService refreshTokenService;  
    @Override  
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {  
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();  
        // 토큰 생성  
        TokenDto tokenDto = tokenProvider.createTokenDto(userDetails.getUsername(), userDetails.getAuthorityList());  
        refreshTokenService.saveOrUpdateToken(userDetails.getUserId(), tokenDto.refreshToken());  
  
        ObjectMapper mapper = new ObjectMapper();  
        String res = mapper.writeValueAsString(tokenDto);  
  
        response.setContentType("application/json; charset=UTF-8");  
        response.getWriter().write(res);  
    }  
}
```
## 트러블 슈팅
### 커스텀 서비스가 호출이 되지 않는 이슈(Google)
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