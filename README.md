# ⏳ ansible-tools
Collection of Ansible roles and playbooks crafted for Seldon ecosystem

> :warning: **NOTE:** This is work in progress

## Requirements

To install Ansible and its requirements:
```bash
pip install ansible openshift docker passlib
ansible-galaxy collection install git+https://github.com/SeldonIO/ansible-k8s-collection.git
```

## Playbooks

### /playbooks/kind.yaml

Creates Kind cluster and sets up MetalLB

Components:
 * Create a kind cluster
 * Install metallb

```bash
ansible-playbook playbooks/tempo/kind.yaml
```

### /playbooks/seldon_core.yaml

Installs Istio, MinIO and Seldon Core

Components:
 * Install Istio
 * Install Minio
 * Install Seldon Core

```bash
ansible-playbook playbooks/tempo/seldon_core.yaml
```
