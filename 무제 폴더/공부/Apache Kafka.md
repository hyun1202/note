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
