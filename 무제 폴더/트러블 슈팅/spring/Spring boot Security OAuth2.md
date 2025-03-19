
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

![이미지](/이미지/Pasted%20image%2020241121224406.png)
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

### 프론트에서 xhr을 이용하여 토큰 값을 가져오지 못하는 이슈
Security의 OAuth2를 이용해서 reponse body로 토큰 값을 설정하였으나
redirect를 이용한다면 더 이상 클라이언트쪽에서 제어할 방법이 없었기에 xhr을 이용해서 호출했더니 cors에러로 작동하지 않았다.

이는 각 로그인 페이지에서의 cors 에러이므로 개발자가 해결할 방법이 없어 여러 방안을 시도해보았다.
#### 1. 인증 완료 핸들러 이후 커스텀 컨트롤러로 리다이렉트
처음에는 간단하게 완료된 후에 내 컨트롤러로 리다이렉트 하고 callback.html 을 만들어 세션에 저장 후 프론트 페이지로 리다이렉트 시키려고 했다.

success handler, custom oauth2 controller
```java
public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {   

		... 토큰 생성 로직
        request.setAttribute("token", res);  
        // 내 컨트롤러로 리다이렉트
        RequestDispatcher dispatcher = request.getRequestDispatcher("/oauth2/callback");  
        dispatcher.forward(request, response);   
}

//// 내 컨트롤러
@RequestMapping("oauth2")  
@Controller  
public class OAuth2Controller {  
  
    @Operation(description = "소셜 로그인 이후 콜백")  
    @GetMapping("/callback")  
    public String callback(HttpServletRequest request, Model model) {  
        model.addAttribute("token", request.getAttribute("token"));  
        return "callback";  
    }
}
```

callback.html
```html
<!DOCTYPE html>  
<html>  
	<body>   
		<script>  
		    sessionStorage.setItem("token", "[[${token}]]");  
		    // 이후 다른 페이지로 이동  
		    window.location.href = "http://localhost:3000/callback";  
		</script>  
	</body>  
</html>
```

프론트 페이지에 값을 넘겨줄 방법이 없어 session으로 넘겨주려고 하는데
테스트 시 session이 비어있는 것을 확인했다.

세션은 각 도메인 별로 저장이 되므로 localhost:3000에는 저장이 안되고 당연히 꺼내쓸 수도 없었다.

그렇기에 이 방법은 사용할 수가 없었다.
### 2. 클라이언트로 리다이렉트 시 url에 토큰 정보 전송
url에 토큰을 전송하는 것은 보안적으로 문제가 있다고 생각이 되었기에 시도도 해보지 않았다..
### 3. 인증 토큰을 클라이언트에서 가져오자
인증 토큰을 클라이언트에서 가져와 xhr을 이용하여 서버로 인증 토큰을 전송하는 방법이 있겠다.
클라이언트에서 `client_id`를 알아야 한다는 점이 껄끄러웠고
인증 토큰을 받는 api를 새로 작성해야 했기에 선택하지 않았다.
### 4. 인증 완료 후 핸들러에서 클라이언트 주소로 리다이렉트 ✔️
최종적으로 이 방법을 선택했다.

생성한 토큰을 클라이언트에게 쿠키로 토큰을 응답한다.
토큰 응답 시 클라이언트에서 받을 수 있게 반드시 path를 `"/"`로 설정해주어야 한다.
클라이언트가 토큰 값을 가져와야 하므로 HttpOnly 속성은 설정하지 않는다
	해당 속성을 설정하게 되면 `document.cookie`로 값을 가져올 수가 없다.

```java
@Override  
public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {  

	...토큰 생성 로직

	// accessToken과 refreshToken의 쿠키를 생성한다.
    Cookie accessToken = new Cookie("accessToken", tokenDto.accessToken());  
    Cookie refreshToken = new Cookie("refreshToken", tokenDto.refreshToken());  
	// 클라이언트에서 쿠키를 받을 수 있게 설정한다.
    accessToken.setPath("/");  
    refreshToken.setPath("/");  
    // 클라이언트가 토큰 값을 가져와야 하므로 httpOnly는 설정하지 않는다.
  
    response.addCookie(accessToken);  
    response.addCookie(refreshToken);  
  
    String clientHost = propertyConfig.getClientHost();  
    response.sendRedirect(clientHost);  
}
```

위와 같이 설정하고 테스트한 결과 정상적으로 쿠키를 응답받고 사용할 수 있는 것을 확인했다.



### 로그인 완료에도 에러가 나는 이슈
