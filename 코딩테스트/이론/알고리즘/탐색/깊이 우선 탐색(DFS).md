* depth-first search로 그래프 완전 탐색 기법 중 하나
* 그래프의 시작 노드에서 출발하여 탐색할 **한 쪽 분기를 정하여 최대 깊이까지 탐색**을 마친 후 다른 쪽 분기로 이동하여 탐색
* **재귀 함수** or 스택을 사용하여 구현
	* 재귀 함수를 이용하므로 스택 오버플로에 유의해야함 -> 예외처리 필요
* 시간 복잡도는 O(노드 수 + 에지 수)
* 응용 문제: 단절점 찾기, 단절선 찾기, 사이클 찾기, 위상 정렬 등

### 핵심 이론

* 한 번 방문한 노드를 다시 방문하면 안되므로 노드 방문 여부를 체크할 배열 필요
* 그래프는 인접 리스트로 표현
* DFS의 탐색 방식: 후입선출 (FILO -> 스택)

### 스택 
1. DFS를 시작할 노드를 정한 후 사용할 자료구조 초기화
		인접 리스트 생성 및 방문 배열 초기화
		![이미지](/이미지/Pasted%20image%2020240923094418.png)
		
2. 스택에서 노드를 꺼낸 후 꺼낸 노드의 인접 노드를 다시 스택에 삽입
		2.1 pop을 수행하여 노드를 꺼낸 후 인접 리스트를 확인
		2.2 탐색 순서에 꺼낸 노드를 기록한다.
		2.3 인접 리스트의 노드(들)를 스택에 삽입한다.
		2.4 방문 배열을 업데이트한다.

3. 스택 자료구조에 값이 없을 때까지 반복
	이미 다녀간 노드는 방문 배열을 바탕으로 재삽입하지 않는다.


#### 코드
```java
/**  
 * 스택을 이용한 DFS  
 */
 public class DFS_Stack {  
    public static void main(String[] args) {  
        // 인접 리스트  
        int n = 6;  
        List<Integer>[] list = new ArrayList[n];  
  
        for (int i=0; i<n; i++) {  
            list[i] = new ArrayList<>();  
        }  
  
        // 1 -> 2, 3  
        // 2 -> 5, 6        
        // 3 -> 4        
        // 4 -> 6  
        list[0].add(1);  
        list[0].add(2);  
  
        list[1].add(4);  
        list[1].add(5);  
  
        list[2].add(3);  
  
        list[3].add(5);  
  
        // 방문 배열  
        int[] visited = new int[n];  
  
        // 스택  
        Stack<Integer> stack = new Stack<>();  
  
        // 1. 스택에 시작점 추가.  
        stack.add(0);  
  
        // 반복  
        while(!stack.isEmpty()) {  
            // 2. pop으로 노드를 꺼내고 탐색 순서에 기입  
            int num = stack.pop();  
            System.out.println(num+1);  
  
            // 3. 인접 리스트의 인접 노드를 스택에 삽입 (방문 배열 체크)  
            for (int i=0; i<list[num].size(); i++) {  
                if (visited[list[num].get(i)] != 1) {  
                    stack.add(list[num].get(i));  
                    // 4. 방문 배열 업데이트.  
                    visited[list[num].get(i)] = 1;  
                }  
            }  
        }  
    }  
}
```


### 재귀 함수

```java
/**  
 * 재귀 함수를 이용한 DFS  
 */
 public class DFS_Recursive {  
    // 인접 리스트  
    static int n = 8;  
    // 방문 배열  
    static boolean[] visited = new boolean[n+1];  
    
    public static int[][] graph = {{},  
            {2, 3, 8},  
            {1, 7},  
            {1, 4, 5},  
            {3, 5},  
            {3, 4},  
            {7},  
            {2, 6, 8},  
            {1, 7}};  
  
    public static void main(String[] args) {  
      DFS(1);  
    }  
  
    static void DFS(int v) {  
        if (visited[v]) {  
            return;  
        }  
  
        System.out.println(v);  
  
        visited[v] = true;  
  
        for (int i : graph[v]) {  
            if (!visited[i]) {  
                DFS(i);  
            }  
        }  
    }  
}
```