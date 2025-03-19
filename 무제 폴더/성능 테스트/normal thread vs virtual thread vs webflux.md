
GET
normal:
![[Pasted image 20250312155229.png]]


virtual thread:
![[Pasted image 20250312155331.png]]

webflux:

![[Pasted image 20250312181905.png]]


post:

normal:
![[Pasted image 20250312160042.png]]

virtual thread:
![[Pasted image 20250312163006.png]]


webflux:
![[Pasted image 20250312182837.png]]






-------

2.
GET

normal thread
![[Pasted image 20250312190850.png]]


virtual thread
![[Pasted image 20250312191013.png]]

webflux
![[Pasted image 20250312185722.png]]


![[Pasted image 20250312191113.png]]


POST
normal
![[Pasted image 20250312185243.png]]

virtual thread
![[Pasted image 20250312185502.png]]

webflux
![[Pasted image 20250312185613.png]]




===> 쓰기의 경우, webflux가 실패율 하나 없이 모든 요청을 처리한 것을 확인
다만 GET요청의 경우 1000건의 데이터를 조회하는게 더 느렸다. (webflux)



webflux flux를 mono로 변경하여 모두 메모리에 올려서 테스트 한 get
![[Pasted image 20250312193139.png]]
=> flux 보다는 성능이 2배정도 향상되었으나 기존 동기 방식과는 약 1.8배?의 성능 차이가 난다
즉, 조회 성능은 훨씬 떨어진다.


그리고 io 작업은 가상 스레드보다 그냥 스레드가 더 성능이 좋음
=> cpu를 많이 사용하는 작업에 가상 스레드를 붙여야할 것 같다.