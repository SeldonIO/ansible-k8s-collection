install-deps:
	pip install ansible openshift docker passlib

install-dev:
	ansible-galaxy collection install . --force

install-seldon-v2:
	pip install -r requirements_kind.txt
	ansible-playbook playbooks/kind.yaml
