import pytest
from pydsa.arith import factorial, primes


def test_factorial_small():
    assert factorial(0) == 1
    assert factorial(1) == 1
    assert factorial(5) == 120


def test_factorial_negative_raises():
    with pytest.raises(ValueError):
        factorial(-1)


def test_primes_up_to_n():
    assert primes(0) == [] and primes(1) == [] and primes(2) == [2]
    assert primes(3) == [2, 3] and primes(4) == [2, 3]
    assert primes(10) == [2, 3, 5, 7]
    assert primes(29) == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    # the bound is included when it is prime
    assert primes(97)[-1] == 97 and primes(100)[-1] == 97 and primes(101)[-1] == 101
    assert len(primes(10**5)) == 9592


def test_primes_in_a_range():
    assert primes(11, 29) == [11, 13, 17, 19, 23, 29]
    assert primes(10, 30) == [11, 13, 17, 19, 23, 29]
    assert primes(0, 10) == primes(10) and primes(2, 2) == [2] and primes(2, 3) == [2, 3]
    assert primes(4, 4) == [] and primes(20, 10) == []
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
        primes(lo, lo + 37) == [p for p in below if lo <= p <= lo + 37]
        for lo in range(0, 950, 13)
    )


def test_primes_count():
    assert primes(count=0) == [] and primes(count=-1) == []
    assert primes(count=1) == [2] and primes(count=4) == [2, 3, 5, 7]
    # across the bound's switch at k = 6, and well past it
    assert primes(count=5) == [2, 3, 5, 7, 11] and primes(count=6) == [2, 3, 5, 7, 11, 13]
    assert primes(count=25) == primes(100)
    assert len(primes(count=9592)) == 9592 and primes(count=9592)[-1] == 99991
    assert primes(count=10**5)[-1] == 1299709


def test_primes_bounds_or_count():
    with pytest.raises(ValueError):
        primes(10, count=3)
    with pytest.raises(ValueError):
        primes()
