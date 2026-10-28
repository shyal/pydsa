from pydsa.counting import Multiset


def test_key_vanishes_at_zero():
    m = Multiset()
    m["a"] += 1
    m["a"] -= 1
    assert "a" not in m
    assert len(m) == 0
    assert m == {}


def test_missing_key_reads_as_zero():
    m = Multiset()
    assert m["x"] == 0
    assert "x" not in m


def test_negative_counts_are_kept():
    m = Multiset()
    m["a"] -= 1
    assert m["a"] == -1
    m["a"] += 1
    assert "a" not in m


def test_constructor_and_update_go_through_the_filter():
    m = Multiset("aab")
    assert m == {"a": 2, "b": 1}
    m.update("b")
    m.subtract("aabb")
    assert m == {}
    m.update({"z": 0})
    assert "z" not in m


def test_zero_assignment_on_missing_key_is_a_no_op():
    m = Multiset()
    m["q"] = 0
    assert m == {}


from pydsa.counting import count_subarrays


def test_count_subarrays_sums_the_blocks():
    assert count_subarrays([1, 3, 2, 5, 4], lambda v: v % 2 == 1) == 4
    assert count_subarrays([1, 1], lambda v: 1 <= v <= 1) == 3
    assert count_subarrays([0, 0, 0], lambda v: v == 0) == 6
    assert count_subarrays([1, 2, 3], lambda v: v == 0) == 0
    assert count_subarrays([], lambda v: True) == 0


def test_count_subarrays_on_pairs_starts_each_block_at_one():
    assert count_subarrays([3, 2, 1, 4], lambda a, b: b == a - 1, pairs=True) == 7
    assert count_subarrays("aaab", lambda a, b: a == b, pairs=True) == 7
    assert count_subarrays([1, 2, 1, 2], lambda a, b: a != b, pairs=True) == 10
    assert count_subarrays([5], lambda a, b: False, pairs=True) == 1
    assert count_subarrays([], lambda a, b: True, pairs=True) == 0
