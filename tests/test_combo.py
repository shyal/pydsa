from itertools import combinations

import pytest

from pydsa.combo import pairs, substrings, triples


def test_pairs_lexicographic():
    assert list(pairs(4)) == [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]


def test_pairs_back_groups_by_later_index():
    assert list(pairs(4, back=True)) == [(0, 1), (0, 2), (1, 2), (0, 3), (1, 3), (2, 3)]
    assert sorted(pairs(7, back=True)) == list(pairs(7))
    assert list(pairs(1, back=True)) == []


def test_pairs_too_small_is_empty():
    assert list(pairs(1)) == []


def test_triples_lexicographic():
    assert list(triples(4)) == [(0, 1, 2), (0, 1, 3), (0, 2, 3), (1, 2, 3)]


def test_triples_too_small_is_empty():
    assert list(triples(2)) == []


def test_matches_combinations():
    assert list(pairs(7)) == list(combinations(range(7), 2))
    assert list(triples(7)) == list(combinations(range(7), 3))


def test_type_builds_each_one():
    assert list(pairs(3, type=list)) == [[0, 1], [0, 2], [1, 2]]
    assert list(triples(4, type=list)) == [[0, 1, 2], [0, 1, 3], [0, 2, 3], [1, 2, 3]]


def test_substrings_by_start():
    assert list(substrings("abcd")) == ["a", "ab", "abc", "abcd", "b", "bc", "bcd", "c", "cd", "d"]


def test_substrings_by_end():
    assert list(substrings("abcd", by="end")) == ["a", "ab", "b", "abc", "bc", "c", "abcd", "bcd", "cd", "d"]


def test_substrings_by_length():
    assert list(substrings("abcd", by="length")) == ["a", "b", "c", "d", "ab", "bc", "cd", "abc", "bcd", "abcd"]


def test_substrings_keep_repeats_and_count_positions():
    assert list(substrings("aaa", by="length")) == ["a", "a", "a", "aa", "aa", "aaa"]
    for by in ("start", "end", "length"):
        assert len(list(substrings("abcdefghij", by=by))) == 55
        assert sorted(substrings("abcdefghij", by=by)) == sorted(substrings("abcdefghij"))


def test_substrings_edges():
    assert list(substrings("a")) == ["a"]
    assert list(substrings("")) == []
    assert list(substrings([1, 2, 3], by="length")) == [[1], [2], [3], [1, 2], [2, 3], [1, 2, 3]]


def test_substrings_rejects_an_unknown_order():
    with pytest.raises(ValueError):
        list(substrings("ab", by="size"))
