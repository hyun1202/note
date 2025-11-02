# Proto 고급 패턴
## oneof
- 해당하는 필드 중 한개만 사용
- `oneof` 필드들은 메모리를 공유한다.
	- 하나를 설정하면 다른 것들은 자동으로 초기화됨
	- 기존의 옵션을 제거하는 것에 대해서는 호환성 측면에 문제가 됨 (삭제 주의)
```
// 모호함, 모든 필드를 사용하는가?
message SearchRequest {
	string query = 1;
	string keyword = 2;
	int32 user_id = 3;
	DataRange data_range = 4;
}

message SearchRequestOneOf {
	string query = 1;
	
	// 한개만 선택
	oneof search_type {
		string keyword = 2;
		int32 user_id = 3;
		DataRange data_range = 4;
	}
}

```

### oneof 사용 예시
```
message APIResponse {
	string request_id = 1;
	
	// 성공과 실패가 반드시 하나는 발생함
	oneof result {
		SuccessData success = 2;
		ErrorInfo error = 3;
	}
}

message SuccessData {
	string message = 1;
	repeated string data = 2;
}

message ErrorInfo {
	int32 error_code = 1;
	string error_message = 2;
}
```
### 이벤트 시스템 데이터 모델링
```
message UserLoginEvent {
	string user_id = 1;
	string ip_address = 2;
}

message OrderCreatedEvnt {
	string order_id = 1;
	string customer_id = 2;
}

message Event {
	string event_id = 1;
	string time = 2;
	
	oneof event_data {
		UserLoginEvent user_login = 10;
		OrderCreatedEvent order_created = 11;
	}
}
```
## Map
- key, value...?
```
message UserProfile {
	string id = 1;
	map<string, string> set = 3;
}

// json으로 표현하면 아래와 같다
{
	"user_id": "user1"
	"name": "이름"
	"set": {
		"theme": "dark"
		"lang": "ko",
		"timezone": "Asia/Seoul"
	}
}
```

### Map 예시
```
message Product {
	string product_id = 1;
	string name = 2;
	double price = 3;
	
	map<string, string> attr = 4;
}
```

## 동적 메시지 처리
- interface, any...와 같은?
- 성능에 대한 일부 오버헤드가 존재 (안정성 떨어짐)
```
// import 필수
import "google/protobuf/any.proto";

message GenericMessage {
	google.protobuf.Any payload = 1;
}
```