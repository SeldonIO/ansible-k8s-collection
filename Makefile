install-deps:
	pip install ansible openshift docker passlib

install-dev:
	ansible-galaxy collection install . --force
