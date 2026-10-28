# pydsa

Documentation: [www.shyal.com/pydsa](https://www.shyal.com/pydsa/)

Data structure and algorithm helpers for LeetCode-style Python: the
functions one keeps rewriting at the top of a solution, written once and
tested.

```
pip install pizza-lib   # the import name is pydsa
```

```python
from pydsa import table, cells, nbrs, first_true, Multiset, maxheappush

dp = table(3, 4)                      # a 3 by 4 grid of zeros
for i, j in cells(grid):              # every cell, row by row
    for ni, nj in nbrs(grid, i, j):   # its on-grid neighbours
        ...
first_true(1, 10**9, lambda x: x * x >= n)   # the first x in [1, 10^9] with ok(x)
```

## Solves

Each solve is a complete LeetCode solution that uses pydsa, in Python and in
[mu](https://www.shyal.com/mu/), a language that transpiles to Python. A
third tab, Python, gives the same solve without pydsa. A mu
file calls pydsa helpers by name, with no import. The
[pydsa profile](https://www.shyal.com/mu/#profiles) registers them, and the
Python that mu prints contains the source of each helper that the file
calls.

```mu
# 53. Maximum Subarray (Kadane's algorithm)
class Solution
  def maxSubArray(nums: [int]) -> int
    max_diff(scan(+, [0] + nums))[-1]
```

<details><summary>pydsa</summary>

```python
# 53. Maximum Subarray (Kadane's algorithm)
from itertools import accumulate
from pydsa import max_diff

class Solution:
    def maxSubArray(self, nums: list[int]) -> int:
        return max_diff(accumulate(nums, initial=0))[-1]
```

</details>

<details><summary>python</summary>

```python
# 53. Maximum Subarray (Kadane's algorithm)
class Solution:
    def maxSubArray(self, nums: list[int]) -> int:
        best = cur = -float("inf")
        for x in nums:
            cur = max(x, cur + x)
            best = max(best, cur)
        return best
```

</details>

```mu
# 121. Best Time to Buy and Sell Stock (running minimum)
class Solution
  def maxProfit(prices: [int]) -> int
    max([0, *max_diff(prices)])
```

<details><summary>pydsa</summary>

```python
# 121. Best Time to Buy and Sell Stock (running minimum)
from pydsa import max_diff

class Solution:
    def maxProfit(self, prices: list[int]) -> int:
        return max([0, *max_diff(prices)])
```

</details>

<details><summary>python</summary>

```python
# 121. Best Time to Buy and Sell Stock (running minimum)
class Solution:
    def maxProfit(self, prices: list[int]) -> int:
        low, best = float("inf"), 0
        for p in prices:
            low = min(low, p)
            best = max(best, p - low)
        return best
```

</details>

```mu
# 130. Surrounded Regions (connected components)
class Solution
  def solve(board: [[str]])
    for c in components(cells(board, eq='O'), p -> nbrs(board, p, eq='O'))
      if not any(is_edge(board, i, j) for i, j in c)
        put(board, c, 'X')
```

<details><summary>pydsa</summary>

```python
# 130. Surrounded Regions (connected components)
from pydsa import cells, components, is_edge, nbrs, put

class Solution:
    def solve(self, board: list[list[str]]) -> None:
        for c in components(cells(board, eq="O"), lambda p: nbrs(board, p, eq="O")):
            if not any(is_edge(board, i, j) for i, j in c):
                put(board, c, "X")
```

</details>

<details><summary>python</summary>

```python
# 130. Surrounded Regions (connected components)
class Solution:
    def solve(self, board: list[list[str]]) -> None:
        m, n = len(board), len(board[0])
        st = [
            (i, j)
            for i in range(m)
            for j in range(n)
            if i in (0, m - 1) or j in (0, n - 1)
        ]
        while st:
            i, j = st.pop()
            if 0 <= i < m and 0 <= j < n and board[i][j] == "O":
                board[i][j] = "S"
                st += [(i + 1, j), (i - 1, j), (i, j + 1), (i, j - 1)]
        for row in board:
            row[:] = ["O" if c == "S" else "X" for c in row]
```

</details>

```mu
# 200. Number of Islands (connected components)
class Solution
  def numIslands(grid: [[str]]) -> int
    len components(cells(grid, eq='1'), p -> nbrs(grid, p, eq='1'))
```

<details><summary>pydsa</summary>

```python
# 200. Number of Islands (connected components)
from pydsa import cells, components, nbrs

class Solution:
    def numIslands(self, grid: list[list[str]]) -> int:
        return len(components(cells(grid, eq="1"), lambda p: nbrs(grid, p, eq="1")))
```

</details>

<details><summary>python</summary>

```python
# 200. Number of Islands (connected components)
class Solution:
    def numIslands(self, grid: list[list[str]]) -> int:
        m, n, islands = len(grid), len(grid[0]), 0
        for r in range(m):
            for c in range(n):
                if grid[r][c] == "1":
                    islands += 1
                    stack = [(r, c)]
                    while stack:
                        i, j = stack.pop()
                        if 0 <= i < m and 0 <= j < n and grid[i][j] == "1":
                            grid[i][j] = "0"
                            stack += [(i + 1, j), (i - 1, j), (i, j + 1), (i, j - 1)]
        return islands
```

</details>

```mu
# 410. Split Array Largest Sum (binary search on the answer)
class Solution
  def splitArray(nums: [int], k: int) -> int
    first_true(max(nums), sum(nums), cap -> min_chunks(nums, cap) <= k)
```

<details><summary>pydsa</summary>

```python
# 410. Split Array Largest Sum (binary search on the answer)
from pydsa import first_true, min_chunks

class Solution:
    def splitArray(self, nums: list[int], k: int) -> int:
        return first_true(max(nums), sum(nums), lambda cap: min_chunks(nums, cap) <= k)
```

</details>

<details><summary>python</summary>

```python
# 410. Split Array Largest Sum (binary search on the answer)
from bisect import bisect_left


class Solution:
    def splitArray(self, nums: list[int], k: int) -> int:
        def chunks(cap):
            n, total = 1, 0
            for x in nums:
                n, total = (n + 1, x) if total + x > cap else (n, total + x)
            return n

        lo, hi = max(nums), sum(nums)
        return lo + bisect_left(
            range(lo, hi + 1), True, key=lambda cap: chunks(cap) <= k
        )
```

</details>

```mu
# 516. Longest Palindromic Subsequence (dynamic programming)
class Solution
  def longestPalindromeSubseq(s: str) -> int
    lcs(s, s[::-1])
```

<details><summary>pydsa</summary>

```python
# 516. Longest Palindromic Subsequence (dynamic programming)
from pydsa import lcs

class Solution:
    def longestPalindromeSubseq(self, s: str) -> int:
        return lcs(s, s[::-1])
```

</details>

<details><summary>python</summary>

```python
# 516. Longest Palindromic Subsequence (dynamic programming)
class Solution:
    def longestPalindromeSubseq(self, s: str) -> int:
        n = len(s)
        dp = [0] * n
        for i in range(n - 1, -1, -1):
            dp[i], prev = 1, 0
            for j in range(i + 1, n):
                prev, dp[j] = dp[j], prev + 2 if s[i] == s[j] else max(dp[j], dp[j - 1])
        return dp[-1]
```

</details>

```mu
# 542. 01 Matrix (multi-source breadth-first search)
class Solution
  def updateMatrix(mat: [[int]]) -> [[int]]
    grid_bfs(mat, list(cells(mat, eq=0)))
```

<details><summary>pydsa</summary>

```python
# 542. 01 Matrix (multi-source breadth-first search)
from pydsa import cells, grid_bfs

class Solution:
    def updateMatrix(self, mat: list[list[int]]) -> list[list[int]]:
        return grid_bfs(mat, list(cells(mat, eq=0)))
```

</details>

<details><summary>python</summary>

```python
# 542. 01 Matrix (multi-source breadth-first search)
class Solution:
    def updateMatrix(self, mat: list[list[int]]) -> list[list[int]]:
        m, n = len(mat), len(mat[0])
        q = [(i, j) for i in range(m) for j in range(n) if mat[i][j] == 0]
        dist = [[-1 if v else 0 for v in row] for row in mat]
        for i, j in q:
            for a, b in [(i + 1, j), (i - 1, j), (i, j + 1), (i, j - 1)]:
                if 0 <= a < m and 0 <= b < n and dist[a][b] == -1:
                    dist[a][b] = dist[i][j] + 1
                    q.append((a, b))
        return dist
```

</details>

```mu
# 547. Number of Provinces (connected components)
class Solution
  def findCircleNum(isConnected: [[int]]) -> int
    len components(0..<len(isConnected), u -> [v for >v, x in isConnected[u] if x])
```

<details><summary>pydsa</summary>

```python
# 547. Number of Provinces (connected components)
from pydsa import components

class Solution:
    def findCircleNum(self, isConnected: list[list[int]]) -> int:
        def edges(u):
            return [v for v, x in enumerate(isConnected[u]) if x]

        return len(components(range(len(isConnected)), edges))
```

</details>

<details><summary>python</summary>

```python
# 547. Number of Provinces (connected components)
class Solution:
    def findCircleNum(self, isConnected: list[list[int]]) -> int:
        seen, provinces = set(), 0
        for s in range(len(isConnected)):
            if s not in seen:
                provinces += 1
                st = [s]
                while st:
                    u = st.pop()
                    if u not in seen:
                        seen.add(u)
                        st += [v for v, x in enumerate(isConnected[u]) if x]
        return provinces
```

</details>

```mu
# 2348. Number of Zero-Filled Subarrays (block counting)
class Solution
  def zeroFilledSubarray(nums: [int]) -> int
    count_subarrays(nums, v -> v == 0)
```

<details><summary>pydsa</summary>

```python
# 2348. Number of Zero-Filled Subarrays (block counting)
from pydsa import count_subarrays

class Solution:
    def zeroFilledSubarray(self, nums: list[int]) -> int:
        return count_subarrays(nums, lambda v: v == 0)
```

</details>

<details><summary>python</summary>

```python
# 2348. Number of Zero-Filled Subarrays (block counting)
class Solution:
    def zeroFilledSubarray(self, nums: list[int]) -> int:
        res = n = 0
        for v in nums:
            n = n + 1 if v == 0 else 0
            res += n
        return res
```

</details>

```mu
# 560. Subarray Sum Equals K (prefix sums)
class Solution
  def subarraySum(nums: [int], k: int) -> int
    count_pairs(scan(+, [0] + nums), lookup=p -> p - k)
```

<details><summary>pydsa</summary>

```python
# 560. Subarray Sum Equals K (prefix sums)
from itertools import accumulate
from pydsa import count_pairs

class Solution:
    def subarraySum(self, nums: list[int], k: int) -> int:
        return count_pairs(accumulate(nums, initial=0), lookup=lambda p: p - k)
```

</details>

<details><summary>python</summary>

```python
# 560. Subarray Sum Equals K (prefix sums)
from collections import Counter


class Solution:
    def subarraySum(self, nums: list[int], k: int) -> int:
        seen, total, count = Counter([0]), 0, 0
        for x in nums:
            total += x
            count += seen[total - k]
            seen[total] += 1
        return count
```

</details>

```mu
# 583. Delete Operation for Two Strings (dynamic programming)
class Solution
  def minDistance(word1: str, word2: str) -> int
    len(word1) + len(word2) - 2 * lcs(word1, word2)
```

<details><summary>pydsa</summary>

```python
# 583. Delete Operation for Two Strings (dynamic programming)
from pydsa import lcs

class Solution:
    def minDistance(self, word1: str, word2: str) -> int:
        return len(word1) + len(word2) - 2 * lcs(word1, word2)
```

</details>

<details><summary>python</summary>

```python
# 583. Delete Operation for Two Strings (dynamic programming)
class Solution:
    def minDistance(self, word1: str, word2: str) -> int:
        dp = list(range(len(word2) + 1))
        for i, a in enumerate(word1, 1):
            prev, dp[0] = dp[0], i
            for j, b in enumerate(word2, 1):
                prev, dp[j] = dp[j], prev if a == b else 1 + min(dp[j], dp[j - 1])
        return dp[-1]
```

</details>

```mu
# 695. Max Area of Island (connected components)
class Solution
  def maxAreaOfIsland(grid: [[int]]) -> int
    max from 0 for c in components(cells(grid, eq=1), p -> nbrs(grid, p, eq=1)): len(c)
```

<details><summary>pydsa</summary>

```python
# 695. Max Area of Island (connected components)
from pydsa import cells, components, nbrs

class Solution:
    def maxAreaOfIsland(self, grid: list[list[int]]) -> int:
        islands = components(cells(grid, eq=1), lambda p: nbrs(grid, p, eq=1))
        return max(map(len, islands), default=0)
```

</details>

<details><summary>python</summary>

```python
# 695. Max Area of Island (connected components)
class Solution:
    def maxAreaOfIsland(self, grid: list[list[int]]) -> int:
        m, n, best = len(grid), len(grid[0]), 0
        for i in range(m):
            for j in range(n):
                st, area = [(i, j)], 0
                while st:
                    a, b = st.pop()
                    if 0 <= a < m and 0 <= b < n and grid[a][b] == 1:
                        grid[a][b] = 0
                        area += 1
                        st += [(a + 1, b), (a - 1, b), (a, b + 1), (a, b - 1)]
                best = max(best, area)
        return best
```

</details>

```mu
# 743. Network Delay Time (Dijkstra's algorithm)
class Solution
  def networkDelayTime(times: [[int]], n: int, k: int) -> int
    max(dijkstra(graph(1..n, times, directed=True), k).values()) or -1 if inf
```

<details><summary>pydsa</summary>

```python
# 743. Network Delay Time (Dijkstra's algorithm)
from math import inf
from pydsa import dijkstra, graph

class Solution:
    def networkDelayTime(self, times: list[list[int]], n: int, k: int) -> int:
        t = max(dijkstra(graph(range(1, n + 1), times, directed=True), k).values())
        return -1 if t == inf else t
```

</details>

<details><summary>python</summary>

```python
# 743. Network Delay Time (Dijkstra's algorithm)
from collections import defaultdict
from heapq import heappop, heappush


class Solution:
    def networkDelayTime(self, times: list[list[int]], n: int, k: int) -> int:
        adj = defaultdict(list)
        for u, v, w in times:
            adj[u].append((v, w))
        dist, pq = {}, [(0, k)]
        while pq:
            d, u = heappop(pq)
            if u not in dist:
                dist[u] = d
                for v, w in adj[u]:
                    heappush(pq, (d + w, v))
        return max(dist.values()) if len(dist) == n else -1
```

</details>

```mu
# 778. Swim in Rising Water (binary search on the answer)
class Solution
  def swimInWater(grid: [[int]]) -> int
    reach = t -> grid_bfs(grid, [(0, 0)], ok=v -> v <= t)[-1][-1] >= 0
    first_true(grid[0][0], len(grid) ** 2, reach)
```

<details><summary>pydsa</summary>

```python
# 778. Swim in Rising Water (binary search on the answer)
from pydsa import first_true, grid_bfs

class Solution:
    def swimInWater(self, grid: list[list[int]]) -> int:
        def reach(t):
            return grid_bfs(grid, [(0, 0)], ok=lambda v: v <= t)[-1][-1] >= 0

        return first_true(grid[0][0], len(grid) ** 2, reach)
```

</details>

<details><summary>python</summary>

```python
# 778. Swim in Rising Water (binary search on the answer)
from bisect import bisect_left


class Solution:
    def swimInWater(self, grid: list[list[int]]) -> int:
        n = len(grid)

        def reach(t):
            seen, st = {(0, 0)}, [(0, 0)]
            while st:
                i, j = st.pop()
                for a, b in [(i + 1, j), (i - 1, j), (i, j + 1), (i, j - 1)]:
                    if (
                        0 <= a < n
                        and 0 <= b < n
                        and (a, b) not in seen
                        and grid[a][b] <= t
                    ):
                        seen.add((a, b))
                        st.append((a, b))
            return (n - 1, n - 1) in seen

        lo = grid[0][0]
        return lo + bisect_left(range(lo, n * n + 1), True, key=reach)
```

</details>

```mu
# 875. Koko Eating Bananas (binary search on the answer)
class Solution
  def minEatingSpeed(piles: [int], h: int) -> int
    first_true(1, max(piles), k -> sum(ceil_div(p, k) for p in piles) <= h)
```

<details><summary>pydsa</summary>

```python
# 875. Koko Eating Bananas (binary search on the answer)
from pydsa import ceil_div, first_true

class Solution:
    def minEatingSpeed(self, piles: list[int], h: int) -> int:
        def ok(k):
            return sum(ceil_div(p, k) for p in piles) <= h
        return first_true(1, max(piles), ok)
```

</details>

<details><summary>python</summary>

```python
# 875. Koko Eating Bananas (binary search on the answer)
from bisect import bisect_left


class Solution:
    def minEatingSpeed(self, piles: list[int], h: int) -> int:
        def ok(k):
            return sum((p + k - 1) // k for p in piles) <= h

        return 1 + bisect_left(range(1, max(piles) + 1), True, key=ok)
```

</details>

```mu
# 974. Subarray Sums Divisible by K (prefix sums)
class Solution
  def subarraysDivByK(nums: [int], k: int) -> int
    count_pairs(scan(+, [0] + nums), key=p -> p % k)
```

<details><summary>pydsa</summary>

```python
# 974. Subarray Sums Divisible by K (prefix sums)
from itertools import accumulate
from pydsa import count_pairs

class Solution:
    def subarraysDivByK(self, nums: list[int], k: int) -> int:
        return count_pairs(accumulate(nums, initial=0), key=lambda p: p % k)
```

</details>

<details><summary>python</summary>

```python
# 974. Subarray Sums Divisible by K (prefix sums)
from collections import Counter


class Solution:
    def subarraysDivByK(self, nums: list[int], k: int) -> int:
        seen, total, count = Counter([0]), 0, 0
        for x in nums:
            total = (total + x) % k
            count += seen[total]
            seen[total] += 1
        return count
```

</details>

```mu
# 1011. Capacity To Ship Packages Within D Days (binary search on the answer)
class Solution
  def shipWithinDays(weights: [int], days: int) -> int
    first_true(max(weights), sum(weights), cap -> min_chunks(weights, cap) <= days)
```

<details><summary>pydsa</summary>

```python
# 1011. Capacity To Ship Packages Within D Days (binary search on the answer)
from pydsa import first_true, min_chunks

class Solution:
    def shipWithinDays(self, weights: list[int], days: int) -> int:
        def fits(cap):
            return min_chunks(weights, cap) <= days

        return first_true(max(weights), sum(weights), fits)
```

</details>

<details><summary>python</summary>

```python
# 1011. Capacity To Ship Packages Within D Days (binary search on the answer)
from bisect import bisect_left


class Solution:
    def shipWithinDays(self, weights: list[int], days: int) -> int:
        def trips(cap):
            n, load = 1, 0
            for w in weights:
                n, load = (n + 1, w) if load + w > cap else (n, load + w)
            return n

        lo, hi = max(weights), sum(weights)
        return lo + bisect_left(range(lo, hi + 1), True, key=lambda c: trips(c) <= days)
```

</details>

```mu
# 1020. Number of Enclaves (connected components)
class Solution
  def numEnclaves(grid: [[int]]) -> int
    islands = components(cells(grid, eq=1), p -> nbrs(grid, p, eq=1))
    sum for c in islands if not any(is_edge(grid, i, j) for i, j in c): len(c)
```

<details><summary>pydsa</summary>

```python
# 1020. Number of Enclaves (connected components)
from pydsa import cells, components, is_edge, nbrs

class Solution:
    def numEnclaves(self, grid: list[list[int]]) -> int:
        islands = components(cells(grid, eq=1), lambda p: nbrs(grid, p, eq=1))
        return sum(
            len(c) for c in islands if not any(is_edge(grid, i, j) for i, j in c)
        )
```

</details>

<details><summary>python</summary>

```python
# 1020. Number of Enclaves (connected components)
class Solution:
    def numEnclaves(self, grid: list[list[int]]) -> int:
        m, n = len(grid), len(grid[0])
        st = [
            (i, j)
            for i in range(m)
            for j in range(n)
            if i in (0, m - 1) or j in (0, n - 1)
        ]
        while st:
            i, j = st.pop()
            if 0 <= i < m and 0 <= j < n and grid[i][j] == 1:
                grid[i][j] = 0
                st += [(i + 1, j), (i - 1, j), (i, j + 1), (i, j - 1)]
        return sum(map(sum, grid))
```

</details>

```mu
# 1074. Number of Submatrices That Sum to Target (prefix sums)
class Solution
  def numSubmatrixSumTarget(matrix: [[int]], target: int) -> int
    P = [[0] * len(matrix[0]), *scan((a, b) -> [x + y for x, y in zip(a, b)], matrix)]
    strip = (a, b) -> scan(+, [0] + [y - x for x, y in zip(a, b)])
    sum for i, j in pairs(len(P)): count_pairs(strip(P[i], P[j]), lookup=s -> s - target)
```

<details><summary>pydsa</summary>

```python
# 1074. Number of Submatrices That Sum to Target (prefix sums)
from itertools import accumulate
from pydsa import count_pairs, pairs

class Solution:
    def numSubmatrixSumTarget(self, matrix: list[list[int]], target: int) -> int:
        P = [
            [0] * len(matrix[0]),
            *accumulate(matrix, lambda a, b: [x + y for x, y in zip(a, b)]),
        ]

        def strip(a, b):
            return accumulate((y - x for x, y in zip(a, b)), initial=0)

        lookup = lambda s: s - target
        return sum(count_pairs(strip(P[i], P[j]), lookup=lookup) for i, j in pairs(len(P)))
```

</details>

<details><summary>python</summary>

```python
# 1074. Number of Submatrices That Sum to Target (prefix sums)
from collections import Counter


class Solution:
    def numSubmatrixSumTarget(self, matrix: list[list[int]], target: int) -> int:
        P = [[0] * len(matrix[0])]
        for row in matrix:
            P.append([x + y for x, y in zip(P[-1], row)])
        count = 0
        for i, a in enumerate(P):
            for b in P[i + 1 :]:
                seen, total = Counter([0]), 0
                for x, y in zip(a, b):
                    total += y - x
                    count += seen[total - target]
                    seen[total] += 1
        return count
```

</details>

```mu
# 1091. Shortest Path in Binary Matrix (breadth-first search)
class Solution
  def shortestPathBinaryMatrix(grid: [[int]]) -> int
    eight = [(a, b) for a in -1..1 for b in -1..1]
    d = grid_bfs(grid, [(0, 0)], ok=v -> not v, dirs=eight)
    grid[0][0] or d[-1][-1] < 0 ? -1 : d[-1][-1] + 1
```

<details><summary>pydsa</summary>

```python
# 1091. Shortest Path in Binary Matrix (breadth-first search)
from pydsa import ALL_EIGHT, grid_bfs

class Solution:
    def shortestPathBinaryMatrix(self, grid: list[list[int]]) -> int:
        d = grid_bfs(grid, [(0, 0)], ok=lambda v: not v, dirs=ALL_EIGHT)
        return -1 if grid[0][0] or d[-1][-1] < 0 else d[-1][-1] + 1
```

</details>

<details><summary>python</summary>

```python
# 1091. Shortest Path in Binary Matrix (breadth-first search)
class Solution:
    def shortestPathBinaryMatrix(self, grid: list[list[int]]) -> int:
        n = len(grid)
        if grid[0][0]:
            return -1
        dist, q = {(0, 0): 1}, [(0, 0)]
        for i, j in q:
            for a in range(i - 1, i + 2):
                for b in range(j - 1, j + 2):
                    if (
                        0 <= a < n
                        and 0 <= b < n
                        and not grid[a][b]
                        and (a, b) not in dist
                    ):
                        dist[(a, b)] = dist[(i, j)] + 1
                        q.append((a, b))
        return dist.get((n - 1, n - 1), -1)
```

</details>

```mu
# 1143. Longest Common Subsequence (dynamic programming)
class Solution
  def longestCommonSubsequence(text1: str, text2: str) -> int
    lcs(text1, text2)
```

<details><summary>pydsa</summary>

```python
# 1143. Longest Common Subsequence (dynamic programming)
from pydsa import lcs

class Solution:
    def longestCommonSubsequence(self, text1: str, text2: str) -> int:
        return lcs(text1, text2)
```

</details>

<details><summary>python</summary>

```python
# 1143. Longest Common Subsequence (dynamic programming)
class Solution:
    def longestCommonSubsequence(self, text1: str, text2: str) -> int:
        dp = [0] * (len(text2) + 1)
        for a in text1:
            prev = 0
            for j, b in enumerate(text2, 1):
                prev, dp[j] = dp[j], prev + 1 if a == b else max(dp[j], dp[j - 1])
        return dp[-1]
```

</details>

```mu
# 1162. As Far from Land as Possible (multi-source breadth-first search)
class Solution
  def maxDistance(grid: [[int]]) -> int
    d = grid_bfs(grid, list(cells(grid, eq=1)))
    max from -1 for i, j in cells(grid, eq=0): d[i][j]
```

<details><summary>pydsa</summary>

```python
# 1162. As Far from Land as Possible (multi-source breadth-first search)
from pydsa import cells, grid_bfs

class Solution:
    def maxDistance(self, grid: list[list[int]]) -> int:
        d = grid_bfs(grid, list(cells(grid, eq=1)))
        return max((d[i][j] for i, j in cells(grid, eq=0)), default=-1)
```

</details>

<details><summary>python</summary>

```python
# 1162. As Far from Land as Possible (multi-source breadth-first search)
class Solution:
    def maxDistance(self, grid: list[list[int]]) -> int:
        n = len(grid)
        q = [(i, j) for i in range(n) for j in range(n) if grid[i][j]]
        dist = {p: 0 for p in q}
        for i, j in q:
            for a, b in [(i + 1, j), (i - 1, j), (i, j + 1), (i, j - 1)]:
                if 0 <= a < n and 0 <= b < n and (a, b) not in dist:
                    dist[(a, b)] = dist[(i, j)] + 1
                    q.append((a, b))
        return max((d for (i, j), d in dist.items() if not grid[i][j]), default=-1)
```

</details>

```mu
# 1248. Count Number of Nice Subarrays (prefix sums)
class Solution
  def numberOfSubarrays(nums: [int], k: int) -> int
    count_pairs(scan(+, [0] + [x % 2 for x in nums]), lookup=p -> p - k)
```

<details><summary>pydsa</summary>

```python
# 1248. Count Number of Nice Subarrays (prefix sums)
from itertools import accumulate
from pydsa import count_pairs

class Solution:
    def numberOfSubarrays(self, nums: list[int], k: int) -> int:
        return count_pairs(
            accumulate((x % 2 for x in nums), initial=0), lookup=lambda p: p - k
        )
```

</details>

<details><summary>python</summary>

```python
# 1248. Count Number of Nice Subarrays (prefix sums)
from collections import Counter


class Solution:
    def numberOfSubarrays(self, nums: list[int], k: int) -> int:
        seen, odd, count = Counter([0]), 0, 0
        for x in nums:
            odd += x % 2
            count += seen[odd - k]
            seen[odd] += 1
        return count
```

</details>

```mu
# 1254. Number of Closed Islands (connected components)
class Solution
  def closedIsland(grid: [[int]]) -> int
    islands = components(cells(grid, eq=0), p -> nbrs(grid, p, eq=0))
    count for c in islands if not any(is_edge(grid, i, j) for i, j in c)
```

<details><summary>pydsa</summary>

```python
# 1254. Number of Closed Islands (connected components)
from pydsa import cells, components, is_edge, nbrs

class Solution:
    def closedIsland(self, grid: list[list[int]]) -> int:
        islands = components(cells(grid, eq=0), lambda p: nbrs(grid, p, eq=0))
        return sum(not any(is_edge(grid, i, j) for i, j in c) for c in islands)
```

</details>

<details><summary>python</summary>

```python
# 1254. Number of Closed Islands (connected components)
class Solution:
    def closedIsland(self, grid: list[list[int]]) -> int:
        m, n = len(grid), len(grid[0])

        def sink(i, j):
            st = [(i, j)]
            while st:
                a, b = st.pop()
                if 0 <= a < m and 0 <= b < n and grid[a][b] == 0:
                    grid[a][b] = 1
                    st += [(a + 1, b), (a - 1, b), (a, b + 1), (a, b - 1)]

        for i in range(m):
            for j in range(n):
                if i in (0, m - 1) or j in (0, n - 1):
                    sink(i, j)
        count = 0
        for i in range(m):
            for j in range(n):
                if grid[i][j] == 0:
                    sink(i, j)
                    count += 1
        return count
```

</details>

```mu
# 1334. Find the City With the Smallest Number of Neighbors at a Threshold Distance
# (Dijkstra's algorithm)
class Solution
  def findTheCity(n: int, edges: [[int]], distanceThreshold: int) -> int
    g, t = graph(0..<n, edges), distanceThreshold
    min(reversed(0..<n), key=c -> sum(d <= t for d in dijkstra(g, c).values()))
```

<details><summary>pydsa</summary>

```python
# 1334. Find the City With the Smallest Number of Neighbors at a Threshold Distance
# (Dijkstra's algorithm)
from pydsa import dijkstra, graph

class Solution:
    def findTheCity(
        self, n: int, edges: list[list[int]], distanceThreshold: int
    ) -> int:
        g, t = graph(range(n), edges), distanceThreshold
        return min(
            reversed(range(n)),
            key=lambda c: sum(d <= t for d in dijkstra(g, c).values()),
        )
```

</details>

<details><summary>python</summary>

```python
# 1334. Find the City With the Smallest Number of Neighbors at a Threshold Distance
# (Floyd-Warshall algorithm)
from math import inf


class Solution:
    def findTheCity(
        self, n: int, edges: list[list[int]], distanceThreshold: int
    ) -> int:
        D = [[0 if i == j else inf for j in range(n)] for i in range(n)]
        for u, v, w in edges:
            D[u][v] = D[v][u] = w
        for k in range(n):
            for i in range(n):
                for j in range(n):
                    D[i][j] = min(D[i][j], D[i][k] + D[k][j])
        return min(
            reversed(range(n)), key=lambda c: sum(d <= distanceThreshold for d in D[c])
        )
```

</details>

```mu
# 1971. Find if Path Exists in Graph (connected components)
class Solution
  def validPath(n: int, edges: [[int]], source: int, destination: int) -> bool
    g = adjacency(edges, directed=False)
    any({source, destination} <= set(c) for c in components(0..<n, u -> g[u]))
```

<details><summary>pydsa</summary>

```python
# 1971. Find if Path Exists in Graph (connected components)
from pydsa import adjacency, components

class Solution:
    def validPath(
        self, n: int, edges: list[list[int]], source: int, destination: int
    ) -> bool:
        g = adjacency(edges, directed=False)
        groups = components(range(n), lambda u: g[u])
        return any({source, destination} <= set(c) for c in groups)
```

</details>

<details><summary>python</summary>

```python
# 1971. Find if Path Exists in Graph (connected components)
from collections import defaultdict


class Solution:
    def validPath(
        self, n: int, edges: list[list[int]], source: int, destination: int
    ) -> bool:
        g = defaultdict(list)
        for u, v in edges:
            g[u].append(v)
            g[v].append(u)
        seen, st = {source}, [source]
        while st:
            for v in g[st.pop()]:
                if v not in seen:
                    seen.add(v)
                    st.append(v)
        return destination in seen
```

</details>

## Modules

| Module | Names |
| --- | --- |
| `grid` | `table`, `like`, `shape`, `cells`, `nbrs`, `in_bounds`, `is_edge`, `edges`, `put`, `row`, `col`, `set_row`, `set_col`, `grid_bfs`, `CARDINALS`, `DIAGONALS`, `ALL_EIGHT` |
| `adj` | `adjacency`, `indegrees`, `levels`, `components`, `Graph`, `graph`, `dijkstra` |
| `search` | `first_true`, `last_true`, `first_false`, `last_false`, `min_chunks`, `viz_binary_search` |
| `heaps` | `maxheappush`, `maxheappop`, `maxheapify`, `maxheappushpop`, `maxheapreplace`, `maxheappeek`, `maxheapitems`, `heap`, `draw_heap` |
| `counting` | `Multiset`, `count_pairs` |
| `combo` | `pairs`, `triples`, `substrings` |
| `digits` | `to_digits`, `to_int`, `num_digits`, `even`, `odd` |
| `arith` | `ceil_div`, `factorial`, `batched` |
| `seq` | `lcs`, `max_diff` |
| `generators` | `as_list` |
| `nodes` | `TreeNode`, `ListNode`, `GraphNode`, `Node` |
| `tree` | `build_tree`, `get_level_order`, `find_node`, `get_inorder`, `is_balanced`, `build_nary_tree`, `build_general_tree`, `get_general_tree`, `generate_random_tree`, `generate_full_binary_tree`, `draw_tree`, `draw_general_tree` |
| `bst` | `insert`, `generate_random_bst`, `is_valid_bst`, `generate_and_print_random_bst` |
| `linked` | `build_linked_list`, `get_list_values`, `print_linked_list`, `linked_list_reverse_k`, `draw_linked_list` |
| `graphs` | `build_graph`, `get_adj_list`, `build_graph_from_edge_list`, `as_dict_of_dicts`, `is_edge_list`, `draw_graph`, `draw_graphviz`, `draw_ascii_graph` |

Every public name is importable from the package itself. Every module
is written in [mu](https://www.shyal.com/mu/): `pydsa/<name>.mu`, with no
`.py` in the repo. On import, mu writes the Python of a module into
`__pycache__`, once for each change to the `.mu`, so the package needs
`mu-language` and, past that, only the standard library. The `draw_*` functions, `tabulate`-style
output and `viz_binary_search` import rich, colorama, PrettyPrintTree,
graphviz, tabulate, networkx and phart when first called:

```
pip install 'pizza-lib[draw]'
```

A function has a docstring only when its name and signature do not give
its contract; the tests in `tests/` are the examples.

## Where it comes from

These helpers were the harness of the `leet` repo, preloaded into
`builtins` for every solve there, and the library that the `mu` language
pastes into the Python it emits. Both still use them from here.

## Tests

```
pip install -e '.[test,draw]'
pytest
```
