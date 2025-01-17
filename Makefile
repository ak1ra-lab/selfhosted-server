# ansible
BINDIR ?= $(HOME)/.local/bin
ANSIBLE_PLAYBOOK := $(BINDIR)/ansible-playbook

# ansible-playbook
playbookHosts ?= localhost

.DEFAULT_GOAL=help
.PHONY: help
help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ {\
		printf "\033[36m%-10s\033[0m %s\n", $$1, substr($$0, index($$0,$$3)) \
	}' $(MAKEFILE_LIST)

.PHONY: format
format:  ## reformat yml/yaml files recursively
	yamlfmt .

.PHONY: install
install:  ## ansible-galaxy collection install
	$(ANSIBLE_PLAYBOOK) install.yml -e 'playbookHosts=$(playbookHosts)'

.PHONY: clean
clean:  ## clean up working directory
	git gc --aggressive
