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
  xs: Iterable[Any], by: Optional[Any -> Any]=none, reverse: bool=false,
  from_right: bool=false
) -> [Any]
  """The largest by(xs[j]) - by(xs[i]) with i < j, so far, for each j
  from 1: one value per index after the first.

  by(x) is the value compared; with by left out it is x itself. reverse
  flips the difference to by(xs[i]) - by(xs[j]): the largest fall, not
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
    return max_diff(list(xs)[::-1], by, not reverse)[::-1]
  ys = [by is none ? x : by(x) for x in xs]
  ys = reverse ? [-y for y in ys] : ys
  scan(max, (y - lo for y, lo in zip(ys[1:], scan(min, ys))), type=list)
