"""Digit helpers preloaded by sitecustomize: a number as its list of digits and
back, its count of digits, and the parity tests even and odd."""

from math import log2

def to_digits(num: int | str, reverse: bool=false, base: int=10) -> [int]
  """The digits of num in the given base as ints, most significant first.

  With reverse=True the least significant digit comes first, so digit i
  is the coefficient of base**i. A negative int loses its sign. A str is
  read one character at a time, so leading zeros are kept; base=2 gives
  the bits.
  """
  if isinstance(num, str)
    ds = [int(c, base) for c in num.lstrip("-")]
    return reverse ? ds[::-1] : ds
  num, ds = abs num, []
  while num or not ds
    num, d = divmod(num, base)
    ds <- d
  reverse ? ds : ds[::-1]

def num_digits(num: int, base: int=10) -> int
  """The count of digits of num in the given base; 0 has one digit.

  A negative int loses its sign. It does not convert num to a str, so it
  is fast on big ints and has no int max str digits limit.
  """
  num = abs num
  ret d = max(1, int(num.bit_length() / log2(base)))
  while d > 1 and base ** (d - 1) > num
    d -= 1
  while base ** d <= num
    d += 1

def to_int(digits: [int], reverse: bool=false, base: int=10) -> int
  """The int whose digits in the given base are the list, most significant first.

  With reverse=True the list is read least significant first, the inverse
  of to_digits(num, reverse=True). An empty list is 0. base=2 reads bits.
  """
  ret out = 0
  for d in reverse ? digits[::-1] : digits
    out = out * base + d

def even(n: int) -> bool: n % 2 == 0
def odd(n: int) -> bool: n % 2 == 1
