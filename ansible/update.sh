#!/bin/bash
HERE=$(dirname $0)
INV=$HERE/inventory
sudo ansible-playbook -i $INV $HERE/system.yml
ansible-playbook -i $INV $HERE/dotfiles.yml
