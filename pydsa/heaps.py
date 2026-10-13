"""heapq with the order reversed.

    maxheappush, maxheappop, maxheapify, maxheappushpop, maxheapreplace, maxheappeek,
    maxheapitems

Each function is its heapq namesake with the prefix max, same signature, and
the largest item comes out first. Items can be anything heapq accepts, tuples
included: there is no negation, so no minus sign to remember.

The list holds each item inside a small wrapper whose `<` is `>`. maxheappop
unwraps it; h[0] does not, so peek with maxheappeek(h), not h[0], and read
the whole heap with maxheapitems(h), not by iterating h.

A heap class and draw_heap, which draws a list heap as the tree it is.
"""

import heapq
from heapq import heapify, heappop, heappush
from typing import Any, List

from .tree import build_tree, draw_tree


class _Rev:
    __slots__ = ("item",)

    def __init__(self, item: Any):
        self.item = item

    def __lt__(self, other: "_Rev") -> bool:
        return other.item < self.item

    def __eq__(self, other: object) -> bool:
        return isinstance(other, _Rev) and self.item == other.item

    def __repr__(self) -> str:
        return repr(self.item)


def maxheapify(h: list) -> None:
    h[:] = [_Rev(x) for x in h]
    heapq.heapify(h)


def maxheappush(h: list, item: Any) -> None:
    heapq.heappush(h, _Rev(item))


def maxheappop(h: list) -> Any:
    return heapq.heappop(h).item


def maxheappushpop(h: list, item: Any) -> Any:
    return heapq.heappushpop(h, _Rev(item)).item


def maxheapreplace(h: list, item: Any) -> Any:
    return heapq.heapreplace(h, _Rev(item)).item


def maxheappeek(h: list) -> Any:
    return h[0].item


def maxheapitems(h: list) -> list:
    return [w.item for w in h]


class heap:
    """A heap of items, smallest first, or largest first with type=max.

    push, pop and peek as the words say; append is push, so a heap can
    stand in for a list. len and iteration work; iteration is heap order,
    not sorted order."""

    class _Rev:
        __slots__ = "x"

        def __init__(self, x):
            self.x = x

        def __lt__(self, o):
            return o.x < self.x

    def __init__(self, items=(), type=min):
        self.rev = type is max
        self.h = [self.wrap(x) for x in items]
        heapify(self.h)

    def wrap(self, x):
        return heap._Rev(x) if self.rev else x

    def unwrap(self, x):
        return x.x if self.rev else x

    def push(self, x):
        heappush(self.h, self.wrap(x))

    append = push

    def pop(self):
        return self.unwrap(heappop(self.h))

    def peek(self):
        return self.unwrap(self.h[0])

    def __len__(self):
        return len(self.h)

    def __iter__(self):
        return (self.unwrap(x) for x in self.h)


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
