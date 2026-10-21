"""Integer arithmetic helpers."""

from itertools import zip_longest
from math import factorial as _factorial
from typing import Any, List, Sequence

def ceil_div(a: int, b: int) -> int
  """a / b rounded up, for a >= 0 and b > 0."""
  if b <= 0
    raise ValueError("Denominator b must be positive.")
  if a < 0
    raise ValueError("Numerator a must be non-negative.")
  (a + b - 1) // b

def factorial(n: int) -> int
  """n! = n * (n - 1) * ... * 2 * 1, for n >= 0; 0! is 1."""
  if n < 0
    raise ValueError("n must be non-negative.")
  _factorial(n)

def batched(s: Sequence[Any], n: int = 1) -> List[Any]
  """s cut into pieces of n; the last piece holds what is left."""
  r = list(range(0, len(s), n))
  [s[a:b] for a, b in zip_longest(r, r[1:])]
