PREFIX ?= /usr/local

.PHONY: all check test install uninstall help

all: check test

check:
	@echo "Checking bash syntax..."
	@bash -n bin/jaaw
	@bash -n install.sh
	@bash -n uninstall.sh
	@bash -n completions/jaaw.bash
	@bash -n tests/test_alias.sh
	@echo "Syntax OK."

test:
	@bash tests/test_alias.sh

install:
	./install.sh $(PREFIX)

uninstall:
	./uninstall.sh $(PREFIX)

help:
	@echo "jaaw Makefile targets:"
	@echo "  make check      - Verify bash syntax of all scripts"
	@echo "  make install    - Install jaaw to $(PREFIX)/bin"
	@echo "  make uninstall  - Uninstall jaaw from $(PREFIX)/bin"

