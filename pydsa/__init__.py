"""pydsa: data structures and algorithm helpers for LeetCode-style Python.

Every public name of every module is importable from the package. The
package imports only the standard library; the drawing functions import
rich, colorama, PrettyPrintTree and graphviz when first called
(`pip install pydsa[draw]`).
"""

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

__version__ = "0.2.0"
