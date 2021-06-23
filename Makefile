install-deps:
	pip install ansible openshift docker

install-dev:
	ansible-galaxy collection install . --force
