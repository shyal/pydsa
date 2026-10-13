from collections import defaultdict
from heapq import heappop, heappush
from math import inf
from typing import Any, Deque, Iterator, List, Optional, Set, Tuple

from .grid import _holds, table


def adjacency(
    edges: List[Any],
    n: Optional[int] = None,
    reverse: bool = False,
    directed: bool = True,
    weighted: bool = False,
) -> Any:
    """Adjacency from an edge list. Each edge is [a, b] or, with weighted,
    [a, b, w]. Unweighted returns a dict of lists in edge order; weighted a
    dict of dicts, adj[a][b] = w. With n, nodes 0 to n - 1 are all keys,
    isolated ones with an empty list. reverse reads each edge as b to a.
    directed=False adds both directions."""
    adj: Any = defaultdict(dict) if weighted else defaultdict(list)
    for c in range(n or 0):
        adj[c]
    for e in edges:
        a, b = e[:2]
        if reverse:
            a, b = b, a
        if weighted:
            adj[a][b] = e[2]
            if not directed:
                adj[b][a] = e[2]
        else:
            adj[a].append(b)
            if not directed:
                adj[b].append(a)
    return adj


def indegrees(
    edges: List[Any],
    n: Optional[int] = None,
    reverse: bool = False,
    directed: bool = True,
    type: Any = defaultdict,
) -> Any:
    """In-degree of every node from an edge list, each edge [a, b] counting
    one into b. Default is a defaultdict(int), any node reading 0; with n,
    nodes 0 to n - 1 are all keys. type=list needs n and returns a plain
    list. reverse reads each edge as b to a. directed=False counts the edge
    into a as well, so the result is the plain degree of every node."""
    indeg: Any
    if type is list:
        if n is None:
            raise ValueError("type=list needs n")
        indeg = table(n)
    else:
        indeg = defaultdict(int)
        for c in range(n or 0):
            indeg[c]
    for e in edges:
        a, b = e[:2]
        if reverse:
            a, b = b, a
        indeg[b] += 1
        if not directed:
            indeg[a] += 1
    return indeg


def levels(
    q: Deque[Any],
    grid: Optional[Any] = None,
    seen: Optional[Set[Any]] = None,
    grouped: bool = False,
    eq: Any = None,
    lt: Any = None,
    lte: Any = None,
    gt: Any = None,
    gte: Any = None,
) -> Iterator[Tuple[int, Any]]:
    """Level-order BFS over a deque the caller keeps pushing onto.

    Yields (d, item) for every item popped, where d is the level the item
    was pushed at, starting from 0 for the items already in q. The caller
    appends the next level's items to q inside the loop body. With grouped=True
    yields (d, items) once per level, items being the whole level as a list.

    Every popped item is checked before it is yielded. With eq, lt, lte, gt or
    gte, an item whose value fails one of them is dropped; the value is
    grid[item[0]][item[1]] when grid is given, else the item itself. With
    seen, an item already in seen is dropped and a kept item is added to it,
    so the caller can push without checking.
    """

    def keep(x: Any) -> bool:
        v = x if grid is None else grid[x[0]][x[1]]
        if not _holds(v, eq, lt, lte, gt, gte) or (seen is not None and x in seen):
            return False
        if seen is not None:
            seen.add(x)
        return True

    d = 0
    while q:
        popped = (q.popleft() for _ in range(len(q)))
        if grouped:
            level = [x for x in popped if keep(x)]
            if level:
                yield d, level
        else:
            for x in popped:
                if keep(x):
                    yield d, x
        d += 1


def components(vertices, edges):
    """The connected components of a graph given as its vertices and a
    function edges(u) listing u's neighbours, each as a list of vertices."""
    left, out = set(vertices), []
    while left:
        stack, comp = [left.pop()], []
        while stack:
            u = stack.pop()
            comp.append(u)
            for v in edges(u):
                if v in left:
                    left.remove(v)
                    stack.append(v)
        out.append(comp)
    return out


class Graph:
    """Vertices and weighted adjacency lists, adj[u] = [(v, w), ...]. An
    edge (u, v) weighs 1; an edge (u, v, w) weighs w."""

    def __init__(self, vertices, edges, directed=False):
        self.vertices = list(vertices)
        self.adj = {u: [] for u in self.vertices}
        for e in edges:
            u, v, w = e if len(e) == 3 else (*e, 1)
            self.adj[u].append((v, w))
            if not directed:
                self.adj[v].append((u, w))


def graph(vertices, edges, directed=False):
    """A Graph of these vertices and edges."""
    return Graph(vertices, edges, directed)


def dijkstra(g, src):
    """Shortest distance from src to every vertex of g, inf when unreachable."""
    dist = {u: inf for u in g.vertices}
    dist[src] = 0
    pq = [(0, src)]
    while pq:
        d, u = heappop(pq)
        if d > dist[u]:
            continue
        for v, w in g.adj[u]:
            if d + w < dist[v]:
                dist[v] = d + w
                heappush(pq, (d + w, v))
    return dist
