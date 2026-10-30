from pydsa.graphs import as_dict_of_dicts


def test_dict_of_lists_becomes_dict_of_dicts():
    assert as_dict_of_dicts({0: [1, 2], 1: []}) == {0: {1: 1, 2: 1}, 1: {}}


def test_dict_of_dicts_unchanged():
    G = {0: {1: 5}, 1: {}}
    assert as_dict_of_dicts(G) == G


def test_dict_of_scalars_is_one_edge_per_key():
    assert as_dict_of_dicts({41: 0, 42: 0, 43: 1}) == {
        41: {0: 1},
        42: {0: 1},
        43: {1: 1},
    }


def test_parent_array_is_a_forest_without_self_loops():
    assert as_dict_of_dicts([2, 2, 2, 1]) == {0: {2: 1}, 1: {2: 1}, 2: {}, 3: {1: 1}}


def test_mixed_dict_values():
    assert as_dict_of_dicts({0: [1], 1: 2, 2: {3: 7}}) == {
        0: {1: 1},
        1: {2: 1},
        2: {3: 7},
    }


from pydsa.adj import adjacency, indegrees  # noqa: E402


def test_adjacency_directed_seeds_isolated_nodes():
    adj = adjacency([[0, 1], [0, 2], [1, 3]], 5)
    assert dict(adj) == {0: [1, 2], 1: [3], 2: [], 3: [], 4: []}


def test_adjacency_reverse_reads_b_to_a():
    adj = adjacency([[1, 0], [2, 0], [3, 1], [3, 2]], 4, reverse=True)
    assert dict(adj) == {0: [1, 2], 1: [3], 2: [3], 3: []}


def test_adjacency_undirected_adds_both_ways():
    adj = adjacency([[0, 1], [1, 2]], directed=False)
    assert dict(adj) == {0: [1], 1: [0, 2], 2: [1]}


def test_adjacency_weighted_is_dict_of_dicts():
    adj = adjacency([[0, 1, 5], [1, 2, 7]], 3, weighted=True)
    assert dict(adj) == {0: {1: 5}, 1: {2: 7}, 2: {}}


def test_adjacency_missing_key_reads_empty():
    assert adjacency([[0, 1]])[9] == []


def test_indegrees_default_reads_zero_for_unseen():
    indeg = indegrees([[0, 1], [0, 2], [1, 2]])
    assert dict(indeg) == {1: 1, 2: 2}
    assert indeg[7] == 0


def test_indegrees_with_n_seeds_every_node():
    assert dict(indegrees([[0, 1], [0, 2], [1, 2]], 4)) == {0: 0, 1: 1, 2: 2, 3: 0}


def test_indegrees_reverse_counts_into_a():
    assert indegrees([[1, 0], [2, 0], [3, 1], [3, 2]], 4, reverse=True, type=list) == [
        0,
        1,
        1,
        2,
    ]


def test_indegrees_list_type():
    assert indegrees([[0, 1]], 3, type=list) == [0, 1, 0]


def test_neighbor_tuples_carry_their_label():
    assert as_dict_of_dicts({0: [(1, "red"), (2, 5)], 1: []}) == {
        0: {1: "red", 2: 5},
        1: {},
    }


def test_parallel_edges_collect_labels():
    G = {0: [[1, "red"], [1, "blue"]]}
    assert as_dict_of_dicts(G) == {0: {1: ["red", "blue"]}}


def test_longer_tuples_keep_the_rest_as_label():
    assert as_dict_of_dicts({0: [(1, 5, "x")]}) == {0: {1: (5, "x")}}


def test_draw_graph_colours_named_edges(capsys):
    from pydsa.graphs import draw_graph

    draw_graph({0: [(1, "red"), (1, "blue")], 1: [(2, 7)]})
    out = capsys.readouterr().out
    assert "\x1b[31mred" in out
    assert "\x1b[34mblue" in out
    assert "7" in out


def test_node_colour_reads_leetcode_letters():
    from pydsa.graphs import _node_colour

    assert _node_colour("R") == "red"
    assert _node_colour("w") == "white"
    assert _node_colour("Blue") == "blue"
    assert _node_colour("orange") == "orange"


def test_per_node_indexes_dict_list_and_string():
    from pydsa.graphs import _per_node

    assert _per_node("BRW", 1) == "R"
    assert _per_node("BRW", 3) is None
    assert _per_node([5, 6], 0) == 5
    assert _per_node({"a": 1}, "a") == 1
    assert _per_node({"a": 1}, "b") is None
    assert _per_node(None, 0) is None


def test_node_attrs_fill_label_and_dark_text_on_light_fill():
    from pydsa.graphs import _node_attrs

    assert _node_attrs(None, None) == {}
    assert _node_attrs("R", None) == {"fillcolor": "red"}
    assert _node_attrs("W", None) == {"fillcolor": "white", "fontcolor": "black"}
    assert _node_attrs(None, 7) == {"label": "\\N\\n7"}
