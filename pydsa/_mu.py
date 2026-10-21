"""The modules of pydsa written in mu. `import pydsa.grid` with no grid.py
reads grid.mu: mu transpiles it into __pycache__, and Python imports that
file, so `inspect.getsource` and tracebacks show the Python mu wrote. The
cached file is named after a hash of the .mu and of the transpiler, so a
change to either writes it again, and an unchanged module needs no mu.
A module carries `__mu__`, the path of its .mu."""

import hashlib
import importlib.util
import os
import sys
import tempfile
from importlib.machinery import SourceFileLoader
from pathlib import Path

HERE = Path(__file__).resolve().parent


def transpiler():
    """The source of mulang's transpiler, read without importing it."""
    spec = importlib.util.find_spec("mulang")
    if spec is None or spec.origin is None:
        raise ImportError("pydsa needs mu to import a module written in mu: pip install mu-language")
    return Path(spec.origin).read_bytes()


def cache_dir():
    """__pycache__ next to the modules, or a temporary directory when the
    package directory is read-only."""
    for d in (HERE / "__pycache__", Path(tempfile.gettempdir()) / "pydsa-mu"):
        try:
            d.mkdir(exist_ok=True)
            if os.access(d, os.W_OK):
                return d
        except OSError:
            continue
    raise ImportError("pydsa: no writable directory for the Python of its mu modules")


def built(mu):
    """The Python file for a .mu, written when it is not there yet."""
    key = hashlib.sha1(mu.read_bytes() + transpiler()).hexdigest()[:16]
    d = cache_dir()
    py = d / f"{mu.stem}.mu-{key}.py"
    if not py.exists():
        from mulang import transpile

        text = transpile(mu.read_text(), path=mu, library=False)
        tmp = py.with_suffix(f".{os.getpid()}.tmp")
        tmp.write_text(text)
        os.replace(tmp, py)
        for old in d.glob(f"{mu.stem}.mu-*.py"):
            if old != py:
                old.unlink(missing_ok=True)
    return py


class MuLoader(SourceFileLoader):
    def __init__(self, fullname, path, mu):
        super().__init__(fullname, path)
        self.mu = mu

    def exec_module(self, module):
        module.__mu__ = str(self.mu)
        super().exec_module(module)


class MuFinder:
    """Finds pydsa.<name> as <name>.mu when no <name>.py is there."""

    @staticmethod
    def find_spec(fullname, path=None, target=None):
        package, _, name = fullname.rpartition(".")
        if package != __package__:
            return None
        mu = HERE / f"{name}.mu"
        if not mu.is_file() or mu.with_suffix(".py").exists():
            return None
        py = str(built(mu))
        return importlib.util.spec_from_file_location(fullname, py, loader=MuLoader(fullname, py, mu))


if MuFinder not in sys.meta_path:
    sys.meta_path.insert(0, MuFinder)
