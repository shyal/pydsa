import pytest
from pydsa.arith import factorial, primes


def test_factorial_small():
    assert factorial(0) == 1
    assert factorial(1) == 1
    assert factorial(5) == 120


def test_factorial_negative_raises():
    with pytest.raises(ValueError):
        factorial(-1)


def test_primes_below_n():
    assert primes(0) == [] and primes(2) == [] and primes(3) == [2]
    assert primes(10) == [2, 3, 5, 7]
    assert primes(30) == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    # 97 is the last prime below 100, and 101 the first at or above it
    assert primes(100)[-1] == 97 and primes(102)[-1] == 101
    assert len(primes(10**5)) == 9592


def test_primes_in_a_range():
    assert primes(10, 30) == [11, 13, 17, 19, 23, 29]
    assert primes(0, 10) == primes(10) and primes(2, 3) == [2]
    assert primes(5, 5) == [] and primes(20, 10) == []
    # the segment above a billion is sieved alone
    want = [
        1000000007,
        1000000009,
        1000000021,
        1000000033,
        1000000087,
        1000000093,
        1000000097,
    ]
    assert primes(10**9, 10**9 + 100) == want
    # every window agrees with the plain sieve
    below = primes(1000)
    assert all(
        primes(lo, lo + 37) == [p for p in below if lo <= p < lo + 37]
        for lo in range(0, 950, 13)
    )
