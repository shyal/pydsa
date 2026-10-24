VERSION := $(shell sed -n 's/^version = "\(.*\)"/\1/p' pyproject.toml)

# the leet venv has mu and pydsa as editable installs, so the tests see both
PY ?= $(HOME)/dev/leet/.venv/bin/python

.PHONY: release

# push master (the docs build), then publish pizza-lib to PyPI; release mu
# first when this version needs a newer mu-language
release:
	$(PY) -m pytest -q tests
	git push origin master
	rm -rf dist && uv build && uv publish
	@echo "pizza-lib $(VERSION) released"
