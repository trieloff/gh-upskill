SHELL := /bin/bash

.PHONY: all test lint ci

all: ci

test:
	@echo "Running tests..."
	@bash tests/test-upskill.sh

lint:
	@echo "Running shellcheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
	  shellcheck -x upskill gh-upskill install.sh tests/*.sh ; \
	else \
	  echo "shellcheck not found; skipping lint"; \
	fi

ci: lint test

