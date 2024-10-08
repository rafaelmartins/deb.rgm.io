#!/bin/bash

export DEBEMAIL="rafael+deb@rafaelmartins.eng.br"
export DEBFULLNAME="Automatic Builder (github-actions)"

NUM_ARGS=3
DEPENDENCIES="devscripts"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/utils.sh"

ORIG_DIR="$(realpath "${1}")"
DEB_DIR="$(realpath "${2}")"
OUTPUT_DIR="$(realpath "${3}")"

bdeps=()
build=()
declare -A changelog
for repo in $("${SCRIPT_DIR}/metadata-repos.sh"); do
    chl_version_rev="$("${SCRIPT_DIR}/metadata-changelog-version-rev.sh" "${repo}")"
    chl_version="$("${SCRIPT_DIR}/metadata-strip-rev.sh" "${chl_version_rev}")"
    orig_version="$("${SCRIPT_DIR}/metadata-orig-version.sh" "${ORIG_DIR}" "${repo}")"
    orig_ss_version="$("${SCRIPT_DIR}/metadata-orig-version.sh" "${ORIG_DIR}" "${repo}-snapshot")"

    while read distro; do
        codename="$(echo "${distro}" | cut -d_ -f2)"
        if ! "${SCRIPT_DIR}/metadata-build-for-codename.sh" "${repo}" "${codename}"; then
            continue
        fi

        for arch in amd64 arm64 source; do
            if [[ "${arch}" != arm64 ]] || [[ "${FORCE_ARM64:-}" == true ]]; then
                # release repository
                if [[ "${chl_version}" = "${orig_version}" ]]; then
                    deb_version_rev="$("${SCRIPT_DIR}/metadata-deb-version-rev.sh" "${DEB_DIR}" "${repo}" "${codename}" "${arch}")"
                    if [[ -z "${deb_version_rev}" ]] || [[ "${chl_version_rev}" != "${deb_version_rev}" ]]; then
                        build+=("${repo} ${distro} ${arch}")
                        changelog["${repo} ${distro} ${chl_version_rev}"]=0
                        if [[ "${arch}" != source ]]; then
                            bdeps+=("${repo} ${arch}")
                        fi
                    fi
                fi

                # snapshot repository
                deb_version_rev="$("${SCRIPT_DIR}/metadata-deb-version-rev.sh" "${DEB_DIR}" "${repo}-snapshot" "${codename}" "${arch}")"
                orig_ss_version_rev="${orig_ss_version}-$(echo "${chl_version_rev}" | rev | cut -d- -f1 | rev)"
                if [[ -z "${deb_version_rev}" ]] || [[ "${deb_version_rev}" != "${orig_ss_version_rev}" ]]; then
                    build+=("${repo}-snapshot ${distro} ${arch}")
                    changelog["${repo}-snapshot ${distro} ${orig_ss_version_rev}"]=0
                    if [[ "${arch}" != source ]]; then
                        control="$("${SCRIPT_DIR}/metadata-debian-file.sh" "${repo}-snapshot" control)"
                        if [[ "${control}" = *-snapshot ]]; then
                            bdeps+=("${repo}-snapshot ${arch}")
                        else
                            bdeps+=("${repo} ${arch}")
                        fi
                    fi
                fi
            fi
        done
    done < "${ROOT_DIR}/DISTROS"
done

mkdir -p "${OUTPUT_DIR}"
touch "${OUTPUT_DIR}/.keep"

for c in "${!changelog[@]}"; do
    "${SCRIPT_DIR}/create-changelog.sh" \
        "${OUTPUT_DIR}" \
        "${DEB_DIR}" \
        ${c} \
    1>&2
done

if [[ "${#bdeps[@]}" -eq 0 ]]; then
    bdeps+=("placeholder")
fi

if [[ "${#build[@]}" -eq 0 ]]; then
    build+=("placeholder")
fi

sbdeps="bdeps=$(
    jq \
        -cnM \
        '$ARGS.positional | unique' \
        --args "${bdeps[@]}"
)"

sbuild="build=$(
    jq \
        -cnM \
        '$ARGS.positional' \
        --args "${build[@]}"
)"q

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    echo "${sbdeps}" >> "${GITHUB_OUTPUT}"
    echo "${sbuild}" >> "${GITHUB_OUTPUT}"
else
    echo "${sbdeps}"
    echo "${sbuild}"
fi
