## 1. consoleAppender
- 콘솔에 로그 출력
- 기본적으로 ANSI 색상을 사용하여 로그 레벨에 따라 색상이 달라짐
```xml
<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">  
    <encoder>  
        <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} %highlight(%-5level) %magenta(${PID:- }) --- [%15.15thread] %cyan(%-40.40logger{39}) : %msg%n</pattern>  
    </encoder>  
</appender>
```
- encoder: 로그 형식 지정
- target: 로그를 출력할 대상

## 2. FileAppender
- 지정한 파일에 로그 기록
```xml
<appender name="INFO_LOG" class="ch.qos.logback.core.FileAppender">  
    <file>${LOGS_PATH}/info.log</file>
    <append>true</append> 
    <encoder>  
        <pattern>${LOG_PATTERN}</pattern>  
    </encoder>  
</appender>
```

## 3. RollingFileAppender
- 로그 파일을 자동으로 롤링(분할)하여 관리
```xml
<!-- Rolling File Appender 공통 설정 -->  
<appender name="INFO_LOG" class="ch.qos.logback.core.rolling.RollingFileAppender">  
    <file>${PATH}/info.log</file>  
    <filter class="ch.qos.logback.classic.filter.LevelFilter">  
        <level>INFO</level>  
        <onMatch>ACCEPT</onMatch>  
        <onMismatch>DENY</onMismatch>  
    </filter>  
    <encoder>  
        <pattern>${LOG_PATTERN}</pattern>  
    </encoder>  
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">  
        <fileNamePattern>${PATH}/info.%d{yyyy-MM-dd}.%i.log.gz</fileNamePattern>  
        <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">  
            <maxFileSize>100MB</maxFileSize>  
        </timeBasedFileNamingAndTriggeringPolicy>  
        <maxHistory>30</maxHistory>  
    </rollingPolicy>  
</appender>
```

## 4. AsyncAppender
- 비동기적으로 로그 기록
```xml
<appender name="ASNYC" class="ch.qos.logback.classic.AsyncAppender">
  <appender-ref ref="FILE"/>
  <queueSize>512</queueSize>
  <discardingThreshold>0</discardingThreshold>
</appender>
```
- queueSize: 비동기 큐 크기
- discardingThreshold: 큐가 가득찰 때 버릴 로그 수준

## 5. SyslogAppender
- 시스템 로그(syslog)로 로그 전송
```xml
<appender name="SYSLOG" class="ch.qos.logback.classic.net.SyslogAppender">
  <syslogHost>localhost</syslogHost>
  <port>514</port>
  <facility>USER</facility>
  <suffixPattern>%logger{36} - %msg%n</suffixPattern>
</appender>
```
- syslogHost: syslog 서버 주소
- port: syslog 포트 (기본값 514)
- facility: 로그 출처 (USER, LOCAL0 등) 

## 6. SocketAppender
- 소켓을 통해 로그를 원격 서버로 전송
```xml
<appender name="SOCKET" class="ch.qos.logback.classic.net.SocketAppender">
  <remoteHost>127.0.0.1</remoteHost>
  <port>5000</port>
  <reconnectionDelay>10000</reconnectionDelay>
</appender>
```
- remoteHost: 대상 서버 주소
- port: 대상 포트
- reconnectionDelay: 재연결 대기 시간

## 7. SMTPAppender
- 이메일을 통해 로그 전송
```xml
<appender name="EMAIL" class="ch.qos.logback.classic.net.SMTPAppender">
  <smtpHost>smtp.example.com</smtpHost>
  <to>admin@example.com</to>
  <from>no-replay@example.com</from>
  <subject>Error Logs</subject>
  <encoder>
    <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} %highlight(%-5level) %magenta(${PID:- }) --- [%15.15thread] %cyan(%-40.40logger{39}) : %msg%n
    </pattern>
  </encoder>
</appender>
```
- smtpHost: smtp 서버 주소
- to/from: 수신자/발신자 이메일
- subject: 이메일 제목

## 8. DBAppender
- 데이터베이스에 로그 기록
```xml
<appender name="DB" class="ch.qos.logback.classic.db.DBAppender">
  <connectionSource class="ch.qos.logback.core.db.DriverManagerConnectionSource">
    <driverClass>org.h2.Driver</driverClass>
    <url>jdbc:h2:mem:testdb</url>
    <user>sa</user>
    <password>password</password>
 </connectionSource>
</appender>
```

## 9. CustomAppender
- 사용자 정의 Appender를 만들어 요구사항에 맞게 로그 처리
```xml
<appender name="CUSTOM" class="com.example.CustomAppender">
	<encoder>  
        <pattern>${LOG_PATTERN}</pattern>  
    </encoder>  
</appender>
```