#!/bin/bash

NUM_ARGS=2
DEPENDENCIES="dctrl-tools"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/utils.sh"

REPO_NAME="${1}"
CODENAME="${2}"

control="$("${SCRIPT_DIR}/metadata-debian-file.sh" "${REPO_NAME}" control)"

codenames="$(
    grep-dctrl \
        --show-field X-Skip-Build-For \
        --no-field-names \
        "" \
        "${control}"
)"

for cname in ${codenames}; do
    if [[ "${cname}" = "${CODENAME}" ]]; then
        exit 1
    fi
done
