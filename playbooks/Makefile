
# ansible-playbook vars
PLAYBOOK_HOST ?= local
PLAYBOOK_ARGS ?= --become

# roles/certbot
CERTBOT_DOMAIN ?= ak1ra.xyz
CERTBOT_EMAIL ?= certbot@ak1ra.xyz

.PHONY: encrypt
encrypt:  ## ansible-vault encrypt credentials/*.yaml
	ansible-vault encrypt credentials/*.yaml

.PHONY: decrypt
decrypt:  ## ansible-vault decrypt credentials/*.yaml
	ansible-vault decrypt credentials/*.yaml

# ansible-playbook receipts
.PHONY: common
common:  ## initial tasks with roles/common
	ansible-playbook playbooks/common.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)'

.PHONY: docker
docker:  ## install docker with roles/docker
	ansible-playbook playbooks/docker.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)'

.PHONY: certbot
certbot:  ## install certbot with roles/certbot
	ansible-playbook playbooks/certbot.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)' \
		-e 'domain=$(CERTBOT_DOMAIN)' -e 'email=$(CERTBOT_EMAIL)' \
		-e @credentials/certbot.yaml --ask-vault-pass

.PHONY: nginx
nginx:  ## install nginx with roles/nginx and roles/nginx_config
	ansible-playbook playbooks/nginx.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)' \
		-e 'domain=$(CERTBOT_DOMAIN)' -e 'email=$(CERTBOT_EMAIL)' \
		-e @credentials/certbot.yaml --ask-vault-pass

.PHONY: gcloud
gcloud:  ## install gcloud with roles/gcloud
	ansible-playbook playbooks/gcloud.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)'

.PHONY: jenkins
jenkins:  ## install jenkins with roles/jenkins
	ansible-playbook playbooks/jenkins.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)'

.PHONY: rsstt
rsstt:  ## install RSStT with roles/rsstt (https://github.com/Rongronggg9/RSS-to-Telegram-Bot)
	ansible-playbook playbooks/rsstt.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)' \
		-e @credentials/rsstt.yaml --ask-vault-pass

.PHONY: singbox
singbox:  ## install singbox with roles/singbox
	ansible-playbook playbooks/singbox.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)'
