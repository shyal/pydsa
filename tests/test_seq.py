from pydsa.seq import lcs, max_diff, run_lengths, subsequence_indices


def test_lcs_is_the_length_by_default():
    assert lcs("abac", "cab") == 2


def test_lcs_full_is_the_table_of_lengths():
    assert lcs("ab", "b", full=True) == [[0, 0], [0, 0], [0, 1]]


def test_lcs_type_str_is_one_longest_common_subsequence():
    assert lcs("abac", "cab", type=str) == "ab"


def test_lcs_type_list_and_tuple_work_on_numbers():
    assert lcs([1, 4, 2], [1, 2, 4], type=list) == [1, 4]
    assert lcs([1, 4, 2], [1, 2, 4], type=tuple) == (1, 4)


def test_lcs_full_type_str_is_the_table_of_strings():
    assert lcs("ab", "b", full=True, type=str) == [["", ""], ["", ""], ["", "b"]]


def test_lcs_of_an_empty_input_is_empty():
    assert (lcs("", "abc"), lcs("", "", type=str)) == (0, "")


def test_max_diff_is_the_best_rise_so_far():
    assert max_diff([12, 6, 1, 2, 7]) == [-6, -5, 1, 6]


def test_max_diff_reverse_is_the_best_fall_so_far():
    assert max_diff([12, 6, 1, 2, 7], reverse=True) == [6, 11, 11, 11]


def test_max_diff_from_right_is_the_best_rise_from_the_right_end():
    assert max_diff([12, 6, 1, 2, 7], from_right=True) == [6, 6, 6, 5]


def test_max_diff_from_right_reverse_is_the_best_fall_from_the_right_end():
    assert max_diff([12, 6, 1, 2, 7], reverse=True, from_right=True) == [11, 5, -1, -5]


def test_max_diff_by_compares_a_key():
    assert max_diff(["ccc", "a", "bb"], key=len) == [-2, 1]


def test_max_diff_of_fewer_than_two_items_is_empty():
    assert max_diff([5]) == [] and max_diff([]) == []
    assert max_diff([5], from_right=True) == [] and max_diff([], from_right=True) == []


def test_max_diff_solves_121_and_2874():
    # 121. Best Time to Buy and Sell Stock
    assert max([0, *max_diff([7, 1, 5, 3, 6, 4])]) == 5
    # 2874. Maximum Value of an Ordered Triplet II
    a = [12, 6, 1, 2, 7]
    assert max([0, *(f * x for f, x in zip(max_diff(a, reverse=True), a[2:]))]) == 77


def test_subsequence_indices_are_the_earliest_indices():
    assert subsequence_indices("abcabc", "ac") == [0, 2]
    assert subsequence_indices("aab", "ab") == [0, 2]


def test_subsequence_indices_from_right_are_the_latest_indices():
    assert subsequence_indices("abcabc", "ac", from_right=True) == [3, 5]
    assert subsequence_indices("abb", "ab", from_right=True) == [0, 2]


def test_subsequence_indices_take_a_repeated_item_at_separate_indices():
    assert subsequence_indices("banana", "aa") == [1, 3]
    assert subsequence_indices("banana", "aa", from_right=True) == [3, 5]


def test_subsequence_indices_work_on_lists_and_tuples():
    assert subsequence_indices([5, 1, 5, 2], [5, 2]) == [0, 3]
    assert subsequence_indices((5, 1, 5, 2), (5, 2), from_right=True) == [2, 3]


def test_subsequence_indices_of_an_empty_sub_are_empty():
    assert subsequence_indices("abc", "") == []
    assert subsequence_indices("abc", "", from_right=True) == []


def test_subsequence_indices_are_empty_when_sub_is_not_a_subsequence():
    for from_right in (False, True):
        assert subsequence_indices("abc", "ca", from_right=from_right) == []
        assert subsequence_indices("abc", "aa", from_right=from_right) == []
        assert subsequence_indices("", "a", from_right=from_right) == []
        assert subsequence_indices([1, 2], [3], from_right=from_right) == []


def test_subsequence_indices_partial_are_the_indices_of_the_matched_prefix():
    assert subsequence_indices("abc", "acb", partial=True) == [0, 2]
    assert subsequence_indices("abc", "xa", partial=True) == []
    assert subsequence_indices("abc", "ax", partial=True) == [0]


def test_subsequence_indices_partial_from_right_are_those_of_the_matched_suffix():
    assert subsequence_indices("abc", "bac", from_right=True, partial=True) == [0, 2]
    assert subsequence_indices("abc", "cx", from_right=True, partial=True) == []
    assert subsequence_indices("abc", "xc", from_right=True, partial=True) == [2]


def test_subsequence_indices_partial_of_a_full_match_is_the_full_match():
    for from_right in (False, True):
        for s, sub in (("abcabc", "ac"), ("banana", "aa"), ("abc", "")):
            assert subsequence_indices(s, sub, from_right, partial=True) == subsequence_indices(s, sub, from_right)


def test_subsequence_indices_agree_with_a_brute_force():
    from itertools import combinations, product

    for s in map("".join, product("ab", repeat=5)):
        for sub in map("".join, product("ab", repeat=2)):
            hits = [list(c) for c in combinations(range(5), 2) if all(s[i] == x for i, x in zip(c, sub))]
            if hits:
                assert subsequence_indices(s, sub) == min(hits)
                assert subsequence_indices(s, sub, from_right=True) == max(hits, key=lambda h: h[::-1])
            else:
                assert subsequence_indices(s, sub) == []
                assert subsequence_indices(s, sub, from_right=True) == []


def test_run_lengths_end_at_each_index():
    assert run_lengths([5, 3, 3, 4, 2], lambda a, b: a >= b) == [1, 2, 3, 1, 2]


def test_run_lengths_from_right_start_at_each_index():
    assert run_lengths([5, 3, 3, 4, 2], lambda a, b: a <= b, from_right=True) == [1, 3, 2, 1, 1]


def test_run_lengths_extends_takes_the_pair_in_index_order_from_right():
    assert run_lengths([1, 2, 3, 9, 10], lambda a, b: b - a == 1, from_right=True) == [3, 2, 1, 2, 1]


def test_run_lengths_of_a_string_and_of_nothing():
    assert run_lengths("aab", lambda a, b: a == b) == [1, 2, 1]
    assert run_lengths([], lambda a, b: a < b) == []
    assert run_lengths([7], lambda a, b: a < b) == [1]
