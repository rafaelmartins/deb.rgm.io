#!/bin/bash

NUM_ARGS=2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/utils.sh"

REPO_NAME="${1}"
FILE_NAME="${2}"

f="${ROOT_DIR}/${REPO_NAME%%-snapshot}/debian/${FILE_NAME}"
if [[ ${REPO_NAME} = *-snapshot ]] && [[ -f "${f}-snapshot" ]]; then
    f="${f}-snapshot"
fi

if [[ ! -f  "${f}" ]]; then
    die "${FILE_NAME} file not found"
fi

echo "${f}"
