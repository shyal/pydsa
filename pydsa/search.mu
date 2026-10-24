import inspect
import shutil
import sys
from bisect import bisect_left
from typing import Callable

PAIRS = (("left", "right"), ("low", "high"), ("lo", "hi"))
TRUE_MARK = "[bold green]✓[/bold green]"
FALSE_MARK = "[bold red]✗[/bold red]"
MID_MARK = "[bold yellow]▼[/bold yellow]"
IN_RANGE = "[cyan]█[/cyan]"
DROPPED = "[dim]·[/dim]"

def _print(*args, **kwargs) -> none
  """rich's print, imported on the first traced step."""
  from rich import print
  print(*args, **kwargs)

def _ticks(lo, hi, width: int) -> str
  """One row of numbers spanning [lo, hi] over `width` columns."""
  span = hi - lo
  row = [" "] * width
  if span <= 0
    return (" " * (width // 2) + str(lo)).ljust(width)[:width]
  n = max(2, min(width // 10, 11))
  ints = isinstance(lo, int) and isinstance(hi, int) and span <= 20
  labels = []
  for v in ints ? lo..hi : [lo + span * i / (n - 1) for i in 0..<n]
    s = isinstance(lo, int) ? str(int(v)) : f"{v:.2f}"
    labels <- (min(int((v - lo) / span * (width - 1)), width - len(s)), s)
  placed = [labels[0], labels[-1]]
  for pos, s in labels[1:-1]
    if all(pos + len(s) < q or pos > q + len(t) for q, t in placed)
      placed <- (pos, s)
  for pos, s in placed
    for >i, ch in s
      row[pos + i] = ch
  "".join(row)

def _names(loc: dict) -> (str, str, str)?
  for a, b in PAIRS
    if a in loc and b in loc
      if "mid" in loc
        return a, b, "mid"
      lo, hi = loc[a], loc[b]
      if isinstance(lo, int) and isinstance(hi, int)
        mids = {(lo + hi) // 2, (lo + hi + 1) // 2}
        for k, v in loc.items()
          if k not in (a, b) and isinstance(v, int) and v in mids
            return a, b, k
      return none

def _record(calls: list, f: Callable, name: str) -> Callable
  def wrapped(*a, **k)
    r = f(*a, **k)
    calls <- (a ? a[0] : none, r, name)
    r
  wrapped

class _Viz
  def __init__(f: Callable, width: int) -> none
    self.f, self.width, self.step = f, width, 0
    self.lo0, self.span = none
    self.names: (str, str, str)? = none
    self.pending: tuple? = none
    self.calls: list = []

  def trace(frame, event: str, arg)
    if frame.f_code == self.f.__code__
      if event == "line"
        self.observe(frame.f_locals)
      return self.trace
    if frame.f_back is none or frame.f_back.f_code != self.f.__code__
      return none
    if event == "return" and self.pending is not none
      mid = self.pending[2]
      if any(v is mid for v in frame.f_locals.values())
        self.calls <- (mid, arg, frame.f_code.co_name)
    self.trace

  def observe(loc: dict) -> none
    self.names = self.names or _names(loc)
    if self.names is none or any(x not in loc for x in self.names)
      return
    lo, hi, mid = state = tuple(loc[x] for x in self.names)
    if lo > hi or abs(mid - (lo + hi) / 2) > 0.5 or state == self.pending
      return
    if self.pending is none
      self.lo0, self.span = lo, hi - lo
      _print(_ticks(lo, hi, self.width))
    else
      self.flush()
    self.pending = state

  def col(v) -> int
    if self.span <= 0
      return self.width // 2
    int((v - self.lo0) / self.span * (self.width - 1))

  def flush() -> none
    lo, hi, mid = self.pending
    hits = [(r, n) for x, r, n in self.calls if x == mid]
    verdict, name = hits ? hits[-1] : (none, "ok")
    self.calls.clear()
    self.step += 1
    mark = verdict is true ? TRUE_MARK : verdict is false ? FALSE_MARK : MID_MARK
    cl, cr, cm = self.col(lo), self.col(hi), self.col(mid)
    row = [c == cm ? mark : cl <= c <= cr ? IN_RANGE : DROPPED for c in 0..<self.width]
    a, b, m = self.names
    ok = verdict is none ? "" : f"  {name}({mid}) = {verdict}"
    _print("".join(row))
    _print(f"[dim]step {self.step:>2}[/dim]  [cyan]{a}={lo}[/cyan]  "
      f"[cyan]{b}={hi}[/cyan]  [yellow]{m}={mid}[/yellow]{ok}")

  def finish(result) -> none
    if self.pending is not none
      self.flush()
    if self.lo0 is none
      return
    c = isinstance(result, (int, float)) ? self.col(result) : none
    star = "[bold magenta]★[/bold magenta]"
    row = [i == c ? star : DROPPED for i in 0..<self.width]
    _print("".join(row))
    _print(f"[bold magenta]return {result!r}[/bold magenta]")

def viz_binary_search(func: Callable?=none, width: int?=none)
  """Trace a binary search: one bar per step, mid marked ✓/✗ by ok(mid)."""
  width = width or min(100, shutil.get_terminal_size().columns) if none
  def decorator(f: Callable) -> Callable
    def wrapper(*args, **kwargs)
      viz = _Viz(f, width)
      bound = inspect.signature(f).bind(*args, **kwargs)
      for name, v in bound.arguments.items()
        if callable(v)
          bound.arguments[name] = _record(viz.calls, v, name)
      args, kwargs = bound.args, bound.kwargs
      old = sys.gettrace()
      sys.settrace(viz.trace)
      try
        result = f(*args, **kwargs)
      finally
        sys.settrace(old)
      viz.finish(result)
      result
    wrapper
  callable(func) ? decorator(func) : decorator

def first_true(lo: int, hi: int, ok: int -> bool) -> int
  """Smallest x in [lo, hi] with ok(x) True; ok is False then True.

  Returns hi + 1 when ok is False on the whole range."""
  lo + bisect_left(range(lo, hi + 1), true, key=ok)

def last_true(lo: int, hi: int, ok: int -> bool) -> int
  """Largest x in [lo, hi] with ok(x) True; ok is True then False.

  Returns lo - 1 when ok is False on the whole range."""
  first_false(lo, hi, ok) - 1

def first_false(lo: int, hi: int, ok: int -> bool) -> int
  """Smallest x in [lo, hi] with ok(x) False; ok is True then False.

  Returns hi + 1 when ok is True on the whole range."""
  first x in lo..hi if not ok(x)

def last_false(lo: int, hi: int, ok: int -> bool) -> int
  """Largest x in [lo, hi] with ok(x) False; ok is False then True.

  Returns lo - 1 when ok is True on the whole range."""
  first_true(lo, hi, ok) - 1

def min_chunks(nums: [int], cap: int) -> float
  """Fewest contiguous chunks of nums with every chunk summing to at most cap.

  Greedy: extend the current chunk while it fits, cut when the next number
  would push it past cap. Returns inf when a single number exceeds cap."""
  ret chunks, total = 1, 0
  for n in nums
    if n > cap
      return inf
    if total + n > cap
      chunks, total = chunks + 1, n
    else
      total += n
