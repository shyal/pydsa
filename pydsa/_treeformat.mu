from typing import Any, Generic, Iterable, Optional, TypeVar

from PrettyPrint.PrintTree.HorizontalTree import add_parent as add_parent_left
from PrettyPrint.PrintTree.HorizontalTree import join_vertically
from PrettyPrint.PrintTree.VerticalTree import add_parent as add_parent_top
from PrettyPrint.PrintTree.VerticalTree import join_horizontally
from PrettyPrint.Utils.NodeFormatter import NodeFormatter
from PrettyPrint.Utils.Orientation import Orientation
from PrettyPrint.Utils.StyleAwareUtils import trim_text

RED, BLUE, RESET = "\033[31m", "\033[34m", "\033[0m"
T = TypeVar("T")
_Generic = Generic[T]  # mu writes no subscript after extends

def _is_left(tree_node: T, child: T) -> bool
  """get_children may omit None, so the side of a lone child comes from
  tree_node.left and tree_node.right. A child that is neither counts as left."""
  left = getattr(tree_node, "left", object())
  right = getattr(tree_node, "right", object())
  child is left or child is not right

class TreeFormatter extends _Generic
  def __init__(
    get_children: T -> Iterable[T], get_val: T -> Any, get_label: Optional[T -> Any],
    label_color: str, show_newline_literal: bool, newline_literal: str,
    trim: int, trim_symbol: str, start_message: Optional[T -> str],
    color: str, border: bool, max_depth: int, orientation: bool
  )
    self.get_children = get_children
    self.get_node_val = get_val
    self.get_label = get_label
    self.label_color = label_color
    self.trim = trim
    self.trim_symbol = trim_symbol
    self.show_newline = show_newline_literal
    self.newline_literal = newline_literal
    self.start_message = start_message
    self.color = color
    self.border = border
    self.max_depth = max_depth
    self.orientation = orientation

  def format(node: T) -> str
    vertical = self.orientation == Orientation.Vertical
    join = vertical ? self.tree_vertical_join : self.tree_horizontal_join
    res = join(node).to_str().rstrip()
    self.start_message ? f"{self.start_message(node)}\n{res}" : res

  def tree_vertical_join(tree_node: T, depth: int=0) -> NodeFormatter
    label = self.get_label ? self.get_label(tree_node) : none
    children = list(self.get_children(tree_node))
    node = self.add_styles(tree_node)
    if children and (self.max_depth == -1 or depth < self.max_depth)
      if len(children) == 1
        edge = _is_left(tree_node, children[0]) ? f"{RED}/{RESET}" : f"{BLUE}\\{RESET}"
        box = self.tree_vertical_join(children[0], depth + 1)
        box.lines.insert(0, " " * box.get_middle_width() + edge)
      else
        # a loop: before Python 3.12 a comprehension adds a frame per level
        boxes = []
        for child in children
          boxes <- self.tree_vertical_join(child, depth + 1)
        box = join_horizontally(boxes)
      node = add_parent_top(node, box)
    self.add_label(label, node, add_parent_top, "|")

  def tree_horizontal_join(tree_node: T, depth: int=0) -> NodeFormatter
    label = self.get_label ? self.get_label(tree_node) : none
    children = list(self.get_children(tree_node))
    node = self.add_styles(tree_node)
    node.lines = node.lines + [" " * node.width]
    node.height += 1
    if children and (self.max_depth == -1 or depth < self.max_depth)
      if len(children) == 1
        edge = (_is_left(tree_node, children[0]) ? RED : BLUE) + "─" + RESET
        box = self.tree_horizontal_join(children[0], depth + 1)
        middle = box.get_middle_height()
        box.lines = [(i == middle ? edge : " ") + line for >i, line in box.lines]
      else
        # a loop: before Python 3.12 a comprehension adds a frame per level
        boxes = []
        for child in children
          boxes <- self.tree_horizontal_join(child, depth + 1)
        box = join_vertically(boxes)
      node = add_parent_left(node, box)
    self.add_label(label, node, add_parent_left, "─")

  def add_label(
    label, node: NodeFormatter,
    parent_adder: (NodeFormatter, NodeFormatter) -> NodeFormatter, seperator: str
  ) -> NodeFormatter
    if not label
      return node
    label = NodeFormatter.from_string(str(label))
    if self.label_color
      label.color_bg(self.label_color, true)
    parent_adder(label, parent_adder(NodeFormatter.from_string(seperator), node))

  def add_styles(tree_node: T) -> NodeFormatter
    contents = str(self.get_node_val(tree_node))
    if self.show_newline
      contents = contents.replace("\n", self.newline_literal)
    if self.trim != -1
      contents = trim_text(contents, self.trim, self.trim_symbol)
    node = NodeFormatter.from_string(contents)
    if self.border
      node.add_border()
    if self.color
      node.color_bg(self.color, add_space=not self.border)
    node
