#!/bin/bash

# Installs dependecies

echo $'\n---- pip install -----'
pip install -r requirements.txt --upgrade

echo $'\n---- ansible-galaxy install -----'
ansible-galaxy install -r ansible_galaxy.yaml

echo $'\n---- git pull -----'
git submodule update --init --recursive
git pull --recurse-submodules
git submodule update --remote
