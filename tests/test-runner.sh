#!/bin/bash

# Bash "stric mode"
set -euo pipefail

INSTANCE_LIST=''
_CURRENT_DIR="$(dirname "$0")"

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
    incus exec "$1" --project ansible-ws -- bash -c "\
        git clone \
        --shallow-submodules \
        --recurse-submodules \
        --depth 1 \
        https://github.com/ricnord/ansible-workstation \
        /tmp/ansible-workstation "
    incus exec --project ansible-ws "$1" -- bash -c "\
        make \
        -C /tmp/ansible-workstation \
        install"
}

get_projects() {
    ALL_INSTANCES=$(incus list --project ansible-ws --format csv --columns n)
}

terraform_apply

get_projects

export -f run_ansible

if [ -n "${INSTANCE_LIST}" ]; then
    echo running selected instances
    echo "$INSTANCE_LIST"
    parallel --delimiter "," run_ansible ::: "$INSTANCE_LIST"
else
    echo running all instances
    echo "$ALL_INSTANCES"
    parallel run_ansible ::: "$ALL_INSTANCES"
fi
