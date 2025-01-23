
## 트러블 슈팅
### 인증번호 관련 메일 전송 시 cid로 설정한 이미지가 안 나오는 이슈

```java
public void send(Mail mail) {  
    MimeMessage mimeMessage = javaMailSender.createMimeMessage();  
    try {  
        MimeMessageHelper mimeMessageHelper = new MimeMessageHelper(mimeMessage, true, "UTF-8");  
        mimeMessageHelper.addTo(mail.getTo());  
        mimeMessageHelper.setFrom(new InternetAddress(mail.getFrom(), mail.getSenderName()));  
        mimeMessageHelper.setSubject(mail.getSubject());  
         
        mimeMessageHelper.addInline("logo", new ClassPathResource("static/images/logo.png"));  
        String body = mail.convertToString(templateEngine);  
        mimeMessageHelper.setText(body, true); 
  
        javaMailSender.send(mimeMessage);  
    } catch (MessagingException | UnsupportedEncodingException e) {  
        throw new RuntimeException(e);  
    }  
}
```

위와 같이 설정이 되어있었는데 메일을 전송하니 계속 이미지를 찾지 못하는 현상이 발생했다.
게다가 네이버로 메일을 전송해보니 attach(0)이라는 첨부파일도 추가가 되길래 영문을 알 수 없었다.
그러다 먼저 body를 설정하는 것으로 순서를 변경해보았더니

```java
String body = mail.convertToString(templateEngine);  
mimeMessageHelper.setText(body, true); 
// 순서 변경
mimeMessageHelper.addInline("logo", new ClassPathResource("static/images/logo.png")); 
```

정상적으로 작동이 되는 것을 확인할 수 있었다.