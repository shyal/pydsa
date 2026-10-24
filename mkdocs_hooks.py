"""MkDocs hook: README.md gives each solve as a code block, then other
versions of the same solve, each folded in <details><summary>Label</summary>,
so GitHub shows them on a click. On the docs site the versions become tabs
of the solve. The first block, the unfolded one, is the first tab: mu +
pydsa on both sites."""

import re
import shutil
import sys
from functools import partial
from pathlib import Path

import griffe
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
ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "build" / "docs-src"


def python_package():
    sys.path.insert(0, str(SOURCE.parent.parent))
    import pydsa
    from pydsa import _mu

    here = Path(pydsa.__file__).parent
    out = SOURCE / "pydsa"
    shutil.rmtree(out, ignore_errors=True)
    out.mkdir(parents=True)
    for py in here.glob("*.py"):
        shutil.copy(py, out / py.name)
    # built, not imported: _treeformat imports PrettyPrint, which the docs
    # build does not install
    for mu in here.glob("*.mu"):
        shutil.copy(_mu.built(mu), out / f"{mu.stem}.py")


class MuSource(griffe.Extension):
    """The mu of each def and class read from build/docs-src, for the mu tab
    of its source block (templates/python/material/_mu.html.jinja): mu maps
    each line of the Python it writes to the .mu line it comes from."""

    def __init__(self):
        self.read = {}

    def mu_of(self, py):
        """(the .mu's lines, the mu line of each Python line) for a file of
        build/docs-src/pydsa written from a .mu, else None."""
        if py not in self.read:
            from mulang import transpile

            mu = ROOT / "pydsa" / f"{py.stem}.mu"
            self.read[py] = None
            if py.parent == SOURCE / "pydsa" and mu.is_file():
                code, origin = transpile(mu.read_text(), mapped=True, path=mu, library=False)
                if code == py.read_text():
                    self.read[py] = (mu.read_text().split("\n"), origin)
        return self.read[py]

    def on_object(self, *, obj, **kwargs):
        if obj.kind not in (griffe.Kind.FUNCTION, griffe.Kind.CLASS) or not obj.endlineno:
            return
        py = Path(obj.filepath).resolve()
        if not (got := self.mu_of(py)):
            return
        lines, origin = got
        at = [origin[k - 1] for k in range(obj.lineno, obj.endlineno + 1) if origin[k - 1]]
        if at:
            first, last = min(at), max(at)
            obj.extra["mu"].update(
                source="\n".join(lines[first - 1 : last]),
                lineno=first,
                path=f"pydsa/{py.stem}.mu",
            )


# before mkdocstrings reads its paths, which must then exist: a first build
# from a clean checkout (CI) found no build/docs-src
@event_priority(100)
def on_config(config):
    python_package()
    config.markdown_extensions.append(TogglesExtension("mu + pydsa"))
    return config
