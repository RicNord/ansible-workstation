#!/bin/bash

# Fail on any non-zero exit code
set -eo pipefail

RECREATE_VENV=false
ANSIBLE_VENV_PATH="/tmp/.ansible-venv"
XORG=true
VERBOSE=false
_CURRENT_DIR="$(dirname "$0")"
ANSIBLE_CONFIG="$(dirname "$0")"
export ANSIBLE_CONFIG

function usage() {
    cat <<EOF
    Usage: $0 [ -c ] [ -x BOOLEAN ] [ -v ]

    -c    clean run, recreates viritual enviorment
    -x    If Xorg is intended to run on machine. Booelan; defaults to true
    -v    Verbose

EOF
    exit 1
}

# Parse args
while getopts ":cvx:" opt; do
    case "${opt}" in
        c) RECREATE_VENV=true ;;
        x) XORG=$OPTARG ;;
        v) VERBOSE=true ;;
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
pip install -r "${_CURRENT_DIR}/requirements.txt"

echo -e "${BBlue}Ansible galaxy install ${NC}"
ansible-galaxy install -r "${_CURRENT_DIR}/ansible_galaxy.yaml"

echo -e "${BBlue}Run ansible playbook ${NC}"

# Build up args for ansible-playbook
args=()

# Check for root
[ "$(id -u)" -ne 0 ] && args+=('--ask-become-pass')

# Check for VERBOSE
[ "$VERBOSE" == true ] && args+=('--verbose')

# Check for XORG
[ "$XORG" == false ] && args+=('--skip-tags=X')

echo -e "${BBlue}ansible-playbook args: ${NC}" "${args[@]}"

ansible-playbook "${args[@]}" -- "${_CURRENT_DIR}/main.yaml"
