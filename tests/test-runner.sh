#!/bin/bash

# Bash "stric mode"
set -euo pipefail

INSTANCE_LIST=''
UBUNTU_VERSIONS='22.04,24.04'
_CURRENT_DIR="$(dirname "$0")"

# Colors
BBlue='\033[1;34m'
NC='\033[0m' # NO COLOR

function usage() {
    cat <<EOF
    Usage: $0 [ -i instance1,instance2... ]

    -i    comma separeated list of instances
    -u    comma separeated list of ubuntu versions (default: 22.04,24.04)

EOF
    exit 1
}

# Parse args
while getopts "i:u:" opt; do
    case "${opt}" in
        i) INSTANCE_LIST=$OPTARG ;;
        u) UBUNTU_VERSIONS=$OPTARG ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

terraform_apply() {

    terraform -chdir="${_CURRENT_DIR}/terraform" init -upgrade

    args=()

    if [ -n "${INSTANCE_LIST}" ]; then
        FORMATTED_INSTANCE_LIST=\"${INSTANCE_LIST//,/\",\"}\"
        args+=("-var='instance-list=[${FORMATTED_INSTANCE_LIST}]'")
    fi

    if [ -n "${UBUNTU_VERSIONS}" ]; then
        FORMATTED_UBUNTU_LIST=\"${UBUNTU_VERSIONS//,/\",\"}\"
        args+=("-var='ubuntu-versions=[${FORMATTED_UBUNTU_LIST}]'")
    fi

    eval terraform -chdir="${_CURRENT_DIR}/terraform" apply -auto-approve "${args[*]}"
}

run_ansible() {
    args=()
    args=('-v')
    # Check for container
    [[ "$1" == *"cont"* ]] && args+=('-x false')

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

get_project_instances() {
    ALL_INSTANCES=$(incus list --project ansible-ws --format csv --columns n)
}

terraform_apply

get_project_instances

export -f run_ansible

if [ -n "${INSTANCE_LIST}" ]; then
    echo -e "${BBlue}Testing selected instances... \n${NC}"
    echo "$ALL_INSTANCES"
    printf "\n"
    echo -e "${BBlue}Running... Writing output to: ${NC}\n\t /tmp/.ansible-output/ \n"
    parallel \
        --tagstring '{}' \
        --results /tmp/.ansible-output/{}/ \
        --joblog /tmp/.ansible-ws-test.log \
        run_ansible ::: "$ALL_INSTANCES" || true

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
