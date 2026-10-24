from typing import Any

class TreeNode
  def __init__(val=0, left=none, right=none)
    self.val, self.left, self.right = val, left, right

class ListNode
  def __init__(val=0, next=none): self.val, self.next = val, next

  # Ordering by val, so heaps/sorts of nodes work like a ListNode.__lt__
  # override does on leetcode. No __eq__/__hash__: those must stay identity,
  # or seen-sets and cycle detection break on duplicate vals.
  def __lt__(other): self.val < other.val
  def __le__(other): self.val <= other.val
  def __gt__(other): self.val > other.val
  def __ge__(other): self.val >= other.val

  def __repr__()
    vals, seen, it = [], set(), self
    while it and it not in seen
      seen.add(it)
      vals <- str(it.val)
      it = it.next
    "->".join(vals)

class GraphNode
  def __init__(val=0, neighbors=none)
    self.val, self.neighbors = val, neighbors is none ? [] : neighbors

  def __repr__(): f"{self.val} -> ..."

class Node
  # parent=p adds the new node to p.children, as anytree's Node(name, parent=p)
  def __init__(val, children: {Any: "Node"}?=none, parent: "Node"?=none)
    self.val, self.children = val, children is none ? {} : children
    if parent is not none
      parent.children[len(parent.children)] = self
