SHELL := /bin/bash
.PHONY: default PYTHON3 PIP3 $(MAKECMDGOALS)

# Ensure python3 and pip3 are in the users path
PYTHON3 := $(shell command -v python3 2> /dev/null)
PIP3 := $(shell command -v pip3 2> /dev/null)
ifndef PYTHON3
$(error package 'python3' not found!)
else ifndef PIP3
$(error package 'pip3' not found!)
endif

## Show Help Menu By Default
default: help

## Run Ansible site.yml
site:
	@ansible-playbook -i hosts --vault-id=hpc_aggiegrid@"./.keys/hpc_aggiegrid.key" site.yml

## Run Ansible update.yml
update:
	@ansible-playbook -i hosts --vault-id=hpc_aggiegrid@"./.keys/hpc_aggiegrid.key" update.yml

## Setup Ansible Vault
vault-setup:
	@if [ ! -f ./.keys/hpc_aggiegrid.key ]; then \
		read -srp "Enter Password for Vault ID 'hpc_aggiegrid': " vault; \
		echo "$$vault" > ./.keys/hpc_aggiegrid.key; \
		unset vault; \
	fi

## Encrypt String
vault-encrypt: vault-setup
	@read -rp "Variable Name: " vname; \
	read -rsp "Variable String (Single Line): " vstring; \
	echo -e "\n"; \
	ansible-vault encrypt_string --vault-id hpc_aggiegrid@./.keys/hpc_aggiegrid.key "$$vstring" --name "$$vname"; \
	unset vname; \
	unset vstring

## Decrypt String
vault-decrypt: vault-setup
	@unset vstring; \
	unset line; \
	echo "Vault String Block (Enter Twice When Done): "; \
	while read -r line; do if [ -z $$line ]; then break; else vstring+="\n$$line"; fi; done; \
	echo -e "$$vstring" | tr -d '[:blank:]' | grep "\S" | ansible-vault decrypt --vault-id=hpc_aggiegrid@"./.keys/hpc_aggiegrid.key"

# See <https://gist.github.com/klmr/575726c7e05d8780505a> for explanation.
.PHONY: show-help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)";echo;sed -ne"/^## /{h;s/.*//;:d" -e"H;n;s/^## //;td" -e"s/:.*//;G;s/\\n## /---/;s/\\n/ /g;p;}" ${MAKEFILE_LIST}|LC_ALL='C' sort -f|awk -F --- -v n=$$(tput cols) -v i=19 -v a="$$(tput setaf 6)" -v z="$$(tput sgr0)" '{printf"%s%*s%s ",a,-i,$$1,z;m=split($$2,w," ");l=n-i;for(j=1;j<=m;j++){l-=length(w[j])+1;if(l<= 0){l=n-i-length(w[j])-1;printf"\n%*s ",-i," ";}printf"%s ",w[j];}printf"\n";}'|more $(shell test $(shell uname) == Darwin && echo '-Xr')
