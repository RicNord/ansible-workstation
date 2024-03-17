#!/bin/bash

# Fail on any non-zero exit code
set -eo pipefail

RECREATE_VENV=false
ANSIBLE_VENV_PATH="/tmp/.ansible-venv"

function usage() {
    cat <<EOF
    Usage: $0 [ -c ]

    -c    clean run, recreates viritual enviorment

EOF
    exit 1
}

# Parse args
while getopts ":c" opt; do
    case "${opt}" in
        c) RECREATE_VENV=true ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

BBlue='\033[1;34m'
NC='\033[0m' # NO COLOR

echo -e "${BBlue}Create or activate viritual enviormant at: $ANSIBLE_VENV_PATH ${NC}"
if [ -d "$ANSIBLE_VENV_PATH" ] && [ "$RECREATE_VENV" == true ]; then
    [[ "$VIRTUAL_ENV" != "" ]] && deactivate
    rm -rf "$ANSIBLE_VENV_PATH"
    echo "Recreating venv"
fi
python3 -m venv "$ANSIBLE_VENV_PATH"
source "$ANSIBLE_VENV_PATH/bin/activate"

echo -e "${BBlue}Pip install requirements ${NC}"
pip install -r ./requirements.txt

echo -e "${BBlue}Ansible galaxy install ${NC}"
ansible-galaxy install -r ansible_galaxy.yaml

echo -e "${BBlue}Run ansible playbook ${NC}"
USER_ID=$(id -u)
if [ "$USER_ID" -ne 0 ]; then
    ansible-playbook main.yaml -K
else
    ansible-playbook main.yaml
fi
