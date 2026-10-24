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
  xs: Iterable[Any], by: Optional[Any -> Any]=none, want: Optional[Any -> Any]=none
) -> int
  """Count the index pairs i < j with by(xs[i]) == want(xs[j]), in one pass.

  by(x) is the key x is stored under and want(x) is the key x looks up.
  With by left out the key is x itself; with want left out it is by, so
  plain count_pairs(xs) counts the pairs of equal values.

  >>> count_pairs([1, 2, 3, 1, 1, 3])
  4
  >>> count_pairs([1, 6, 3, 11, 8], by=lambda x: x % 5)
  4
  >>> count_pairs([3, 1, 4, 6, 3], want=lambda x: x - 2)
  2
  """
  if by is none
    by = x -> x
  if want is none
    want = by
  ret res, cnt = 0, Counter()
  for x in xs
    res += cnt[want(x)]
    cnt[by(x)] += 1
