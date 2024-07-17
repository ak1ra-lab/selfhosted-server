
.PHONY: encrypt
encrypt:  ## ansible-vault encrypt credentials/*.yaml
	$(ANSIBLE_VAULT) encrypt credentials/*.yaml

.PHONY: decrypt
decrypt:  ## ansible-vault decrypt credentials/*.yaml
	$(ANSIBLE_VAULT) decrypt credentials/*.yaml

# ansible-playbook receipts
.PHONY: common
common:  ## initial tasks with roles/common
	$(ANSIBLE_PLAYBOOK) playbooks/common.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)'

.PHONY: docker
docker:  ## install docker with roles/docker
	$(ANSIBLE_PLAYBOOK) playbooks/docker.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)'

.PHONY: certbot
certbot:  ## install certbot with roles/certbot
	$(ANSIBLE_PLAYBOOK) playbooks/certbot.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)' \
		-e @credentials/certbot.yaml --ask-vault-pass

.PHONY: nginx
nginx:  ## install nginx with roles/nginx and roles/nginx_config
	$(ANSIBLE_PLAYBOOK) playbooks/nginx.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)' \
		-e @credentials/certbot.yaml --ask-vault-pass

.PHONY: gcloud
gcloud:  ## install gcloud with roles/gcloud
	$(ANSIBLE_PLAYBOOK) playbooks/gcloud.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)'

.PHONY: jenkins
jenkins:  ## install jenkins with roles/jenkins
	$(ANSIBLE_PLAYBOOK) playbooks/jenkins.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)'

.PHONY: rsstt
rsstt:  ## install RSStT with roles/rsstt (https://github.com/Rongronggg9/RSS-to-Telegram-Bot)
	$(ANSIBLE_PLAYBOOK) playbooks/rsstt.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)' \
		-e @credentials/rsstt.yaml --ask-vault-pass

.PHONY: singbox
singbox:  ## install singbox with roles/singbox
	$(ANSIBLE_PLAYBOOK) playbooks/singbox.yaml $(PLAYBOOK_ARGS) -e 'host=$(PLAYBOOK_HOST)'
