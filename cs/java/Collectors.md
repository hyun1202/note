# GroupingBy
### 1. Collectors.groupingBy(Function<T, K> classifier)
`classifier` : 그룹핑할 key 값

```java
void collection1() {  
    Map<Long, List<WordDetailResponseDto>> collect = dtoList.stream()  
            .collect(Collectors.groupingBy(  
                    WordDetailResponseDto::wordGroupId  
            ));  
  
}
```
### 2.  Collectors.groupingBy(Function<T, K> classifier,  Collector<T, A, D> downstream)
`classifier`: 그룹핑할 key 값
`downstream`: 그룹핑한 값을 해당 값으로 value 생성

```java
void collection2() {  
    Map<Long, List<ReadWordDetailGroupingDto>> collect = dtoList.stream()  
            .collect(Collectors.groupingBy(  
                    WordDetailResponseDto::wordGroupId,  
                    Collectors.mapping(entry ->  
                            new ReadWordDetailGroupingDto(  
                                    entry.wordDetailId(),  
                                    entry.title(),  
                                    entry.content(),  
                                    entry.createTime(),  
                                    entry.updateTime()  
                            ), Collectors.toList()  
                    )  
            ));  
}
```

#### 3.  Collectors.groupingBy(Function<T, K> classifier, Supplier<Map<K, D>> mapFactory,  Collector<T, A, D> downstream)
`classifier`: 그룹핑할 key 값
`mapFactory`: 원하는 map의 형태를 지정
`downstream`: 그룹핑한 값을 해당 값으로 value 생성

## 의문점
### 1. 어떤 방식으로 그룹핑을 하는 것일까?
`classifier`에 `WordDetailResponseDto::wordGroupId`와 같은 key값에 해당하는 `function`을 넘겼는데 처음에는 저 id값으로 그룹핑을 하는구나 라고 생각했으나 아래와 같은 복합키에 해당하는 예제를 보고 의문이 생겼다.

```java
Map<String, List<ReadWordDetailGroupingDto>> collect = dtoList.stream()  
        .collect(Collectors.groupingBy(  
		        // 복합키
                entry -> entry.wordGroupId() + "_" + entry.groupName(),
                // 아래와 같은 복합키 객체도 잘 작동함
                // entry -> new ReadWordDetailGroupKey(entry.wordGroupId(), entry.groupName()),  
                Collectors.mapping(entry ->  
                        new ReadWordDetailGroupingDto(  
                                entry.wordDetailId(),  
                                entry.title(),  
                                entry.content(),  
                                entry.createTime(),  
                                entry.updateTime()  
                        ), Collectors.toList()  
                )  
        ));
```
> 위의 예제를 통해 
> groupingBy의 `classifier`는 해당하는 함수를 실행시켜서 key를 생성하고, 
> 그 key가 있다면 추가, 없다면 새로 생성하여 추가하는 방식으로 작동이 되는 것을 깨달았다.

dto에는 `entry.wordGroupId() + "_" + entry.groupName()` 라는 값이 없는데도 그룹핑이 잘 되는 것을 확인할 수 있었다.

```json
{5_자동사=[ReadWordDetailGroupingDto[wordDetailId=4, title=, content=[사람이] (배로)가다, 전진하다, createTime=null, updateTime=null]], 3_동사=[ReadWordDetailGroupingDto[wordDetailId=1, title=기본, content=put, createTime=null, updateTime=null], ReadWordDetailGroupingDto[wordDetailId=2, title=과거, content=put, createTime=null, updateTime=null], ReadWordDetailGroupingDto[wordDetailId=3, title=과거분사, content=put, createTime=null, updateTime=null]], 6_명사=[ReadWordDetailGroupingDto[wordDetailId=1, title=, content=밀기, 떠밀기, createTime=null, updateTime=null]]}
```

또한 `new ReadWordDetailGroupKey(entry.wordGroupId(), entry.groupName())`와 같이 Key 객체도 잘 작동하는 것을 확인할 수 있었다.

어떠한 방식으로 그룹핑을 하는지 확인해보니 **hashCode와 equals**를 이용하여 동일 여부 판단을 한다고 한다.
[[HashCode & Equals]] 참조

