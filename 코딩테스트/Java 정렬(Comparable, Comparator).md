
* 원시 데이터 비교는 java에서 제공하는 > < = 와 같은 비교연산자로 가능하다.
* 하지만, **객체들 간의 비교**는 비교연산자로 불가능하다.
* 객체들간의 비교 및 정렬을 위해 Comparable과 Comparator를 사용할 수 있다.
	* 인터페이스이므로 선언된 메소드를 반드시 구현해야한다.
	* Comparable: `compareTo(T o)`
	* Comparator: `compare(T o1, T o2)`

### Comparable
* `compareTo(T o)` 
* 자기 자신과 매개변수 객체를 비교한다.

```java
class Student implements Comparable<Student> {
 
	int age;			// 나이
	int classNumber;	// 학급
	
	Student(int age, int classNumber) {
		this.age = age;
		this.classNumber = classNumber;
	}
	
	@Override
	public int compareTo(Student o) {
    
		// 자기자신의 age가 o의 age보다 크다면 양수
		if(this.age > o.age) {
			return 1;
		}
		// 자기 자신의 age와 o의 age가 같다면 0
		else if(this.age == o.age) {
			return 0;
		}
		// 자기 자신의 age가 o의 age보다 작다면 음수
		else {
			return -1;
		}

		// 위의 것을 아래와 같이 축약할 수 있다.
		return this.age - o.age;
	}
}
```

자기 자신을 기준으로 삼아 대소관계를 파악해야한다.
=> 즉, "본인이 기준"이다.
### Comparator
* 두 매개변수 객체를 비교한다.


오름차순:
o1 -o2 ? 1 : -1

내림 차순:
o2 - o1

음수인 경우 첫 번째 매개변수가 더 작은 값으로 판단함.
양수인 경우 첫 번째 매개변수가 더 큰 값으로 판단함.