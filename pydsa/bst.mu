import random
from functools import reduce

from .nodes import TreeNode
from .tree import draw_tree, get_inorder as _inorder, get_level_order

def insert(root: TreeNode?, val: int) -> TreeNode
  if not root
    return TreeNode(val)
  if val < root.val
    root.left = insert(root.left, val)
  elif val > root.val
    root.right = insert(root.right, val)
  # If val == root.val, ignore (no duplicates in this BST)
  root

def generate_random_bst(n: int, seed: int?=none) -> TreeNode?
  if n <= 0
    return none
  if seed
    random.seed(seed)
  values = list(1..n)
  random.shuffle(values)
  reduce(insert, values, none)

def is_valid_bst(root: TreeNode?) -> bool
  vals = _inorder(root)
  all(a < b for a, b in zip(vals, vals[1:]))

def generate_and_print_random_bst(n: int, seed=none, verbose=true) -> TreeNode?
  ret root = generate_random_bst(n, seed)
  valid = is_valid_bst(root)
  assert valid
  if verbose
    draw_tree(root)
    print get_level_order(root)
    print("Valid BST:", valid)
