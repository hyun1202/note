# 식별 관계란?
연관 관계를 갖는 entity에서 부모의 식별자를 자식 entity에서 pk로 즉 fk를 pk로 갖는 것을 말한다.

# 트러블 슈팅
퀴즈 통계 테이블에서 퀴즈 정보를 toOne 관계로 가지고 있었고, 이를 식별 관계로 설정을 하고자 했으나
`detached entity passed to persist: com.numo.domain.quiz.QuizInfo`와 같은 에러가 나왔다.

아래와 같이 데이터를 저장하고 있었고 quizInfo는 그냥 new로 만든 객체라 **비영속성**인 객체였던 것이다.

```java
QuizInfo quizInfo = new QuizInfo(quizInfoId);  
  
	QuizStat quizStat = QuizStat.builder()  
			.quizInfo(quizInfo)  
			.user(User.builder().userId(userId).build())  
			.totalCount(quizResult.getTotalCount())  
			.correctCount(quizResult.getCorrectCount())  
			.wrongCount(quizResult.getWrongCount())  
			.build();
```

## 원인
식별 관계를 위해 `@MapsId`를 사용했는데 

```java
@Id  
@Column(name = "quiz_info_id")  
private Long id;  
  
@OneToOne(fetch = FetchType.LAZY)  
@JoinColumn(name = "quiz_info_id")  
@MapsId  
QuizInfo quizInfo;
```

**부모 엔티티의 식별자를 자식 엔티티의 식별자로 사용**하는 어노테이션이다. 
즉, **부모가 반드시 영속 상태**이어야 한다고 JPA가 판단한다.

## 해결
1. exists문을 find로 변경
	* exists를 find로 변경할까 생각했으나 메모리 낭비라고 생각
	* 통계 데이터를 만들기 위해서 select절이 한번 더 발생 하므로 영속 객체를 만들기 위해 쿼리 날리는 방식은 효율이 떨어짐
2. entityManager를 이용해서 영속 객체로 만들고 저장 - 채택

```java
if (quizStatRepository.existsByQuizInfo_Id(quizInfoId)) {  
    throw new CustomException(ErrorCode.QUIZ_STAT_EXISTS);  
}

// 통계 데이터를 만들기 위해 퀴즈 데이터 조회
QuizResultDto quizResult = quizStatRepository.findQuiz(quizInfoId, userId);

// @MapsId 사용으로 quizInfo 객체를 영속 객체로 만들어준다.
QuizInfo quizInfo = entityManager.getReference(QuizInfo.class, quizInfoId);  
  
QuizStat quizStat = QuizStat.builder()  
        .quizInfo(quizInfo)  
        .user(User.builder().userId(userId).build())  
        .totalCount(quizResult.getTotalCount())  
        .correctCount(quizResult.getCorrectCount())  
        .wrongCount(quizResult.getWrongCount())  
        .build();  
  
return QuizStatResponseDto.of(quizStatRepository.save(quizStat));
```
