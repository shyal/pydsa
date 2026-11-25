from typing import Any, Iterable, Optional, Sequence

from .grid import cells, table

def lcs(a: Sequence[Any], b: Sequence[Any], full: bool=false, type=int)
  """Longest common subsequence of a and b.

  Row i and column j of the table stand for the prefixes a[:i] and b[:j],
  so row 0 and column 0 are the empty prefix. With type=int (the default)
  each cell holds the length; with type=str, list or tuple it holds one
  LCS itself, built as that type. Plain lcs(a, b) is the last cell,
  `dp[-1][-1]`; full returns the whole table."""
  dp = table(len(a) + 1, len(b) + 1, fill=type())
  for i, j in cells(dp, start=1)
    x = a[i - 1]
    if x == b[j - 1]
      dp[i][j] = dp[i - 1][j - 1] + (type is int ? 1 : type is str ? x : type([x]))
    else
      dp[i][j] = max(dp[i - 1][j], dp[i][j - 1], key=type is int ? none : len)
  full ? dp : dp[-1][-1]

def max_diff(
  xs: Iterable[Any], key: Optional[Any -> Any]=none, reverse: bool=false,
  from_right: bool=false
) -> [Any]
  """The largest key(xs[j]) - key(xs[i]) with i < j, so far, for each j
  from 1: one value per index after the first.

  key(x) is the value compared; with key left out it is x itself. reverse
  flips the difference to key(xs[i]) - key(xs[j]): the largest fall, not
  the largest rise.

  from_right scans from the right end: the value at i is the best
  difference over all pairs i' < j with i' >= i, one value per index
  before the last, in index order.

  >>> max_diff([12, 6, 1, 2, 7])
  [-6, -5, 1, 6]
  >>> max_diff([12, 6, 1, 2, 7], reverse=True)
  [6, 11, 11, 11]
  >>> max_diff([12, 6, 1, 2, 7], from_right=True)
  [6, 6, 6, 5]
  >>> max_diff([12, 6, 1, 2, 7], reverse=True, from_right=True)
  [11, 5, -1, -5]
  >>> max([0, *max_diff([7, 6, 4, 3, 1])])
  0
  """
  if from_right
    return max_diff(list(xs)[::-1], key, not reverse)[::-1]
  ys = [key is none ? x : key(x) for x in xs]
  ys = reverse ? [-y for y in ys] : ys
  scan(max, (y - lo for y, lo in zip(ys[1:], scan(min, ys))), type=list)

def subsequence_indices(
  s: Sequence[Any], sub: Sequence[Any], from_right: bool=false,
  partial: bool=false
) -> [int]
  """The earliest indices of s at which sub is a subsequence of s: one
  index per item of sub, in increasing order. [] when sub is not a
  subsequence of s.

  from_right matches from the right end: the latest indices, still in
  increasing order.

  partial returns the indices of the items that match before the first
  item with no match: a prefix of sub, or a suffix of sub with from_right.

  >>> subsequence_indices("abcabc", "ac")
  [0, 2]
  >>> subsequence_indices("abcabc", "ac", from_right=True)
  [3, 5]
  >>> subsequence_indices([5, 1, 5, 2], [5, 2])
  [0, 3]
  >>> subsequence_indices("abc", "acb")
  []
  >>> subsequence_indices("abc", "acb", partial=True)
  [0, 2]
  >>> subsequence_indices("abc", "bac", from_right=True, partial=True)
  [0, 2]
  """
  if from_right
    n = len(s)
    return [n - 1 - i for i in subsequence_indices(s[::-1], sub[::-1], partial=partial)][::-1]
  ret res = []
  j = -1
  for c in sub
    try
      j = s.index(c, j + 1)
    except ValueError
      return partial ? res : []
    res <- j

def run_lengths(
  xs: Sequence[Any], extends: (Any, Any) -> bool, from_right: bool=false
) -> [int]
  """The length of the run that ends at each index of xs: one value per
  item. A run is a stretch of items in which every pair of neighbours a, b
  satisfies extends(a, b). An item whose left neighbour fails extends(a, b)
  starts a new run of length 1.

  from_right gives the length of the run that starts at each index
  instead. extends still takes the pair in index order, left item first.

  >>> run_lengths([5, 3, 3, 4, 2], (a, b) -> a >= b)
  [1, 2, 3, 1, 2]
  >>> run_lengths([5, 3, 3, 4, 2], (a, b) -> a <= b, from_right=True)
  [1, 3, 2, 1, 1]
  >>> run_lengths([1, 2, 3, 9, 10], (a, b) -> b - a == 1)
  [1, 2, 3, 1, 2]
  >>> run_lengths("aab", (a, b) -> a == b)
  [1, 2, 1]
  >>> run_lengths([], (a, b) -> a < b)
  []
  """
  if from_right
    return run_lengths(xs[::-1], (a, b) -> extends(b, a))[::-1]
  if not xs
    return []
  scan((r, p) -> r + 1 if extends(*p) else 1, zip(xs, xs[1:]), initial=1, type=list)
