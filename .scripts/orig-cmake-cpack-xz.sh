#!/bin/bash

NUM_ARGS=2
DEPENDENCIES="cmake ninja-build"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/utils.sh"

OUTPUT_DIR="$(realpath "${1}")"
NAME="${2}"

mkdir build-orig

cmake \
    -B build-orig \
    -S . \
    -G Ninja

cmake \
    --build build-orig \
    --target package_source

pushd build-orig > /dev/null
mv \
    "${NAME}"-*.tar.xz \
    "${OUTPUT_DIR}/$(
        echo "${NAME}"-*.tar.xz \
        | sed \
            -e "s/${NAME}-/${NAME}_/" \
            -e 's/\.tar\./.orig.tar./'
    )"
popd > /dev/null
