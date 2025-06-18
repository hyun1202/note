# Optional
- 존재할 수도 있고 존재하지 않을 수도 있는 값을 감싸는 클래스
- 런타임 `NullPointerException`을 사전에 방지하기 위해 도입

Optional**의** **값을 확인하거나, 획득하는 메서드**
1. `isPresent()` , `isEmpty()`
	값이 있으면 `true`
	값이 없으면 `false` 를 반환. 간단 확인용.
	`isEmpty()` : 자바 11 이상에서 사용 가능, 값이 비어있으면 `true` , 값이 있으면 `false` 를 반환
2. `get()`
	값이 있는 경우 그 값을 반환
	값이 없으면 `NoSuchElementException` 발생.
	직접 사용 시 주의해야 하며, 가급적이면 `orElse` , `orElseXxx` 계열 메서드를 사용하는 것이 안전.
3. `orElse(T other)`
	값이 있으면 그 값을 반환
	값이 없으면 `other` 를 반환.
4. `orElseGet(Supplier<? extends T> supplier)`
	값이 있으면 그 값을 반환
	값이 없으면 `supplier` 호출하여 생성된 값을 반환.
5. `orElseThrow(...)`
	값이 있으면 그 값을 반환
	값이 없으면 지정한 예외를 던짐.
6. `or(Supplier<? extends Optional<? extends T>> supplier)`
	값이 있으면 해당 값의 `Optional` 을 그대로 반환
	값이 없으면 `supplier` 가 제공하는 다른 `Optional` 반환
	값 대신 `Optional` 을 반환한다는 특징

**Optional 값 처리 메서드**

1. `ifPresent(Consumer<? super T> action)`
	값이 존재하면 action 실행
	값이 없으면 아무것도 안 함
2. `ifPresentOrElse(Consumer<? super T> action, Runnable emptyAction)`
	값이 존재하면 action 실행
	값이 없으면 emptyAction 실행
3. `map(Function<? super T, ? extends U> mapper)`
	값이 있으면 `mapper` 를 적용한 결과`(Optional<U>)` 반환
	값이 없으면 `Optional.empty()` 반환
4. `flatMap(Function<? super T, ? extends Optional<? extends U>> mapper)`
	map과 유사하지만, `Optional` 을 반환할 때 중첩되지 않고 평탄화(flat)해서 반환
5. `filter(Predicate<? super T> predicate)`
	값이 있고 조건을 만족하면 그대로 반환,
	조건 불만족이거나 비어있으면 `Optional.empty()` 반환
6. `stream()`
	값이 있으면 단일 요소를 담은 `Stream<T>` 반환
	값이 없으면 빈 스트림 반환

## 즉시 평가와 지연 평가
### 즉시 평가
- 값을 바로 생성하거나 계산
- `Optional.orElse(T)`: 값이 있어도 값을 생성하고 버린다.
### 지연 평가
- 값이 실제로 필요할 때까지 계산을 미루는 것
- `Optional.orElseGet(Supplier<? super T>)`: 값이 있으면 실행하지 않는다. 

## 모범 사례
1. 반환 타입으로만 사용하고, 필드에는 가급적 사용X'
	값이 없음을 명시하기 위해 사용하는 것이 `Optional`인데, **필드가 null이면 혼란 가중**
	만약 `Optional`로 값을 받고 싶다면 반환시점에 `Optional`로 감싸준다.
2. 매개변수로 사용X
	자바 공식 문서에 **메서드의 반환값으로 사용하기를 권장**하며, 매개변수로 사용하지 말라고 명시
	오버로드된 메서드를 만들거나, 명시적으로 null 허용 여부를 문서화
3. 컬렉션이나 배열 타입을 `Optional`로 감싸지 않기
	**컬렉션은 비어있는 상태(empty)를 표현**할 수 있다.
	따라서 다시 감싸면 empty()와 빈 리스트가 이중 표현이 된다.
4. `isPresent()`와 `get()`조합을 직접 사용하지 않기
	`if (opt.isPresent()) { opt.get() ...} else {...}` 는 사실상 `null`체크와 다를 바 없다
	`orElse`, `orElseGet`, `orElseThrow`, `ifPresentOrElse`, `map`, `filter`등 메서드를 사용하면 간결하고 안전하게 처리할 수 있다.
5. `orElseGet()` vs `orElse()` 차이를 분명히 이해하기
	`orElse()`는 항상 즉시 생성하거나 계산한다. (즉시 평가)
	`orElseGet` 은 필요할 때만 `Supplier`를 호출한다. (지연 평가)
6. 무조건 `Optional`이 좋은 것은 아니다.
	편의성과 안전성을 높여주지만 무조건 사용하는 것은 오히려 코드 복잡성을 증가시킬 수 있다.
	다음과 같은 경우 사용이 불필요할 수 있다.
		1. 항상 값이 있는 상황
		2. 값이 없으면 예외를 던지는 것이 더 자연스러운 상황
		3. 흔히 비는 경우가 아니라 흔히 채워져 있는 경우
		4. 성능이 극도로 중요한 로우레벨 코드