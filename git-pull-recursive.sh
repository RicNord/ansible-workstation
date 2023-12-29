#!/bin/bash

echo $'\n---- git pull -----'
git submodule update --init --recursive
git pull --recurse-submodules
git submodule update --remote
