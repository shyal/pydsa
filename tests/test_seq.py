from pydsa.seq import lcs, max_diff


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
    assert max_diff(["ccc", "a", "bb"], by=len) == [-2, 1]


def test_max_diff_of_fewer_than_two_items_is_empty():
    assert max_diff([5]) == [] and max_diff([]) == []
    assert max_diff([5], from_right=True) == [] and max_diff([], from_right=True) == []


def test_max_diff_solves_121_and_2874():
    # 121. Best Time to Buy and Sell Stock
    assert max([0, *max_diff([7, 1, 5, 3, 6, 4])]) == 5
    # 2874. Maximum Value of an Ordered Triplet II
    a = [12, 6, 1, 2, 7]
    assert max([0, *(f * x for f, x in zip(max_diff(a, reverse=True), a[2:]))]) == 77
