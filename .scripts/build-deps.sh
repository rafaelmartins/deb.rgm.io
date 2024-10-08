#!/bin/bash

NUM_ARGS=3

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/utils.sh"

OUTPUT_DIR="$(realpath "${1}")"
REPO_NAME="${2}"
ARCH="${3}"

tmpdir="$(mktemp -d)"
trap 'rm -rf -- "${tmpdir}"' EXIT

control="$("${SCRIPT_DIR}/metadata-debian-file.sh" "${REPO_NAME}" control)"
bcontrol="$(basename ${control})"

docker run \
    --pull=always \
    --rm \
    --init \
    --volume "${ROOT_DIR}/${REPO_NAME%%-snapshot}:/src" \
    --volume "${tmpdir}:/builddeps" \
    --workdir /builddeps \
    debian:sid \
    bash \
        -c "\
            set -Eeuo pipefail; \
            trap 'chown -R $(id -u):$(id -g) /builddeps' EXIT; \
            apt update \
            && apt install \
                -y \
                --no-install-recommends \
                    devscripts \
                    equivs \
            && mk-build-deps \
                --arch ${ARCH} \
                --build-arch ${ARCH} \
                --host-arch ${ARCH} \
                /src/debian/${bcontrol} \
        "

mkdir -p "${OUTPUT_DIR}"
cp -rv "${tmpdir}"/* "${OUTPUT_DIR}/"
