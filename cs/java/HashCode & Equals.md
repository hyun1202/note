# hashCode()
해시 코드란 각 **객체의 주소 값을 이용**해서 해싱 기법을 통해 해시 코드를 만든 후 반환하는 메서드이다.
서로 다른 두 객체는 같은 해시 코드를 가질 수 없지만 해시 충돌로 인해 그런 일이 발생할 수도 있다.
=> 이를 위해 Equals 메서드를 사용한다.

자바에서 객체 비교 시 hashCode 메서드를 오버라이딩한 것을 많이 봤을 것이다.
가장 많이 사용하는 String 클래스도 hashCode가 정의가 되어있다.

```java
public int hashCode() {  
    if (h == 0 && !hashIsZero) {  
        h = isLatin1() ? StringLatin1.hashCode(value)  
                       : StringUTF16.hashCode(value);  
        if (h == 0) {  
            hashIsZero = true;  
        } else {  
            hash = h;  
        }  
    }  
    return h;  
}
```

예제: 이름이 같을 경우 객체를 동일하게 판단하고 싶은 경우

```java
public class Person {
	String name,
	int age;

	@Override
	public int hashCode() {
		return Objects.hash(name);
	}
}
```
# equals()
객체의 주소를 이용하여 비교 후 반환하는 메서드이다.

비교할 대상이 객체일 경우 객체의 주소를 이용하여 비교하는데, **객체가 다르지만 값은 같을 경우 동일한 것으로 판단하고 싶을 때 오버라이딩하여 사용**한다.

아래는 String 클래스의 equals 메서드이다.

```java
public boolean equals(Object anObject) {  
    if (this == anObject) {  
        return true;  
    }  
    return (anObject instanceof String aString)  
            && (!COMPACT_STRINGS || this.coder == aString.coder)  
            && StringLatin1.equals(value, aString.value);  
}
```

예제: 이름이 같을 경우 객체를 동일하게 판단하고 싶은 경우

```java
public class Person {
	String name,
	int age;

	@Override
	public int hashCode() {
		return Objects.hash(name);
	}

	@Override
	public boolean equals(Object o) {
		// 객체 주소값 비교
		if (this == o) reutnr true;
		// 해당 객체가 아닐 경우 false
		if (o == null) || getClass() != o.getClass()) return false;
		// 객체일 경우 name 비교
		Person p = (Person) o;
		return Objects.equals(name, p.name);
	}
}
```

# 주의사항
## 1. equals와 hashCode를 같이 재정의 하는 이유

Collecetion 객체에서는 객체가 논리적으로 같은지 비교할 때
`hashCode() -> equals()`의 순서를 거친다.

즉, equals만 오버라이딩하고 hashCode를 오버라이딩 하지 않은 경우 개발자는 동일한 객체라고 판단했음에도 결과는 의도하지 않은 결과가 나올 수 있다.