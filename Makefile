# ansible
BINDIR ?= $(HOME)/.local/bin
ANSIBLE_HOME ?= $(HOME)/.ansible
ANSIBLE_GALAXY := $(BINDIR)/ansible-galaxy
ANSIBLE_PLAYBOOK := $(BINDIR)/ansible-playbook
ANSIBLE_VAULT := $(BINDIR)/ansible-vault

# ansible-playbook
PLAYBOOK_HOST ?= local
PLAYBOOK_ARGS ?= --become

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
build:  ## ansible-galaxy collection build
	$(ANSIBLE_GALAXY) collection build --force --output-path=./build .

.PHONY: install
install:  ## ansible-galaxy collection install
	$(ANSIBLE_PLAYBOOK) install.yaml -e 'host=$(PLAYBOOK_HOST)'

.PHONY: clean
clean:  ## clean up working directory
	rm -f ./build/*.tar.gz
	git gc --aggressive

include playbooks/Makefile
