from collections import Counter
from typing import Any, Iterable, Optional

class Multiset extends Counter
  """A Counter whose keys vanish when their count hits 0.

  `m[k] += 1` and `m[k] -= 1` are the whole interface. With a plain
  Counter, `m[k] -= 1` leaves the key behind at 0, so `len(m)` and
  `k in m` stop meaning what a sliding window needs them to mean.
  Negative counts are kept: only an exact 0 deletes."""

  def __setitem__(key, value) -> none
    if value == 0
      self.pop(key, none)
    else
      super().__setitem__(key, value)

  def update(*args, **kwds) -> none
    # Counter.update on an empty Counter is a bare dict.update, which
    # skips __setitem__; the pass below catches the zeros it let in.
    super().update(*args, **kwds)
    for key in [k for k, v in self.items() if v == 0]
      del self[key]

def count_pairs(
  xs: Iterable[Any], key: Optional[Any -> Any]=none, lookup: Optional[Any -> Any]=none
) -> int
  """Count the index pairs i < j with key(xs[i]) == lookup(xs[j]), in one pass.

  key(x) is the key x is stored under and lookup(x) is the key x looks up.
  With key left out the key is x itself; with lookup left out it is key, so
  plain count_pairs(xs) counts the pairs of equal values.

  >>> count_pairs([1, 2, 3, 1, 1, 3])
  4
  >>> count_pairs([1, 6, 3, 11, 8], key=lambda x: x % 5)
  4
  >>> count_pairs([3, 1, 4, 6, 3], lookup=lambda x: x - 2)
  2
  """
  if key is none
    key = x -> x
  if lookup is none
    lookup = key
  ret res, cnt = 0, Counter()
  for x in xs
    res += cnt[lookup(x)]
    cnt[key(x)] += 1

def count_subarrays(xs: Iterable[Any], key: Any -> bool, pairs: bool=false) -> int
  """Count the subarrays of xs in which every element passes key, or, with
  pairs, every adjacent pair (a, b) passes key(a, b).

  A maximal block that passes holds n * (n + 1) // 2 subarrays for its
  length n; the running count adds the current block length at each step.
  With pairs, a single element has no pair, so a block starts at length 1.

  >>> count_subarrays([1, 3, 2, 5, 4], lambda v: v % 2 == 1)
  4
  >>> count_subarrays([3, 2, 1, 4], lambda a, b: b == a - 1, pairs=True)
  7
  """
  ret res = 0
  n = 0
  prev = none
  for >i, x in xs
    passes = (i == 0 or key(prev, x)) if pairs else key(x)
    n = n + 1 if passes else (1 if pairs else 0)
    res += n
    prev = x
