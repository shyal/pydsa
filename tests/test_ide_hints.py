"""Every public function of pydsa has signature help in the editor through
`from pydsa import name`. A new helper needs no list to be added to: this
test fails for any function the mu editor tool cannot see."""

import inspect

import pytest

import pydsa

ide = pytest.importorskip("mulang.ide")

PUBLIC = sorted(
    name
    for name, obj in vars(pydsa).items()
    if not name.startswith("_")
    and inspect.isfunction(obj)
    and obj.__module__.startswith("pydsa.")
)


def test_the_public_functions_are_found():
    assert "run_lengths" in PUBLIC and "lcs" in PUBLIC


@pytest.mark.parametrize("name", PUBLIC)
def test_signature_help_through_from_pydsa_import(name, tmp_path):
    text = f"from pydsa import {name}\n\nx = {name}("
    req = {"cmd": "signature", "root": str(tmp_path), "text": text, "line": 2, "col": len(f"x = {name}(")}
    got = ide.signature(req)
    assert got and got["label"].startswith(f"{name}("), f"no signature help for {name}"
