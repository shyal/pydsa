import hashlib
import json
import os
import re
from collections import deque
from typing import Any, List

from .nodes import GraphNode

def draw_graph(G: {Any: dict | Any}) -> none
  """
  Utility function to draw a graph (stored as dict of dicts, dict of lists, or dict with (row, col) tuples as keys) in the terminal as a colored adjacency matrix.
  Requires 'tabulate' library: pip install tabulate
  For colors, requires 'colorama': pip install colorama
  Colors edges based on values (e.g., 1 in red, 0 in blue).
  Assumes nodes are comparable for sorting.
  """
  G = as_dict_of_dicts(is_edge_list(G) ? build_graph_from_edge_list(G) : G)
  try
    from tabulate import tabulate
  except ImportError
    print "Please install tabulate: pip install tabulate"
    return
  try
    import colorama
  except ImportError
    print "Please install colorama: pip install colorama"
    return
  if not G
    print "Empty graph"
    return
  print "\n"
  first_key = next(iter(G))
  is_tuple_key = isinstance(first_key, tuple) and len(first_key) == 2
  if is_tuple_key
    all_nodes = {node for src, dst in G for node in (src, dst)}
  else
    all_nodes = set(G.keys())
    for neighbors in G.values()
      all_nodes.update(neighbors.keys())
  nodes = sort(all_nodes)
  headers = [str(node) for node in nodes]
  table = []
  for src in nodes
    row = []
    for dst in nodes
      if is_tuple_key
        val = (src, dst) in G ? G[(src, dst)] : none
      else
        val = src in G and dst in G[src] ? G[src][dst] : none
      row <- val is none ? "" : _cell(val)
    table <- row
  print(tabulate(table, headers=headers, tablefmt="grid", showindex=headers,
    numalign="center", stralign="center"))

def build_graph_from_edge_list(edges, directed: bool=false)
  """A dict of dicts from an edge list, every edge weighted 0. directed
  adds each edge one way only, as adjacency does."""
  ret G = {:dict}
  for u, v in edges
    G[u][v] = 0
    if not directed
      G[v][u] = 0

def as_dict_of_dicts(G)
  """Accept a dict of lists (or tuples or sets) as well as a dict of dicts.

  Also accept a dict of scalars (each key has one neighbor, its value)
  and a list of ints (a parent array: index i has one neighbor
  parent[i]). A self loop, parent[i] == i, draws as a node with no
  outgoing edge."""
  if isinstance(G, list) and all(isinstance(v, int) for v in G)
    G = dict(enumerate(G))
  if not isinstance(G, dict)
    return G
  ret out = {}
  for k, v in G.items()
    if isinstance(v, dict)
      out[k] = v
    elif isinstance(v, (list, tuple, set))
      out[k] = _labelled_neighbors(v)
    else
      out[k] = v == k ? {} : {v: 1}

def _labelled_neighbors(nbrs) -> dict
  """A neighbour list holds ints, or tuples whose first element is the
  neighbour and the rest its label: (b, w) for a weight, (b, "red") for
  a colour, (b, w, idx) for several. Two tuples to the same neighbour
  (parallel edges) collect their labels in a list."""
  ret out = {}
  for item in nbrs
    if isinstance(item, (list, tuple)) and len(item) >= 2
      dst, label = item[0], len(item) == 2 ? item[1] : tuple(item[1:])
    else
      dst, label = item, 1
    if dst in out
      label = (isinstance(out[dst], list) ? out[dst] : [out[dst]]) + [label]
    out[dst] = label

_COLOURS = ("red", "blue", "green", "yellow", "magenta", "cyan", "white", "black")

def _edge_colour(label) -> str?
  if isinstance(label, str) and label.lower() in _COLOURS
    return label.lower()
  label == 1 ? "red" : label == 0 ? "blue" : none

def _cell(val) -> str
  """Render one adjacency-matrix cell: colour names in their colour,
  tuple labels space-joined, parallel edges one per line."""
  from colorama import Fore, Style
  if isinstance(val, list)
    return "\n".join(_cell(v) for v in val)
  if isinstance(val, tuple)
    return " ".join(_cell(v) for v in val)
  colour = _edge_colour(val)
  colour is none ? str(val) : getattr(Fore, colour.upper()) + str(val) + Style.RESET_ALL

def is_edge_list(edges)
  type(edges) is list and all(len(x) == 2 and type(x) is list for x in edges)

def _items(nbrs)
  if isinstance(nbrs, dict)
    nbrs.items()
  elif isinstance(nbrs, (list, tuple, set))
    [(dst, none) for dst in nbrs]
  else
    raise ValueError("Invalid graph format")

def draw_graphviz(
  G: {Any: dict | list}, png_filename: str?=none, n=none, directed: bool=false,
  show_weights: bool=false
) -> none
  if os.environ.get("RUNNING_TESTS") == "True"
    return
  G = as_dict_of_dicts(is_edge_list(G) ? build_graph_from_edge_list(G, directed) : G)
  if png_filename is none
    # Compute deterministic hash for caching; shorten hash for filename
    sorted_G = {
      str(k): sort([(str(dst), weight) for dst, weight in _items(v)], by=x -> x[0])
      for k, v in sort(G.items(), by=x -> str(x[0]))
    }
    serialized = json.dumps({"G": sorted_G, "n": n}, sort_keys=true).encode()
    png_filename = f"/tmp/graph_{hashlib.sha256(serialized).hexdigest()[:16]}.png"
  try
    from graphviz import Digraph, Graph
  except ImportError
    print "Please install graphviz: pip install graphviz"
    return
  if not G
    print "Empty graph"
    return
  print "\n"
  all_nodes = set(G.keys())
  edges = [(src, dst, weight) for src in G for dst, weight in _items(G[src])]
  all_nodes.update(dst for _, dst, _ in edges)
  if n is not none
    all_nodes.update(range(n))
  dot = (directed ? Digraph : Graph)(comment="The Graph")
  dot.attr(rankdir="TB")
  dot.attr(bgcolor="transparent")
  dot.node_attr.update(style="filled", fillcolor="transparent", color="white",
    fontcolor="white")
  dot.edge_attr.update(color="blue", fontcolor="white")
  for node in sort(all_nodes, by=str)  # Sort for consistent order
    dot.node(str(node))
  for src, dst, weight in edges
    for one in (isinstance(weight, list) ? weight : [weight])
      dot.edge(str(src), str(dst), **_edge_attrs(one, show_weights))
  try
    print dot.pipe(format="ascii", encoding="utf-8")
  except Exception
    try
      base_name = png_filename[:-4]
      if not os.path.exists(png_filename)
        dot.render(base_name, format="png", cleanup=true, view=false)
      if os.system(f"timg {png_filename}") != 0
        raise RuntimeError("timg failed to run (is it installed?)")
    except Exception as e
      print f"Failed to render/display PNG: {e}"
      print f"\nDOT source:\n\n{dot.source}"

def _edge_attrs(weight, show_weights: bool) -> {str: str}
  """Graphviz attributes for one edge label: a colour name (or 0/1)
  colours the arrow, anything else becomes the arrow's text."""
  ret attrs = {}
  if weight is none
    return
  text = []
  for part in (isinstance(weight, tuple) ? weight : (weight,))
    colour = _edge_colour(part)
    if colour is not none and "color" not in attrs
      attrs["color"] = colour
      if not show_weights and not isinstance(part, str)
        continue
    text <- str(part)
  if text
    attrs["label"] = " ".join(text)

def _colorize_ascii_graph(text: str) -> str
  """Nodes [x] in bold cyan, edge glyphs in yellow."""
  from colorama import Fore, Style
  node = re.compile(r"\[[^\]]*\]")
  edge = re.compile(r"[→←↑↓↕↔─│┌┐└┘┤├┬┴┼+|\-]+")
  cyan = m -> Style.BRIGHT + Fore.CYAN + m.group() + Style.RESET_ALL
  yellow = m -> Fore.YELLOW + m.group() + Style.RESET_ALL
  # nodes first: edges first would re-match the "[" of the escape codes
  "\n".join(edge.sub(yellow, node.sub(cyan, line)) for line in text.splitlines())

def _image_terminal() -> bool
  import shutil
  import sys
  (sys.stdout.isatty() and os.environ.get("TERM_PROGRAM") == "iTerm.app"
    and shutil.which("timg") is not none)

def _symmetric(G: {Any: dict}) -> bool
  """Every edge u->v has a v->u: draw it undirected."""
  all(src in G.get(dst, {}) for src in G for dst in G[src])

def draw_ascii_graph(graph: {Any: dict | list}) -> none
  """
  Utility function to draw a graph (stored as dict of dicts or dict of lists) in the terminal using PHART for ASCII rendering.
  Requires 'networkx' and 'phart' libraries: pip install networkx phart
  Supports directed graphs. Edge weights (like 0/1) are ignored in rendering but structure is shown.
  """
  G: {Any: dict} = as_dict_of_dicts(graph)
  if not G
    print "Empty graph"
    return
  # An image terminal gets a graphviz layout: phart puts every node on
  # one row and routes edges through the others, which is unreadable
  # past a handful of edges.
  if _image_terminal()
    draw_graphviz(graph, directed=not _symmetric(G))
    return
  # imported here: networkx costs ~50ms and every interpreter start pays
  # for sitecustomize's imports
  try
    import networkx as nx
    from phart import ASCIIRenderer
  except ImportError
    print "Please install networkx and phart: pip install networkx phart"
    return
  print "\n"
  nx_graph = nx.DiGraph()
  all_nodes = set(G.keys())
  for neighbors in G.values()
    all_nodes.update(neighbors.keys())
  nx_graph.add_nodes_from(all_nodes)
  # Add edges, ignoring weights for now (PHART doesn't support labels)
  nx_graph.add_edges_from((src, dst) for src in G for dst in G[src])
  try
    print _colorize_ascii_graph(ASCIIRenderer(nx_graph).render())
  except Exception as e
    print f"Failed to render with PHART: {e}"
    print "Fallback: Adjacency list"
    for src in sort(G)
      shown = [f"{dst}({G[src][dst]})" for dst in sort(G[src])]
      print f"{src}: {', '.join(shown)}"

def build_graph(adj: List[List[int]]) -> GraphNode?
  if not adj
    return none
  nodes = [GraphNode(i) for i in 1..len adj]
  for >i in adj
    for nb in adj[i]
      nodes[i].neighbors <- nodes[nb - 1]
  nodes[0]

def get_adj_list(node: GraphNode?) -> [[int]]
  if not node
    return []
  node_map, max_val = {}, 0
  queue, visited = deque([node]), {node}
  while queue
    cur = queue.popleft()
    node_map[cur.val] = cur
    max_val = max(max_val, cur.val)
    for nb in cur.neighbors
      if nb not in visited
        visited.add(nb)
        queue <- nb
  nodes = map(node_map.get, 1..max_val)
  [sort([nb.val for nb in cur.neighbors]) for cur in nodes if cur]
