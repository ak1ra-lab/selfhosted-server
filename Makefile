
ANSIBLE_HOME ?= $(HOME)/.ansible

GIT := git
ANSIBLE_GALAXY := ansible-galaxy

.DEFAULT_GOAL=help
.PHONY=help
help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ {\
		printf "\033[36m%-10s\033[0m %s\n", $$1, substr($$0, index($$0,$$3)) \
	}' $(MAKEFILE_LIST)

.PHONY: yamlfmt
yamlfmt:
	command yamlfmt 2>/dev/null || \
		go install github.com/google/yamlfmt/cmd/yamlfmt@latest

.PHONY: fmt
fmt: yamlfmt  ## reformat yaml files
	yamlfmt .

.PHONY: build
build: fmt  ## ansible-galaxy collection build
	$(ANSIBLE_GALAXY) collection build --force .

.PHONY: install
install: fmt  ## ansible-galaxy collection install
	$(ANSIBLE_GALAXY) collection install -p $(ANSIBLE_HOME)/collections .

.PHONY: clean
clean:  ## clean up working directory
	$(RM) *.tar.gz
	$(GIT) gc --aggressive

include playbooks/Makefile
