
```java
@Bean  
public Advisor advisor2(LogTrace logTrace) {  
    // aspectJ pointcut 적용  
    AspectJExpressionPointcut pointcut = new AspectJExpressionPointcut();  
    pointcut.setExpression("execution(* hello.proxy.app..*(..)) && !execution(* hello.proxy.app..noLog(..))");  
  
    //advice  
    LogTraceAdvice advice = new LogTraceAdvice(logTrace);  
    return new DefaultPointcutAdvisor(pointcut, advice);  
}
```

# 포인트컷 지시자
Pointcut Designator

포인트컷을 편리하게 표현하기 위한 특별한 표현식

## 종류

1. execution: **메소드 실행** 조인 포인트를 매칭
2. within: 특정 타입 내의 조인 포인트를 매칭
3. args: 인자가 주어진 타입의 인스턴스인 조인 포인트
4. this: 스프링 빈 객체를 대상으로 하는 조인 포인트
5. target: Target객체를 대상으로 하는 조인 포인트
6. @target: 실행 객체의 **클래스에 주어진 타입의 애노테이션이 있는** 조인 포인트
7. @within: **주어진 애노테이션이 있는** 타입 내 조인 포인트
8. @annotation: **<U>메서드</U>가 주어진 애노테이션을 가지고 있는** 조인 포인트
10. @args: 전달된 실제 인수의 런타임 타입이 주어진 타입의 애노테이션을 갖는 조인 포인트
11. bean: 스프링 전용 포인트컷 지시자, 빈의 이름으로 포인트컷 지정

## 사용법

> <포인트컷 지시자>(<접근 제어자> <반환형><패키지>(<파라미터>))
### execution

```java
// 반환형, 접근제어자, 인자 타입 상관 없이 해당 패키지 하위에 있는 모든 메서드 지정
execution(* com.example.demo..*.*(..))
```

#### 패키지에서 `.` 와 `..`의 차이
`.`: 정확한 해당 위치의 패키지
`..`: 해당 위치의 패키지와 그 **하위 패키지도 포함**
#### 파라미터
`()`: 파라미터가 없어야한다.
`(*)`: 정확히 하나의 파라미터, 모든 타입 허용
`(*, *)`: 정확히 두 개의 파라미터, 모든 타입 허용
`(String, ..)`: String 타입으로 시작, 숫자와 무관하게 모든 파라미터, 모든 타입 허용
`(..)`: 숫자와 무관하게 모든 파라미터, 모든 타입 허용(파라미터가 없어도 됨)

### within
특정 **타입** 내의 조인 포인트에 대한 매칭 제한
execution의 타입 관련만 가져온 것과 같다.

```java
within(com.example.demo..*)
```

### args
인자가 주어진 타입의 인스턴스인 조인 포인트로 매칭

```java
args(String)
args(java.io.Serializable)
args(com.example.demo.member.Member)
```
#### execution과 args의 차이점
`execution`: 파라미터 타입이 정확하게 매칭, 클래스에 선언된 정보를 기반으로 판단 (정적)
`args`: 부모 타입 허용, 실제 넘어온 파라미터 객체 인스턴스를 보고 판단 (동적)

### @target, @within
타입(class)에 있는 애노테이션으로 AOP 적용 여부를 판단한다.

`@target`: 실행 객체의 클래스에 주어진 타입의 애노테이션이 있는 조인 포인트
	인스턴스의 모든 메서드를 조인 포인트로 적용
	-> **부모 클래스의 메서드까지** 어드바이스를 모두 적용
`@within`: 주어진 애노테이션이 있는 타입 내 조인 포인트
	해당 타입 내에 있는 메서드만 조인 포인트로 적용
	-> **자기 자신의 클래스에 정의된 메서드**에만 어드바이스를 적용

