#!/bin/bash

# Bash "stric mode"
set -euo pipefail

INSTANCE_LIST=''
_CURRENT_DIR="$(dirname "$0")"

# Colors
BBlue='\033[1;34m'
NC='\033[0m' # NO COLOR

function usage() {
    cat <<EOF
    Usage: $0 [ -i instance1,instance2... ]

    -i    comma separeated list of instances

EOF
    exit 1
}

# Parse args
while getopts "i:" opt; do
    case "${opt}" in
        i) INSTANCE_LIST=$OPTARG ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

terraform_apply() {
    if [ -n "${INSTANCE_LIST}" ]; then
        FORMATTED_INSTANCE_LIST=\"${INSTANCE_LIST//,/\",\"}\"
    else
        FORMATTED_INSTANCE_LIST=
    fi
    eval terraform -chdir="${_CURRENT_DIR}/terraform" apply -auto-approve -var="'instance-list=[${FORMATTED_INSTANCE_LIST}]'"
}

run_ansible() {
    args=()
    args=('-v')
    # Check for container
    [[ "$1" == *"container"* ]] && args+=('-x false')

    incus exec "$1" --project ansible-ws -- bash -c "\
        rm -rf /tmp/ansible-workstation
        "
    incus exec "$1" --project ansible-ws -- bash -c "\
        git clone \
        --single-branch \
        --branch $(git branch --show-current) \
        --shallow-submodules \
        --recurse-submodules \
        --depth 1 \
        https://github.com/ricnord/ansible-workstation \
        /tmp/ansible-workstation "
    incus exec --project ansible-ws "$1" -- bash -c "\
        chmod u+x /tmp/ansible-workstation/run-ansible.sh"
    incus exec --project ansible-ws "$1" -- bash -c "\
        /tmp/ansible-workstation/run-ansible.sh ${args[*]}"
}

get_projects() {
    ALL_INSTANCES=$(incus list --project ansible-ws --format csv --columns n)
}

terraform_apply

get_projects

export -f run_ansible

if [ -n "${INSTANCE_LIST}" ]; then
    echo -e "${BBlue}Testing selected instances... \n${NC}"
    echo "$INSTANCE_LIST"
    printf "\n"
    echo -e "${BBlue}Running... Writing output to: ${NC}\n\t /tmp/.ansible-output/ \n"
    parallel \
        --delimiter "," \
        --tagstring '{}' \
        --results /tmp/.ansible-output/{}/ \
        --joblog /tmp/.ansible-ws-test.log \
        run_ansible ::: "$INSTANCE_LIST" || true

    printf "\n"
    echo -e "${BBlue}Test result log: ${NC}"
    column -t /tmp/.ansible-ws-test.log
else
    echo -e "${BBlue}Testing all instances... \n${NC}"
    echo "$ALL_INSTANCES"
    printf "\n"
    echo -e "${BBlue}Running... Writing output to: ${NC}\n\t /tmp/.ansible-output/ \n"
    parallel \
        --tagstring '{}' \
        --results /tmp/.ansible-output/{}/ \
        --joblog /tmp/.ansible-ws-test.log \
        run_ansible ::: "$ALL_INSTANCES" || true

    printf "\n"
    echo -e "${BBlue}Test result log: \n${NC}"
    column -t /tmp/.ansible-ws-test.log
fi
