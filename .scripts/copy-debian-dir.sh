#!/bin/bash

NUM_ARGS=2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/utils.sh"

REPO_NAME="${1}"
BUILD_DIR="$(realpath "${2}")"

debian="${ROOT_DIR}/${REPO_NAME%%-snapshot}/debian"

if [[ ! -d  "${debian}" ]]; then
    die "debian directory not found"
fi

rm -rf "${BUILD_DIR}/debian"
mkdir -p "${BUILD_DIR}/debian"

pushd "${debian}" > /dev/null

for f in *; do
    if [[ ! -e "${f}" ]]; then
        continue
    fi

    target="${f}"
    if [[ "${f}" = *-snapshot ]]; then
        if [[ "${REPO_NAME}" = *-snapshot ]]; then
            target="${f%%-snapshot}"
        else
            continue
        fi
    fi

    cp \
        --recursive \
        "${f}" \
        "${BUILD_DIR}/debian/${target}"
done

popd > /dev/null
