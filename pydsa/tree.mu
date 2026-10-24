import random
from typing import Any, Iterable

from .nodes import Node as GeneralNode, TreeNode

def _pretty_print_tree()
  """PrettyPrintTree with our TreeFormatter patched in. Imported on first
  draw: PrettyPrint pulls in cmd2 (~75ms), and every interpreter start
  pays for sitecustomize's imports."""
  from PrettyPrint import PrettyPrintTree, PrintTree
  from . import _treeformat
  PrintTree.TreePrinter.TreeFormatter = _treeformat.TreeFormatter
  PrettyPrintTree

class Node
  # children is a dict for draw_general_tree and a list for build_nary_tree
  def __init__(val, children=none)
    self.val, self.children = val, children is none ? {} : children

def find_node(root, val)
  if root
    root.val == val ? root : find_node(root.left, val) or find_node(root.right, val)

def build_tree(arr: [int?]) -> TreeNode?
  """
  Utility function to build a binary tree from a level-order list representation.
  Null/None values are skipped for node creation.
  """
  if not arr or arr[0] is none
    # should this be [] ?
    return none
  nodes = [v is none ? none : TreeNode(v) for v in arr]
  kids = iter(nodes[1:])
  for node in nodes
    if node
      node.left, node.right = next(kids, none), next(kids, none)
  nodes[0]

def draw_tree(root: TreeNode?) -> none
  """
  Utility function to draw a binary tree in the terminal using PrettyPrintTree.
  Requires 'PrettyPrintTree' library: pip install PrettyPrintTree
  For colors, requires 'colorama': pip install colorama
  Supports node.color attribute for coloring the node value (e.g., 'blue', 'red', etc.).
  """
  if not root
    print "Empty tree"
    return
  print "\n"
  def get_value(node: TreeNode) -> str
    ret val_str = str(node.val)
    if hasattr(node, "color")
      from colorama import Fore, Style
      color = node.color.lower()
      if color in "black red green yellow blue magenta cyan white".split()
        val_str = getattr(Fore, color.upper()) + val_str + Style.RESET_ALL
  def get_children(node: TreeNode): [c for c in (node.left, node.right) if c]
  pt = _pretty_print_tree()(get_children, get_value, border=true, color="\x1b[30;43m")
  pt(root)

class _Wrapper
  def __init__(node: Node): self.node = node

def draw_general_tree(root: Node?) -> none
  if not root
    print "Empty tree"
    return
  print "\n"
  def get_children(w: _Wrapper)
    kids = w.node.children
    [_Wrapper(kid) for kid in (isinstance(kids, dict) ? kids.values() : kids)]
  def get_value(w: _Wrapper): str(hasattr(w.node, "label") ? w.node.label : w.node.val)
  pt = _pretty_print_tree()(get_children, get_value, border=true, color="\x1b[30;43m")
  pt(_Wrapper(root))

def generate_full_binary_tree(height: int) -> TreeNode?
  """
  Generates a full (perfect) binary tree of the given height.
  Height 0 returns a single node.
  Node values are assigned sequentially from 1 in level-order.
  """
  if height < 0
    return none
  # a perfect binary tree of height h has 2^(h+1) - 1 nodes
  build_tree(1..<(1 << (height + 1)))

def generate_random_tree(
  size: int, seed: int?=none, sparsity: float=0.0, skew: float=0.0,
  values: Iterable[int]?=none, bst: bool=false
) -> TreeNode?
  """A random binary tree with `size` nodes.

  The tree grows one node at a time. Each new node fills one of the empty
  child slots of the tree so far. Which slot is chosen is controlled by:

  sparsity in [0, 1]: 0 fills the shallowest slots first, so the tree is
      as bushy as a complete tree; 1 fills the deepest slots, so the tree
      is a long chain. In between, each node picks deep with probability
      `sparsity` and shallow otherwise.
  skew in [-1, 1]: -1 always takes a left slot when one is available at
      the chosen depth, 1 always takes a right one, 0 is even.
  values: the node values, in the order the tree grows; default is 1..size shuffled.
      With bst=True the values are sorted and assigned in inorder, so the
      tree is a valid BST with the same shape.
  seed: fixes the tree; the global random state is untouched.
  """
  if size <= 0
    return none
  rng = random.Random(seed)
  vals = values is none ? list(1..size) : list(values)
  if len(vals) != size
    raise ValueError(f"need {size} values, got {len(vals)}")
  if values is none
    rng.shuffle(vals)
  ret root = TreeNode(vals[0])
  # (depth, parent, side): every empty child slot in the tree so far
  slots = [(1, root, "left"), (1, root, "right")]
  for v in vals[1:]
    depth = (rng.random() < sparsity ? max : min)(s[0] for s in slots)
    at = [s for s in slots if s[0] == depth]
    side = rng.random() < (1 + skew) / 2 ? "right" : "left"
    depth, parent, name = rng.choice([s for s in at if s[2] == side] or at)
    slots.remove((depth, parent, name))
    child = TreeNode(v)
    setattr(parent, name, child)
    slots += [(depth + 1, child, "left"), (depth + 1, child, "right")]
  if bst
    stack, node = [], root
    for v in sorted(vals)
      while node
        stack <- node
        node = node.left
      node = stack .
      node.val = v
      node = node.right

def get_inorder(root: TreeNode?) -> [int]
  root ? get_inorder(root.left) + [root.val] + get_inorder(root.right) : []

def is_balanced(root: TreeNode?) -> bool
  def check_height(node: TreeNode?) -> int
    if not node
      return 0
    left = check_height(node.left)
    right = left == -1 ? -1 : check_height(node.right)
    right == -1 or abs(left - right) > 1 ? -1 : max(left, right) + 1
  check_height(root) != -1

def get_level_order(root: TreeNode?) -> [int?]
  ret vals, nodes = [], [root]
  for node in nodes
    vals <- node ? node.val : none
    if node
      nodes += [node.left, node.right]
  while vals and vals[-1] is none
    vals .

def build_nary_tree(arr: [int?]) -> Node?
  if not arr or arr[0] is none
    return none
  ret root = Node(arr[0], children=[])
  queue, vals = [root], iter(arr[2:])  # skip the first null at index 1
  for node in queue
    for v in vals
      if v is none
        break  # a null ends the children of this node
      node.children <- Node(v, children=[])
    queue += node.children

def build_general_tree(nested: [Any]) -> GeneralNode
  """A general tree from its nested form [val, [child, child, ...]], where
  each child is again [val, [...]]. Children get keys 0, 1, 2, ..."""
  val, kids = nested
  ret node = GeneralNode(val)
  for >i, kid in kids
    node.children[i] = build_general_tree(kid)

def get_general_tree(root: GeneralNode?) -> [Any]?
  """The nested form [val, [child, child, ...]] of a general tree, the
  inverse of build_general_tree. Children come in the order of .children."""
  if root is not none
    kids = isinstance(root.children, dict) ? root.children.values() : root.children
    [root.val, [get_general_tree(kid) for kid in kids]]
