#!/bin/bash

NUM_ARGS=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/utils.sh"

REPO_NAME="${1}"

changelog="$("${SCRIPT_DIR}/metadata-debian-file.sh" "${REPO_NAME}" changelog)"

dpkg-parsechangelog \
    -l "${changelog}" \
    -S Version \
| cut -d~ -f1
