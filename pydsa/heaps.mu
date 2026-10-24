"""Heaps that hold the items as they are, smallest first or largest first.

    maxheappush, maxheappop, maxheapify, maxheappushpop, maxheapreplace, maxheappeek,
    maxheapitems

Each function is its heapq namesake with the prefix max, same signature, and
the largest item comes out first. Items can be anything with `<`, tuples
included: there is no negation and no wrapper, so h[0] is the largest item
and iterating h gives the items.

A heap class and draw_heap, which draws a list heap as the tree it is.
"""

from heapq import heapify, heappop, heappush  # re-exported

from .tree import build_tree, draw_tree

def _lt(a, b): a < b
def _gt(a, b): b < a

def _push(h: list, x, before) -> none
  h <- x
  i = len h - 1
  while i and before(x, h[p := (i - 1) // 2])
    h[i], i = h[p], p
  h[i] = x

def _down(h: list, i: int, before) -> none
  n, x = len(h), h[i]
  while (c := 2i + 1) < n
    if c + 1 < n and before(h[c + 1], h[c])
      c += 1
    if not before(h[c], x)
      break
    h[i], i = h[c], c
  h[i] = x

def _pop(h: list, before)
  ret x = h .
  if h
    x, h[0] = h[0], x
    _down(h, 0, before)

def maxheapify(h: list) -> none
  for i in reversed(0..<len(h) // 2)
    _down(h, i, _gt)

def maxheappushpop(h: list, item)
  if h and item < h[0]
    item, h[0] = h[0], item
    _down(h, 0, _gt)
  item

def maxheapreplace(h: list, item)
  top, h[0] = h[0], item
  _down(h, 0, _gt)
  top

def maxheappush(h: list, item) -> none: _push(h, item, _gt)
def maxheappop(h: list): _pop(h, _gt)
def maxheappeek(h: list): h[0]
def maxheapitems(h: list) -> list: list h

class heap
  """A heap of items, smallest first, or largest first with type=max.

  push, pop and peek as the words say; append is push, so a heap can
  stand in for a list. len and iteration work; iteration is heap order,
  not sorted order. h is the list of items in heap order, for min and
  max the same."""

  def __init__(items=(), type=min)
    self.before = type is max ? _gt : _lt
    self.h = list items
    for i in reversed(0..<len(self.h) // 2)
      _down(self.h, i, self.before)

  def push(x) -> none: _push(self.h, x, self.before)
  def pop(): _pop(self.h, self.before)
  def peek(): self.h[0]
  def __len__(): len self.h
  def __iter__(): iter self.h
  append = push

def draw_heap(heap_list: [int]) -> none
  """
  Utility function to draw a heap represented as a list in the terminal.
  The heap list is assumed to be in level-order (array representation of a complete binary tree).
  """
  if not heap_list
    print "Empty heap"
    return
  draw_tree(build_tree(list(heap_list)))
