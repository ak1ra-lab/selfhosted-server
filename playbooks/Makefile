
# ansible-playbook vars
PLAYBOOK_HOST ?= local
PLAYBOOK_DOMAIN ?= ak1ra.xyz
PLAYBOOK_EMAIL ?= certbot@ak1ra.xyz
PLAYBOOK_VAULT_FILE ?= @credentials/cloudflare.yaml

# ansible-playbook wrapper
.PHONY: common
common:  ## initial tasks with roles/common
	ansible-playbook playbooks/common.yaml -e 'host=$(PLAYBOOK_HOST)' --become

.PHONY: docker
docker:  ## install docker with roles/docker
	ansible-playbook playbooks/docker.yaml -e 'host=$(PLAYBOOK_HOST)' --become

.PHONY: certbot
certbot:  ## install certbot with roles/certbot
	ansible-playbook playbooks/certbot.yaml \
		-e 'host=$(PLAYBOOK_HOST)' -e 'domain=$(PLAYBOOK_DOMAIN)' -e 'email=$(PLAYBOOK_EMAIL)' \
		-e $(PLAYBOOK_VAULT_FILE) --ask-vault-pass --become

.PHONY: nginx
nginx:  ## install nginx with roles/nginx and roles/nginx_config
	ansible-playbook playbooks/nginx.yaml \
		-e 'host=$(PLAYBOOK_HOST)' -e 'domain=$(PLAYBOOK_DOMAIN)' -e 'email=$(PLAYBOOK_EMAIL)' \
		-e $(PLAYBOOK_VAULT_FILE) --ask-vault-pass --become
