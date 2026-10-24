"""pydsa: data structures and algorithm helpers for LeetCode-style Python.

Every public name of every module is importable from the package. The
modules are written in mu (pydsa/<name>.mu, with no .py): pydsa._mu
imports them through mu, which writes their Python into __pycache__ (see
pydsa/_mu.py). Past that, the package imports only the standard library;
the drawing functions import rich, colorama, PrettyPrintTree, graphviz,
tabulate, networkx and phart when first called
(`pip install 'pizza-lib[draw]'`).
"""

from . import _mu  # noqa: F401  (imports the modules written in mu)
from .adj import *  # noqa: F401,F403
from .arith import *  # noqa: F401,F403
from .bst import *  # noqa: F401,F403
from .combo import *  # noqa: F401,F403
from .counting import *  # noqa: F401,F403
from .digits import *  # noqa: F401,F403
from .generators import *  # noqa: F401,F403
from .graphs import *  # noqa: F401,F403
from .grid import *  # noqa: F401,F403
from .heaps import *  # noqa: F401,F403
from .linked import *  # noqa: F401,F403
from .nodes import *  # noqa: F401,F403
from .search import *  # noqa: F401,F403
from .seq import *  # noqa: F401,F403
from .tree import *  # noqa: F401,F403

__version__ = "0.4.0"
