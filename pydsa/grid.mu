"""Grid helpers preloaded by sitecustomize: scan a grid, list a cell's
in-bounds neighbours, test for and list the border cells, build a table
by shape or by size, read a grid's shape, write one value or a stream of
values into many cells, read or set a row or a column, multi-source BFS."""

from collections import deque
from itertools import repeat
from typing import Any, Iterable, Iterator, List, Sequence, Tuple

Cell = Tuple[int, int]
CARDINALS: Tuple[Cell, ...] = ((-1, 0), (0, -1), (0, 1), (1, 0))
DIAGONALS: Tuple[Cell, ...] = ((-1, -1), (-1, 1), (1, -1), (1, 1))
ALL_EIGHT: Tuple[Cell, ...] = CARDINALS + DIAGONALS

def _holds(v, eq=none, lt=none, lte=none, gt=none, gte=none) -> bool
  """True if v passes every comparison given: v == eq, v < lt, v <= lte,
  v > gt, v >= gte. A comparison left as None is not tested."""
  ((eq is none or v == eq) and (lt is none or v < lt) and (lte is none or v <= lte)
    and (gt is none or v > gt) and (gte is none or v >= gte))

def cells(
  grid: Sequence[Sequence[Any]], start: int=0, eq=none, lt=none, lte=none, gt=none, gte=none
) -> Iterator[Cell]
  """Every (i, j) of grid with i >= start and j >= start, in row-major order.
  With eq, lt, lte, gt or gte, only the cells whose value passes them all
  (see _holds)."""
  for i in start..<len grid
    for j in start..<len grid[0]
      if _holds(grid[i][j], eq, lt, lte, gt, gte)
        yield i, j

def nbrs(
  grid: Sequence[Sequence[Any]], r, c: int?=none, dirs: Sequence[Cell]=CARDINALS,
  eq=none, lt=none, lte=none, gt=none, gte=none
) -> Iterator[Cell]
  """The cells (r + dr, c + dc) for (dr, dc) in dirs that lie on grid.
  nbrs(grid, p) takes the cell as one pair. With eq, lt, lte, gt or gte,
  only the cells whose value passes them all (see _holds)."""
  if c is none
    r, c = r
  for dr, dc in dirs
    nr, nc = r + dr, c + dc
    if in_bounds(grid, nr, nc) and _holds(grid[nr][nc], eq, lt, lte, gt, gte)
      yield nr, nc

def in_bounds(grid: Sequence[Sequence[Any]], r, c: int?=none) -> bool
  """True if (r, c) is a cell of grid. in_bounds(grid, p) takes the cell as
  one pair."""
  if c is none
    r, c = r
  0 <= r < len grid and 0 <= c < len grid[0]

def is_edge(grid: Sequence[Sequence[Any]], r, c: int?=none) -> bool
  """True if (r, c) lies on the border of grid. is_edge(grid, p) takes the
  cell as one pair."""
  if c is none
    r, c = r
  r == 0 or c == 0 or r == len grid - 1 or c == len grid[0] - 1

def edges(
  grid: Sequence[Sequence[Any]], eq=none, lt=none, lte=none, gt=none, gte=none
) -> Iterator[Cell]
  """Every (i, j) on the border of grid, each once, in row-major order.
  With eq, lt, lte, gt or gte, only the cells whose value passes them all
  (see _holds)."""
  for i, j in cells(grid, eq=eq, lt=lt, lte=lte, gt=gt, gte=gte)
    if is_edge(grid, i, j)
      yield i, j

def table(*dims: int, fill=0) -> list
  """A new table of the given dimensions, every cell set to fill.

  table(n) is a list of n cells; table(m, n) is m rows of n cells, the
  rows distinct lists; table(l, m, n) nests one level deeper."""
  len dims == 1 ? [fill] * dims[0] : [table(*dims[1:], fill=fill) for _ in 0..<dims[0]]

def like(grid: Sequence[Sequence[Any]], fill=0) -> [list]
  table(len grid, len grid[0], fill=fill)

def shape(*seqs, last_index: bool=false) -> Tuple[int, ...]
  """The sizes of a nested list, or of several sequences side by side.

  shape(grid) follows grid[0] down while it is a list: (rows, cols, ...).
  shape(a, b) is (len(a), len(b)). With last_index, every size less one:
  the index of the last cell."""
  dims = [len(s) for s in seqs]
  if len seqs == 1
    x = seqs[0]
    while dims[-1] and isinstance(x[0], list)
      x = x[0]
      dims <- len x
  last_index ? tuple(d - 1 for d in dims) : tuple(dims)

def _spread(v) -> Iterator
  """v itself forever if it is one value, else v's items in order."""
  isinstance(v, str) or not isinstance(v, Iterable) ? repeat(v) : iter(v)

def put(grid: List[List[Any]], at: Iterable[Cell], v) -> none
  """Set `grid[i][j] = v` for every (i, j) in at.

  v is one value, or an iterable read once per cell in the order of at:
  put(dp, cells(dp), accumulate(...))."""
  for (i, j), x in zip(at, _spread(v))
    grid[i][j] = x

def row(grid: Sequence[Sequence[Any]], i: int) -> list
  """A copy of row i."""
  list(grid[i])

def col(grid: Sequence[Sequence[Any]], j: int) -> list
  """A copy of column j, top to bottom."""
  [r[j] for r in grid]

def set_row(grid: List[List[Any]], i: int, v) -> none
  """Set every cell of row i to v, one value or an iterable read left to right."""
  put(grid, ((i, j) for >j in grid[i]), v)

def set_col(grid: List[List[Any]], j: int, v) -> none
  """Set every cell of column j to v, one value or an iterable read top to bottom."""
  put(grid, ((i, j) for >i in grid), v)

def grid_bfs(
  grid: Sequence[Sequence[Any]], sources: Sequence[Cell] | Cell, dirs: Sequence[Cell]=CARDINALS,
  eq=none, lt=none, lte=none, gt=none, gte=none
) -> [[int]]
  """Steps from the nearest source to every cell; -1 where none reaches.

  sources is a list of cells, or one cell. With eq, lt, lte, gt or gte,
  only the cells whose value passes them all are entered (see _holds).
  Sources are entered unconditionally at distance 0.
  """
  if sources and isinstance(sources[0], int)
    sources = [sources]
  ret dist = like(grid, -1)
  q = deque(sources)
  for r, c in sources
    dist[r][c] = 0
  while q
    r, c = q.popleft()
    for nr, nc in nbrs(grid, r, c, dirs, eq=eq, lt=lt, lte=lte, gt=gt, gte=gte)
      if dist[nr][nc] == -1
        dist[nr][nc] = dist[r][c] + 1
        q <- (nr, nc)

class Grid extends list
  """A list of rows that also takes a (row, col) pair as an index."""

  def __getitem__(k)
    type(k) is tuple ? list.__getitem__(self, k[0])[k[1]] : list.__getitem__(self, k)

  def __setitem__(k, v) -> none
    if type(k) is tuple
      list.__getitem__(self, k[0])[k[1]] = v
    else
      list.__setitem__(self, k, v)
