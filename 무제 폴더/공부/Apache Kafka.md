### docker 파일 작성

```yaml
services:
  zookeeper-0:
    image: bitnami/zookeeper:3.9.2
    container_name: zookeeper-0
    ports:
      - 2181:2181
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ALLOW_ANONYMOUS_LOGIN: yes

  kafka-0:
    image: bitnami/kafka:3.7.0
    container_name: kafka-0
    ports:
      - 9094:9094
    environment:
      ALLOW_PLAINTEXT_LISTENER: yes
      KAFKA_ENABLE_KRAFT: no
      KAFKA_CFG_ZOOKEEPER_CONNECT: zookeeper-0:2181
      KAFKA_CFG_LISTENERS: PLAINTEXT://:9092,EXTERNAL://:9094
      KAFKA_CFG_ADVERTISED_LISTENERS: PLAINTEXT://kafka-0:9092,EXTERNAL://localhost:9094
      KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP: CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT,PLAINTEXT:PLAINTEXT

  kafka-ui:
    image: provectuslabs/kafka-ui:v0.7.2
    container_name: kafka-ui
    depends_on:
      - kafka-0
    ports:
      - 8080:8080
    environment:
      KAFKA_CLUSTERS_0_NAME: local
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka-0:9092
```

카프카 클러스터는 주키퍼가 담당하므로 올려주어야 함
카프카를 쉽게 확인할 수 있도록 ui도 올려준다.

### 명령어

#### 토픽 생성
```bash
docker-compose exec kafka-0 kafka-topics.sh --create --topic topic1 --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1
```
topic1이라는 토픽을 생성
#### 컨슈머 메시지 구독
```bash
docker-compose exec kafka-0 kafka-console-consumer.sh --topic topic1 --bootstrap-server localhost:9092
```
topic1에 메시지 구독
#### 프로듀서 메시지 전송
```bash
docker-compose exec kafka-0 kafka-console-producer.sh -
-topic topic1 --broker-list localhost:9092
```
topic1에 메시지 발행
#### 토픽 데이터 확인
```bash
docker-compose exec kafka-0 kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic topic1 --from-beginning
```




# kafka
## 토픽
- 카프카에서 메시지를 보내는 논리적 개념.
- 일종의 구분 값
- append only -> 끝에만 값이 추가됨(수정X)
- 불변성 -> 한번 기록된 메시지는 변하지 않음
- 시간 기반의 보존 -> 설정된 시간이나 사이즈에 도달하면 삭제됨 (주기적 삭제)
### 명명 규칙
- user-events
- user-registration-completed
- dev.users-event

## 파티션
- 토픽을 논리적으로 나눠서 저장
- 병렬처리를 위해 존재
- 한번 증가한 파티션은 삭제가 불가능, (확장만 가능)
- 파티션 간 순서 보장이 안됨 (각 파티션에서는 보장 됨)
	- 같은 키에 대해서는 같은 파티션에 저장되도록 함
- 오프셋: 이벤트가 어디까지 처리가되었는지(중복된 메시지를 처리하지 않기 위함)
	- current offset: 현재 이벤트를 처리하고 있는 위치
	- committed offset: 가장 최근에 처리 완료된 offset (current offset - 1)
	- highwater mark: 파티션에서 저장된 마지막 메시지의 위치
	- logstart offset: 파티션에서 가장 오래된 메시지의 위치
### 컨슈머 렉
- 처리되지 않은 메시지 수
- 해결 방법
	- 파티션의 개수와 컨슈머의 개수를 동일
### 오프셋 전략
- 커밋 전략: 메시지를 처리했다는 것을 언제 명확하게 커밋을 하냐
	- 자동 커밋: 일정 시간마다 자동 오프셋 커밋, 메시지 손실 위험
	- 수동 커밋: 로직 처리 후 명시적 커밋, 데이터 안정성 보장 (구현 복잡)
	- 배치 커밋: 여러 메시지를 한번에 커밋, 성능 향상 (재처리 핸들링 필요)
- 오프셋 리셋 전략: 이 오프셋을 기준으로 어떻게 메시지를 읽을 것인지, 무시할 것인지에 대한 Reset 전략
	- earliest: 가장 오래된 메시지부터, 전체 데이터 처리 시 사용
	- latest: 가장 최신 메시지부터, 실시간 데이터 처리시 사용
	- none: 오프셋 없으면 예외 발생, 엄격한 오프셋 관리시 사용

## Producer
- 메시지 발송자
- ACKS: 메시지를 받았는지 확인
	- ACKS: 0 - 확인하지 않음
	- ACKS: 1 - 리더 파티션에만 메시지를 받았는지 확인
	- ACKS: all - 모든 파티션에 메시지를 받았는지 확인
## Consumer
- 메시지를 받아 핸들링
- bootstrap.server
- group.id
- auto.offset.reset
- enable.auto.commit
- rebalancing 
	- 문제 상황에서 파티션 재분배

## 메시지 법칙
- 멱등성이 보장되지 않으면 심각한 비즈니스 문제가 발생한다.
- At Most Once (ACKS 0, 자동 커밋)
	- 전달이 된다면 무조건 한 번만 처리함
	- 전달이 안될 수도 있음
	- 메시지 전송 후 즉시 오프셋 커밋
	- 로그나 메트릭 정보 등 어느정도 손실이 허용되는 경우 사용
- At Least Once (ACKS 1,all, 수동 커밋)
	- 메시지가 최소 한 번은 전달이 된다.
	- 중복이 가능하지만 유실은 절대 존재하지 않는다.
	- 메시지를 처리하고 오프셋을 커밋한다.
- Exactly Once 
	- 정확히 한 번만 전달
	- 중복도 없고 손실이 없다.
	- 프로듀서에 멱등성 활성화(enable.idempotence=true)
	- 이후 로직은 At Least Once와 동일
	- At Least Once와의 차이점은 멱등성 활성화 유무
# CDC (Chance Data Capture)
- 데이터베이스에서 발생하는 모든 데이터 변경 사항을 실시간으로 감지하고 캡처하는 기술
- Source Database: 원본 데이터가 저장된 데이터 베이스
- Target System: 변경된 데이터를 받아 처리하는 시스템
- Change Event: 데이터가 변경되는 이벤트

배치 처리는 실시간성 데이터를 처리하는 시스템에서는 아쉽다.

### 로그 기반 구현
- 실시간성이 뛰어남
- 트랜잭션 로그 파일을 읽어오면서 처리
- 소스 데이터베이스 성능에 영향이 없음(DB 부하가 적다)
### 트리거 기반 구현
- SQL 레벨에서의 쿼리 작성이 필요함
- 유지보수가 힘들다
- 잘 사용하지 않음
### TimeStamp 기반 구현
- 배치처리와 비슷
- 트리거 사용 또는 배치 처리
- 잘 사용하지 않음
### 스냅샷 기반 구현
- 전체 데이터에 대해 스냅샷을 생성하고 이전 스냅샷과 비교하여 변경사항 추출
- 잘 사용하지 않음