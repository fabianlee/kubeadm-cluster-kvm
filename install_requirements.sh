#!/bin/bash
#
# Installs OS level apt packages
# and then Ansible galaxy modules required to run scripting
#

# os level and file requirements
ansible-playbook install_dependencies.yml

# ansible galaxy modules
ansible-galaxy collection install -r galaxy_requirements.yaml
# -p ../collections
