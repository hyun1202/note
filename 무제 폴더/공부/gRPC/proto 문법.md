# .proto
- 확장자 .proto
```proto
syntax = "proto3";  // 문법 버전

package tutorial;  // 패키지 선언 (선택)
```

## 메시지 및 필드 정의
```
message User {
	int32 id = 1;  // 타입 이름 번호
	string name = 2;
	string email = 3;
}
```
## 타입
### 정수형
```
message Numbers {
	int32 age = 1;
	int64 po = 2;
	unit32 count = 3;
	uint64 c = 4;
}
```
### 실수형 & Boolean
```
mesage BasicType {
	float tem = 1;  // 32비트
	double t = 2;  // 64비트
	bool is_active = 3;  // 참/거짓
}
```
### 문자열
```
message TextData {
	string name = 1;  // UTF-8 문자열
	bytes data = 2;  // 바이너리
}
```
### 배열
```
message UserProfile {
	string name = 1;
	repeated string hobbies = 2;
}

name: "이름"
hobbies = ["독서", "영화", "코딩"]
```
### Enum
```
enum Status {
	UNKNOWN = 0;
	ACTIVE = 1;
}

message Account {
	String name = 1;
	Status status = 2;
}
```
### 객체끼리 참조?
```
message Address {
	string street = 1;
	string city = 2;
}

mesage Person {
	string name = 1;
	int32 age = 2;
	Address home_address = 3;
	Address work_address = 4;
}
```
### 중첩 메시지
```
message Company {
	string name = 1;
	
	message Emplo {
		string name = 1;
	}
	
	repeated Emplo employees = 2;
}
```

## 기본 값
- proto3 에선 모든 필드가 기본 값을 가지고 있다.
```
message UserSettings {
	string theme = 1;  // 빈 문자열
	bool noti = 2;  // false
	int32 time = 3;  // 0
	repeated string lan = 4;  // []
}

enum Status2 {
	UNKNOWN = 0;  // 기본적으로 초기화 상태는 0으로 해주는게 좋음(첫 번째 값을 0을 기대하는 경우가 많다)
	STARTED = 1001;  // 필드 값은 어떤 값을 넣어도 무방하나, 중복 값은 안됨
	FINISHED = 1;
}

message ABC {
	Status2 test = 1;  // UNKNOWN
}
```