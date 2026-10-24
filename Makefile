VERSION := $(shell sed -n 's/^version = "\(.*\)"/\1/p' pyproject.toml)

PY := .venv/bin/python

.PHONY: venv release

# the dev venv: this repo and its sibling as editable installs, so a change
# in either is live, with the test, docs and drawing extras
venv:
	uv venv --python 3.13 .venv
	uv pip install --python $(PY) -e '.[test,draw,docs]' -e '../mu[ide]'

# push master (the docs build), then publish pizza-lib to PyPI; release mu
# first when this version needs a newer mu-language
release:
	$(PY) -m pytest -q tests
	git push origin master
	rm -rf dist && uv build && uv publish
	@echo "pizza-lib $(VERSION) released"
