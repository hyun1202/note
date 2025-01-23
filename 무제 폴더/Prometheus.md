## 필터
레이블을 기준으로 필터를 사용할 수 있다. 필터는 중괄호(`{}` ) 문법을 사용한다.
### 레이블 일치 연산자

* `=` 제공된 문자열과 정확히 동일한 레이블 선택
* `!=` 제공된 문자열과 같지 않은 레이블 선택
* `=~`  제공된 문자열과 정규식 일치하는 레이블 선택
* `!~` 제공된 문자열과 정규식 일치하지 않는 레이블 선택

* `uri=/log` , `method=GET` 조건으로 필터
	* `http_server_requests_seconds_count{uri="/log", method="GET"}`

* `/actuator/prometheus` 는 제외한 조건으로 필터
	* `http_server_requests_seconds_count{uri!="/actuator/prometheus"}`

* `method` 가 `GET` , `POST` 인 경우를 포함해서 필터
	* `http_server_requests_seconds_count{method=~"GET|POST"}`

* `/actuator`로 시작하는 `uri` 는 제외한 조건으로 필터
	* `http_server_requests_seconds_count{uri!~"/actuator.*"}`

