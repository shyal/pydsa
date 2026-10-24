"""Heaps that hold the items as they are, smallest first or largest first.

    maxheappush, maxheappop, maxheapify, maxheappushpop, maxheapreplace, maxheappeek,
    maxheapitems

Each function is its heapq namesake with the prefix max, same signature, and
the largest item comes out first. Items can be anything with `<`, tuples
included: there is no negation and no wrapper, so h[0] is the largest item
and iterating h gives the items.

A heap class and draw_heap, which draws a list heap as the tree it is.
"""

from heapq import heapify, heappop, heappush  # noqa: F401
from typing import Any, List

from .tree import build_tree, draw_tree


def _lt(a, b):
    return a < b


def _gt(a, b):
    return b < a


def _up(h: list, i: int, before) -> None:
    x = h[i]
    while i:
        p = (i - 1) // 2
        if not before(x, h[p]):
            break
        h[i] = h[p]
        i = p
    h[i] = x


def _down(h: list, i: int, before) -> None:
    n, x = len(h), h[i]
    while (c := 2 * i + 1) < n:
        if c + 1 < n and before(h[c + 1], h[c]):
            c += 1
        if not before(h[c], x):
            break
        h[i] = h[c]
        i = c
    h[i] = x


def _pop(h: list, before) -> Any:
    last = h.pop()
    if not h:
        return last
    top, h[0] = h[0], last
    _down(h, 0, before)
    return top


def maxheapify(h: list) -> None:
    for i in reversed(range(len(h) // 2)):
        _down(h, i, _gt)


def maxheappush(h: list, item: Any) -> None:
    h.append(item)
    _up(h, len(h) - 1, _gt)


def maxheappop(h: list) -> Any:
    return _pop(h, _gt)


def maxheappushpop(h: list, item: Any) -> Any:
    if h and item < h[0]:
        item, h[0] = h[0], item
        _down(h, 0, _gt)
    return item


def maxheapreplace(h: list, item: Any) -> Any:
    top, h[0] = h[0], item
    _down(h, 0, _gt)
    return top


def maxheappeek(h: list) -> Any:
    return h[0]


def maxheapitems(h: list) -> list:
    return list(h)


class heap:
    """A heap of items, smallest first, or largest first with type=max.

    push, pop and peek as the words say; append is push, so a heap can
    stand in for a list. len and iteration work; iteration is heap order,
    not sorted order. h is the list of items in heap order, for min and
    max the same."""

    def __init__(self, items=(), type=min):
        self.before = _gt if type is max else _lt
        self.h = list(items)
        for i in reversed(range(len(self.h) // 2)):
            _down(self.h, i, self.before)

    def push(self, x):
        self.h.append(x)
        _up(self.h, len(self.h) - 1, self.before)

    append = push

    def pop(self):
        return _pop(self.h, self.before)

    def peek(self):
        return self.h[0]

    def __len__(self):
        return len(self.h)

    def __iter__(self):
        return iter(self.h)


def draw_heap(heap_list: List[int]) -> None:
    """
    Utility function to draw a heap represented as a list in the terminal.
    The heap list is assumed to be in level-order (array representation of a complete binary tree).
    Leverages build_tree and draw_tree from tree_utils.py.
    """
    if not heap_list:
        print("Empty heap")
        return

    # Build the binary tree from the heap list (no Nones expected)
    root = build_tree(
        [val for val in heap_list]
    )  # Convert to List[Optional[int]] implicitly
    draw_tree(root)
