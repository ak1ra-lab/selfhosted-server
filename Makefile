# ansible
BINDIR ?= $(HOME)/.local/bin
ANSIBLE_HOME ?= $(HOME)/.ansible
ANSIBLE_GALAXY := $(BINDIR)/ansible-galaxy
ANSIBLE_PLAYBOOK := $(BINDIR)/ansible-playbook
ANSIBLE_VAULT := $(BINDIR)/ansible-vault

# ansible-playbook
PLAYBOOK_HOSTS ?= localhost
PLAYBOOK_ARGS ?= --become
repository ?= https://github.com/ak1ra-lab/selfhosted-server.git

.DEFAULT_GOAL=help
.PHONY: help
help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ {\
		printf "\033[36m%-10s\033[0m %s\n", $$1, substr($$0, index($$0,$$3)) \
	}' $(MAKEFILE_LIST)

.PHONY: pipx
pipx:
	command -v pipx >/dev/null || { \
		sudo apt-get update -y && \
		sudo apt-get install -y pipx; \
	}

.PHONY: ansible
ansible: pipx  ## pipx install ansible
	command -v ansible >/dev/null || { \
		pipx install ansible && \
		pipx inject ansible boto3 botocore && \
		ln -sf $(HOME)/.local/pipx/venvs/ansible/bin/ansible* $(HOME)/.local/bin/; \
	}

.PHONY: yamlfmt
yamlfmt:
	command -v yamlfmt >/dev/null || \
		go install github.com/google/yamlfmt/cmd/yamlfmt@latest

.PHONY: format
format: yamlfmt  ## reformat yml/yaml files recursively
	yamlfmt .

.PHONY: build
build: ansible  ## ansible-galaxy collection build
	$(ANSIBLE_GALAXY) collection build --force --output-path=./build .

.PHONY: install
install: ansible  ## ansible-galaxy collection install
	$(ANSIBLE_PLAYBOOK) install.yaml -e 'playbook_hosts=$(PLAYBOOK_HOSTS)' -e 'repository=$(repository)'

.PHONY: clean
clean:  ## clean up working directory
	rm -f ./build/*.tar.gz
	git gc --aggressive

include playbooks/Makefile
