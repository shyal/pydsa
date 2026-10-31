"""Integer arithmetic helpers."""

from math import factorial as _factorial
from math import isqrt, log
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

def primes(lo: int?=none, hi: int?=none, count: int?=none) -> [int]
  """The primes from lo to hi, both ends included, in order; primes(n)
  alone is the primes up to n, and primes(count=k) the first k primes.
  primes(10) is [2, 3, 5, 7], primes(11, 29) is [11, 13, 17, 19, 23, 29]
  and primes(count=4) is [2, 3, 5, 7].

  A segmented sieve: the primes up to the square root of hi mark their
  multiples in lo..hi alone, so a short range high up, primes(10**9,
  10**9 + 100), costs the segment and not the billion below it. The
  first k primes are sieved up to Rosser's bound k (ln k + ln ln k),
  which the k-th prime is under from k = 6 on."""
  if count is not none
    if lo is not none or hi is not none
      raise ValueError("primes takes bounds or count, not both.")
    if count <= 0
      return []
    hi = 15 if count < 6 else int(count * (log(count) + log(log(count)))) + 1
    found = primes(hi)
    while len(found) < count
      found += primes(hi + 1, 2 * hi)
      hi *= 2
    return found[:count]
  if lo is none
    raise ValueError("primes takes a bound or count.")
  if hi is none
    lo, hi = 0, lo
  lo = max(lo, 2)
  if hi < lo
    return []
  flags = [1] * (hi - lo + 1)
  for p in primes(isqrt(hi))
    for j in max(p * p, ceil_div(lo, p) * p)..hi by p
      flags[j - lo] = 0
  [k for k in lo..hi if flags[k - lo]]
