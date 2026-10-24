"""Integer arithmetic helpers."""

from math import factorial as _factorial
from typing import Sequence

def ceil_div(a: int, b: int) -> int
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

def batched(s: Sequence, n: int=1) -> list
  """s cut into pieces of n; the last piece holds what is left."""
  [s[i:i + n] for i in range(0, len(s), n)]
