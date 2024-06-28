
ANSIBLE_HOME := $(HOME)/.ansible

.DEFAULT_GOAL=help
.PHONY=help
help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ {\
		printf "\033[36m%-10s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)

.PHONY: yamlfmt
yamlfmt:
	command yamlfmt 2>/dev/null || \
		go install github.com/google/yamlfmt/cmd/yamlfmt@latest

.PHONY: fmt
fmt: yamlfmt  ## reformat yaml files
	yamlfmt .

.PHONY: install
install: fmt  ## install this ansible collection
	ansible-galaxy collection install . -p $(ANSIBLE_HOME)/collections

.PHONY: clean
clean:  ## clean up working directory
	git gc --aggressive

include playbooks/Makefile
