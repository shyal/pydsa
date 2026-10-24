"""MkDocs hook: README.md gives each solve as a code block, then other
versions of the same solve, each folded in <details><summary>Label</summary>,
so GitHub shows them on a click. On the docs site the versions become tabs
of the solve. The first block, the unfolded one, is the first tab: mu +
pydsa on both sites."""

import importlib
import re
import shutil
import sys
from functools import partial
from pathlib import Path

from markdown import Extension
from mkdocs.plugins import event_priority
from markdown.preprocessors import Preprocessor

FENCE = r"```\w*\n(?:(?!```).*\n)*```"
FOLD = rf"\n\n<details><summary>(.+)</summary>\n\n({FENCE})\n\n</details>"
SOLVE = re.compile(rf"^({FENCE})((?:{FOLD})+)$", re.M)


def indent(block):
    return "\n".join("    " + line if line else line for line in block.split("\n"))


def tabs(first, m):
    parts = [f'===! "{first}"\n\n{indent(m.group(1))}']
    parts += [
        f'=== "{name}"\n\n{indent(block)}'
        for name, block in re.findall(FOLD, m.group(2))
    ]
    return "\n\n".join(parts)


class Toggles(Preprocessor):
    def __init__(self, md, first):
        super().__init__(md)
        self.first = first

    def run(self, lines):
        return SOLVE.sub(partial(tabs, self.first), "\n".join(lines)).split("\n")


class TogglesExtension(Extension):
    def __init__(self, first):
        super().__init__()
        self.first = first

    def extendMarkdown(self, md):
        # after snippets (32) pastes README.md in, and before superfences
        # and the raw HTML stash read the text
        md.preprocessors.register(Toggles(md, self.first), "toggles", 31.5)


# mkdocstrings reads Python source; a module written in mu has none in the
# repo. build/docs-src/pydsa is the package as Python: each .py copied, and
# for each .mu the Python that pydsa imports for it (pydsa/_mu.py).
SOURCE = Path(__file__).resolve().parent / "build" / "docs-src"


def python_package():
    sys.path.insert(0, str(SOURCE.parent.parent))
    import pydsa

    here = Path(pydsa.__file__).parent
    out = SOURCE / "pydsa"
    shutil.rmtree(out, ignore_errors=True)
    out.mkdir(parents=True)
    for py in here.glob("*.py"):
        shutil.copy(py, out / py.name)
    for mu in here.glob("*.mu"):
        module = importlib.import_module(f"pydsa.{mu.stem}")
        shutil.copy(module.__file__, out / f"{mu.stem}.py")


# before mkdocstrings reads its paths, which must then exist: a first build
# from a clean checkout (CI) found no build/docs-src
@event_priority(100)
def on_config(config):
    python_package()
    config.markdown_extensions.append(TogglesExtension("mu + pydsa"))
    return config
