from collections import defaultdict
from heapq import heappop, heappush
from typing import Any, Deque, Iterator

from .grid import _holds, table

def adjacency(
  edges: list, n: int?=none, reverse: bool=false, directed: bool=true,
  weighted: bool=false
)
  """Adjacency from an edge list. Each edge is [a, b] or, with weighted,
  [a, b, w]. Unweighted returns a dict of lists in edge order; weighted a
  dict of dicts, `adj[a][b] = w`. With n, nodes 0 to n - 1 are all keys,
  isolated ones with an empty list. reverse reads each edge as b to a.
  directed=False adds both directions."""
  ret adj = weighted ? {:dict} : {:list}
  for c in 0..<(n or 0)
    adj[c]
  for e in edges
    a, b = e[:2]
    if reverse
      a, b = b, a
    if weighted
      adj[a][b] = e[2]
      if not directed
        adj[b][a] = e[2]
    else
      adj[a] <- b
      if not directed
        adj[b] <- a

def indegrees(
  edges: list, n: int?=none, reverse: bool=false, directed: bool=true, type=defaultdict
)
  """In-degree of every node from an edge list, each edge [a, b] counting
  one into b. Default is a defaultdict(int), any node reading 0; with n,
  nodes 0 to n - 1 are all keys. type=list needs n and returns a plain
  list. reverse reads each edge as b to a. directed=False counts the edge
  into a as well, so the result is the plain degree of every node."""
  if type is list and n is none
    raise ValueError("type=list needs n")
  ret indeg = type is list ? table(n) : defaultdict(int, dict.fromkeys(0..<(n or 0), 0))
  for e in edges
    a, b = e[:2]
    if reverse
      a, b = b, a
    indeg[b] += 1
    if not directed
      indeg[a] += 1

def levels(
  q: Deque, grid=none, seen: set?=none, grouped: bool=false,
  eq=none, lt=none, lte=none, gt=none, gte=none
) -> Iterator[(int, Any)]
  """Level-order BFS over a deque the caller keeps pushing onto.

  Yields (d, item) for every item popped, where d is the level the item
  was pushed at, starting from 0 for the items already in q. The caller
  appends the next level's items to q inside the loop body. With grouped=True
  yields (d, items) once per level, items being the whole level as a list.

  Every popped item is checked before it is yielded. With eq, lt, lte, gt or
  gte, an item whose value fails one of them is dropped; the value is
  `grid[item[0]][item[1]]` when grid is given, else the item itself. With
  seen, an item already in seen is dropped and a kept item is added to it,
  so the caller can push without checking.
  """
  def keep(x) -> bool
    v = grid is none ? x : grid[x[0]][x[1]]
    if not _holds(v, eq, lt, lte, gt, gte) or (seen is not none and x in seen)
      return false
    if seen is not none
      seen.add(x)
    true

  d = 0
  while q
    popped = (q.popleft() for _ in 0..<len q)
    if grouped
      if level := [x for x in popped if keep(x)]
        yield d, level
    else
      for x in popped
        if keep(x)
          yield d, x
    d += 1

def components(vertices, edges)
  """The connected components of a graph given as its vertices and a
  function edges(u) listing u's neighbours, each as a list of vertices."""
  ret out, left = [], set(vertices)
  while left
    stack, comp = [left.pop()], []
    while stack
      u = stack .
      comp <- u
      for v in edges(u)
        if v in left
          left.remove(v)
          stack <- v
    out <- comp

class Graph
  """Vertices and weighted adjacency lists, adj[u] = [(v, w), ...]. An
  edge (u, v) weighs 1; an edge (u, v, w) weighs w."""

  def __init__(vertices, edges, directed=false)
    self.vertices = list(vertices)
    self.adj = {u: [] for u in self.vertices}
    for e in edges
      u, v, w = len(e) == 3 ? e : (*e, 1)
      self.adj[u] <- (v, w)
      if not directed
        self.adj[v] <- (u, w)

def graph(vertices, edges, directed=false): Graph(vertices, edges, directed)

def dijkstra(g, src)
  """Shortest distance from src to every vertex of g, inf when unreachable."""
  ret dist = {u: inf for u in g.vertices}
  dist[src] = 0
  pq = [(0, src)]
  while pq
    d, u = heappop(pq)
    if d > dist[u]
      continue
    for v, w in g.adj[u]
      if d + w < dist[v]
        dist[v] = d + w
        heappush(pq, (d + w, v))
