from itertools import accumulate
from typing import Any, Callable, Iterable, List, Optional, Sequence

from .grid import cells, table


def lcs(a: Sequence[Any], b: Sequence[Any], full: bool = False, type: Any = int) -> Any:
    """Longest common subsequence of a and b.

    Row i and column j of the table stand for the prefixes a[:i] and b[:j],
    so row 0 and column 0 are the empty prefix. With type=int (the default)
    each cell holds the length; with type=str, list or tuple it holds one
    LCS itself, built as that type. Plain lcs(a, b) is the last cell,
    `dp[-1][-1]`; full returns the whole table."""
    dp = table(len(a) + 1, len(b) + 1, fill=type())
    for i, j in cells(dp, start=1):
        x = a[i - 1]
        if x == b[j - 1]:
            one = 1 if type is int else x if type is str else type([x])
            dp[i][j] = dp[i - 1][j - 1] + one
        else:
            dp[i][j] = max(dp[i - 1][j], dp[i][j - 1], key=None if type is int else len)
    return dp if full else dp[-1][-1]


def max_diff(
    xs: Iterable[Any],
    by: Optional[Callable[[Any], Any]] = None,
    reverse: bool = False,
) -> List[Any]:
    """The largest by(xs[j]) - by(xs[i]) with i < j, so far, for each j
    from 1: one value per index after the first.

    by(x) is the value compared; with by left out it is x itself. reverse
    flips the difference to by(xs[i]) - by(xs[j]): the largest fall, not
    the largest rise.

    >>> max_diff([12, 6, 1, 2, 7])
    [-6, -5, 1, 6]
    >>> max_diff([12, 6, 1, 2, 7], reverse=True)
    [6, 11, 11, 11]
    >>> max([0, *max_diff([7, 6, 4, 3, 1])])
    0
    """
    ys = [x if by is None else by(x) for x in xs]
    if reverse:
        ys = [-y for y in ys]
    lows = accumulate(ys, min)
    return list(accumulate((y - lo for y, lo in zip(ys[1:], lows)), max))
