# 컬렉터
- 스트림이 최종 연산으로 써 데이터를 처리할 때 그 결과물을 요구사항에 따라 반환값을 만들어 낸다.
- 그룹화, 분할, 통계, 리듀싱, 문자열 연결, 매핑이 가능

| 기능 | 메서드 예시 | 설명 | 반환 타입 |
|------|------------|------|----------|
| List로 수집 | toList(), toUnmodifiableList() | 스트림 요소를 List로 모은다. toUnmodifiableList()는 불변 리스트를 만든다. | List<T> |
| Set으로 수집 | toSet(), toCollection(HashSet::new) | 스트림 요소를 Set으로 모은다. 중복 요소는 자동으로 제거된다. 특정 Set 타입으로 모으려면 toCollection() 사용. | Set<T> |
| Map으로 수집 | toMap(keyMapper, valueMapper), toMap(keyMapper, valueMapper, mergeFunction, mapSupplier) | 스트림 요소를 Map에 (키, 값) 형태로 수집한다. 중복 키가 생기면 mergeFunction으로 해결하고, mapSupplier로 맵 타입을 지정할 수 있다. | Map<K, V> |
| 그룹화 | groupingBy(classifier), groupingBy(classifier, downstreamCollector) | 특정 기준 함수(classifier)에 따라 그룹별로 스트림 요소를 묶는다. 각 그룹에 대해 추가로 적용할 다운스트림 컬렉터를 지정할 수 있다. | Map<K, List<T>> 또는 Map<K, R> |
| 분할 | partitioningBy(predicate), partitioningBy(predicate, downstreamCollector) | predicate 결과가 true와 false 두 가지로 나뉘어, 2개 그룹으로 분할한다. | Map<Boolean, List<T>> 또는 Map<Boolean, R> |
| 통계 | counting(), summingInt(), averagingInt(), summarizingInt() 등 | 요소의 개수, 합계, 평균, 최소, 최댓값 등을 구하거나, IntSummaryStatistics 같은 통계 객체로도 모을 수 있다. | Long, Integer, Double, IntSummaryStatistics 등 |
| 리듀싱 | reducing(...) | 스트림의 reduce()와 유사하게, Collector 환경에서 요소를 하나로 합치는 연산을 할 수 있다. | Optional<T> 혹은 다른 타입 |
| 문자열 연결 | joining(delimiter, prefix, suffix) | 문자열 스트림을 하나로 합쳐서 연결한다. 구분자(delimiter), 접두사(prefix), 접미사(suffix) 등을 붙일 수 있다. | String |

## 다운 스트림 컬렉터
- **각 그룹 내부에서 추가적인 연산 또는 결과물을 정의**
- 그룹별 총합, 평균, 최대/최소값, 매핑결과, 통계등의 데이터를 얻고 싶을때가 많다.
	- 학년별로 학생들을 그룹화한 뒤 각 학년 그룹의 평균 점수를 구해야한다면 그룹 내 학생들의 점수를 합산하고 평균을 내는 동작이 더 필요하다.

| Collector | 사용 메서드 예시 | 설명 | 예시 반환 타입 |
|-----------|------------------|------|----------------|
| counting() | Collectors.counting() | 그룹 내(혹은 스트림 내) 요소들의 개수를 센다. | Long |
| summingInt() 등 | Collectors.summingInt(...), Collectors.summingLong(...) | 그룹 내 요소들의 특정 정수형 속성을 모두 합산한다. | Integer, Long 등 |
| averagingInt() 등 | Collectors.averagingInt(...), Collectors.averagingDouble(...) | 그룹 내 요소들의 특정 속성 평균값을 구한다. | Double |
| minBy(), maxBy() | Collectors.minBy(Comparator), Collectors.maxBy(Comparator) | 그룹 내 최소, 최댓값을 구한다. | Optional<T> |
| summarizingInt() 등 | Collectors.summarizingInt(...), Collectors.summarizingLong(...) | 개수, 합계, 평균, 최소, 최댓값을 동시에 구할 수 있는 SummaryStatistics 객체를 반환한다. | IntSummaryStatistics 등 |
| mapping() | Collectors.mapping(변환 함수, 다운스트림) | 각 요소를 다른 값으로 변환한 뒤, 변환된 값들을 다시 다른 Collector로 수집할 수 있게 한다. | 다운스트림 반환 타입에 따라 달라짐 |
| collectingAndThen() | Collectors.collectingAndThen(다른 컬렉터, 변환 함수) | 다운 스트림 컬렉터의 결과를 최종적으로 한 번 더 가공(후처리)할 수 있다. | 후처리 후의 타입 |
| reducing() | Collectors.reducing(초깃값, 변환 함수, 누적 함수), Collectors.reducing(누적 함수) | 스트림의 reduce()와 유사하게, 그룹 내 요소들을 하나로 합치는 로직을 정의할 수 있다. | 누적 로직에 따라 달라짐 |
| toList(), toSet() | Collectors.toList(), Collectors.toSet() | 그룹 내(혹은 스트림 내) 요소를 리스트나 집합으로 수집한다. toCollection(...)으로 구현체 지정 가능 | List<T>, Set<T> |
