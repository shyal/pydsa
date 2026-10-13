# pydsa

Data structure and algorithm helpers for LeetCode-style Python: the
functions one keeps rewriting at the top of a solution, written once and
tested.

```
pip install dsa-py        # the import name is pydsa
```

```python
from pydsa import table, cells, nbrs, first_true, Multiset, maxheappush

dp = table(3, 4)                      # a 3 by 4 grid of zeros
for i, j in cells(grid):              # every cell, row by row
    for ni, nj in nbrs(grid, i, j):   # its on-grid neighbours
        ...
first_true(1, 10**9, lambda x: x * x >= n)   # the first x in [1, 10^9] with ok(x)
```

## Modules

| Module | Names |
| --- | --- |
| `grid` | `table`, `like`, `shape`, `cells`, `nbrs`, `in_bounds`, `is_edge`, `edges`, `put`, `row`, `col`, `set_row`, `set_col`, `grid_bfs`, `CARDINALS`, `DIAGONALS`, `ALL_EIGHT` |
| `adj` | `adjacency`, `indegrees`, `levels`, `components`, `Graph`, `graph`, `dijkstra` |
| `search` | `first_true`, `last_true`, `first_false`, `last_false`, `min_chunks`, `viz_binary_search` |
| `heaps` | `maxheappush`, `maxheappop`, `maxheapify`, `maxheappushpop`, `maxheapreplace`, `maxheappeek`, `maxheapitems`, `heap`, `draw_heap` |
| `counting` | `Multiset`, `count_pairs` |
| `combo` | `pairs`, `triples` |
| `digits` | `to_digits`, `to_int`, `even`, `odd` |
| `arith` | `ceil_div`, `batched` |
| `seq` | `lcs` |
| `generators` | `as_list` |
| `nodes` | `TreeNode`, `ListNode`, `GraphNode`, `Node` |
| `tree` | `build_tree`, `get_level_order`, `find_node`, `get_inorder`, `is_balanced`, `build_nary_tree`, `build_general_tree`, `get_general_tree`, `generate_random_tree`, `generate_full_binary_tree`, `draw_tree`, `draw_general_tree` |
| `bst` | `insert`, `generate_random_bst`, `tree_to_list`, `is_valid_bst`, `generate_and_print_random_bst` |
| `linked` | `build_linked_list`, `get_list_values`, `print_linked_list`, `linked_list_reverse_k`, `draw_linked_list` |
| `graphs` | `build_graph`, `get_adj_list`, `build_graph_from_edge_list`, `as_dict_of_dicts`, `is_edge_list`, `draw_graph`, `draw_graphviz`, `draw_ascii_graph` |

Every public name is importable from the package itself. The package
imports only the standard library. The `draw_*` functions, `tabulate`-style
output and `viz_binary_search` import rich, colorama, PrettyPrintTree and
graphviz when first called:

```
pip install 'dsa-py[draw]'
```

Every function has a docstring with its contract; the tests in `tests/`
are the examples.

## Where it comes from

These helpers were the harness of the `leet` repo, preloaded into
`builtins` for every solve there, and the library that the `mu` language
pastes into the Python it emits. Both still use them from here.

## Tests

```
pip install -e '.[test]'
pytest
```
