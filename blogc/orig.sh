#!/bin/bash

NUM_ARGS=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)/../.scripts"
source "${SCRIPT_DIR}/utils.sh"

OUTPUT_DIR="$(realpath "${1}")"

"${SCRIPT_DIR}/orig-cmake-cpack-xz.sh" \
    "${OUTPUT_DIR}" \
    "blogc"
