"""The modules written in mu: imported through pydsa._mu, with no .py."""

import importlib
import inspect
from pathlib import Path

import pytest

import pydsa
from pydsa import _mu

PACKAGE = Path(pydsa.__file__).parent
MU = sorted(PACKAGE.glob("*.mu"))


@pytest.mark.parametrize("mu", MU, ids=lambda p: p.name)
def test_a_mu_module_imports_with_its_source(mu):
    assert not mu.with_suffix(".py").exists(), "a module is its .mu or its .py, not both"
    module = importlib.import_module(f"pydsa.{mu.stem}")
    assert module.__mu__ == str(mu)
    assert Path(module.__file__).name.startswith(f"{mu.stem}.mu-")
    assert inspect.getsource(module).startswith(('"""', "from", "import"))


def test_the_python_follows_the_mu(tmp_path, monkeypatch):
    """A change to the .mu names a new cached file and removes the old one."""
    monkeypatch.setattr(_mu, "cache_dir", lambda: tmp_path)
    mu = tmp_path / "m.mu"
    mu.write_text("def f() -> int\n  1\n")
    first = _mu.built(mu)
    assert "return 1" in first.read_text()
    mu.write_text("def f() -> int\n  2\n")
    second = _mu.built(mu)
    assert second != first and not first.exists() and "return 2" in second.read_text()
