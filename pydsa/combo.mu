"""Index-combination helpers preloaded by sitecustomize: every pair and every
triple of indices below n, in lexicographic order, without recursion; every
substring of a sequence, in one of three orders."""

from typing import Any, Callable, Iterable, Iterator, Sequence

Maker = Callable[[Iterable[int]], Any]

def pairs(n: int, type: Maker=tuple, back: bool=false) -> Iterator[Any]
  """Every (i, j) with 0 <= i < j < n, in lexicographic order.

  With back, the pairs are grouped by the later index instead: for each
  j in turn, every (i, j) with i < j. That is the dp order, where cell j
  looks back at every earlier cell.

  Each pair is built by type: tuple by default, list for a LeetCode answer.
  """
  if back
    for j in 0..<n
      for i in 0..<j
        yield type((i, j))
  else
    for i in 0..<n
      for j in i + 1..<n
        yield type((i, j))

def triples(n: int, type: Maker=tuple) -> Iterator[Any]
  """Every (i, j, k) with 0 <= i < j < k < n, in lexicographic order.

  Each triple is built by type: tuple by default, list for a LeetCode answer.
  """
  for i in 0..<n
    for j in i + 1..<n
      for k in j + 1..<n
        yield type((i, j, k))

def substrings(s: Sequence, by: str="start") -> Iterator
  """Every slice s[i:j] with 0 <= i < j <= len(s), each position once.

  by picks the order: "start" groups the slices by where they start,
  shortest first; "end" groups them by where they end, longest first;
  "length" gives every slice of length 1, then of length 2, and so on,
  left to right. A list gives its subarrays the same way.
  """
  n = len(s)
  if by == "start"
    for i in 0..<n
      for j in i + 1..n
        yield s[i:j]
  elif by == "end"
    for j in 1..n
      for i in 0..<j
        yield s[i:j]
  elif by == "length"
    for size in 1..n
      for i in 0..n - size
        yield s[i:i + size]
  else
    raise ValueError(by)
