#!/usr/bin/env bash
# vendor-sherpa-onnx.sh
# Downloads sherpa-onnx + onnxruntime static libraries and the bundled punctuation model.
#
# Usage: ./scripts/vendor-sherpa-onnx.sh [sherpa-version] [onnxruntime-version]
# Defaults: v1.13.2 / v1.24.4

set -euo pipefail

SHERPA_VERSION="${1:-v1.13.2}"
ONNX_VERSION="${2:-v1.24.4}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_DIR="${REPO_ROOT}/Vendor"
BRIDGE_LIB_DIR="${REPO_ROOT}/Sources/VocaMacSherpaBridge/lib"
BRIDGE_INCLUDE_DIR="${REPO_ROOT}/Sources/VocaMacSherpaBridge/include"

SHERPA_ARCHIVE="sherpa-onnx-${SHERPA_VERSION}-macos-xcframework-static.tar.bz2"
SHERPA_URL="https://github.com/k2-fsa/sherpa-onnx/releases/download/${SHERPA_VERSION}/${SHERPA_ARCHIVE}"
XCFRAMEWORK_PATH="${VENDOR_DIR}/sherpa-onnx.xcframework"

PUNCT_ARCHIVE="sherpa-onnx-punct-ct-transformer-zh-en-vocab272727-2024-04-12-int8.tar.bz2"
PUNCT_URL="https://github.com/k2-fsa/sherpa-onnx/releases/download/punctuation-models/${PUNCT_ARCHIVE}"
PUNCT_FOLDER="sherpa-onnx-punct-ct-transformer-zh-en-vocab272727-2024-04-12-int8"
PUNCT_MODEL="${VENDOR_DIR}/punctuation/model.int8.onnx"

ARCH="$(uname -m)"
case "${ARCH}" in
    arm64) ONNX_ARCHIVE="onnxruntime-osx-arm64-static_lib-${ONNX_VERSION#v}.zip" ;;
    x86_64) ONNX_ARCHIVE="onnxruntime-osx-x86_64-static_lib-${ONNX_VERSION#v}.zip" ;;
    *) ONNX_ARCHIVE="onnxruntime-osx-universal2-static_lib-${ONNX_VERSION#v}.zip" ;;
esac
ONNX_URL="https://github.com/csukuangfj/onnxruntime-libs/releases/download/${ONNX_VERSION}/${ONNX_ARCHIVE}"

link_bridge_artifacts() {
    mkdir -p "${BRIDGE_LIB_DIR}" "${BRIDGE_INCLUDE_DIR}"
    ln -sf "../../../Vendor/sherpa-onnx.xcframework/macos-arm64_x86_64/libsherpa-onnx.a" \
        "${BRIDGE_LIB_DIR}/libsherpa-onnx.a"
    ln -sf "../../../Vendor/sherpa-onnx.xcframework/macos-arm64_x86_64/Headers/sherpa-onnx" \
        "${BRIDGE_INCLUDE_DIR}/sherpa-onnx"

    local onnx_lib="${VENDOR_DIR}/onnxruntime/lib/libonnxruntime.a"
    if [[ -f "${onnx_lib}" ]]; then
        ln -sf "../../../Vendor/onnxruntime/lib/libonnxruntime.a" \
            "${BRIDGE_LIB_DIR}/libonnxruntime.a"
    fi
}

ensure_punctuation_model() {
    if [[ -f "${PUNCT_MODEL}" ]]; then
        echo "Punctuation model already present"
        return
    fi

    echo "Downloading ${PUNCT_URL} ..."
    curl -fL --retry 3 --retry-delay 2 -C - -o "${TMP_DIR}/${PUNCT_ARCHIVE}" "${PUNCT_URL}"

    local extract_dir="${TMP_DIR}/punct-extract"
    mkdir -p "${extract_dir}"
    tar -xjf "${TMP_DIR}/${PUNCT_ARCHIVE}" -C "${extract_dir}"

    local extracted_model="${extract_dir}/${PUNCT_FOLDER}/model.int8.onnx"
    if [[ ! -f "${extracted_model}" ]]; then
        echo "ERROR: model.int8.onnx not found in ${PUNCT_ARCHIVE}" >&2
        exit 1
    fi

    mkdir -p "$(dirname "${PUNCT_MODEL}")"
    cp "${extracted_model}" "${PUNCT_MODEL}"
    echo "Installed ${PUNCT_MODEL}"
}

if [[ -d "${XCFRAMEWORK_PATH}" ]] \
    && [[ -f "${VENDOR_DIR}/onnxruntime/lib/libonnxruntime.a" ]] \
    && [[ -f "${PUNCT_MODEL}" ]]; then
    echo "sherpa-onnx + onnxruntime + punctuation model already present"
    link_bridge_artifacts
    exit 0
fi

mkdir -p "${VENDOR_DIR}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

if [[ ! -d "${XCFRAMEWORK_PATH}" ]]; then
    echo "Downloading ${SHERPA_URL} ..."
    curl -fL --retry 3 --retry-delay 2 -C - -o "${TMP_DIR}/${SHERPA_ARCHIVE}" "${SHERPA_URL}"
    tar -xjf "${TMP_DIR}/${SHERPA_ARCHIVE}" -C "${TMP_DIR}"
    EXTRACTED="$(find "${TMP_DIR}" -name 'sherpa-onnx.xcframework' -type d | head -1)"
    if [[ -z "${EXTRACTED}" ]]; then
        echo "ERROR: sherpa-onnx.xcframework not found in archive" >&2
        exit 1
    fi
    mv "${EXTRACTED}" "${XCFRAMEWORK_PATH}"
    echo "Installed ${XCFRAMEWORK_PATH}"
fi

ONNX_DEST="${VENDOR_DIR}/onnxruntime"
if [[ ! -f "${ONNX_DEST}/lib/libonnxruntime.a" ]]; then
    echo "Downloading ${ONNX_URL} ..."
    curl -fL --retry 3 --retry-delay 2 -C - -o "${TMP_DIR}/${ONNX_ARCHIVE}" "${ONNX_URL}"
    rm -rf "${ONNX_DEST}"
    mkdir -p "${ONNX_DEST}"
    unzip -q "${TMP_DIR}/${ONNX_ARCHIVE}" -d "${TMP_DIR}/onnx-extract"
    ONNX_LIB="$(find "${TMP_DIR}/onnx-extract" -name 'libonnxruntime.a' | head -1)"
    if [[ -z "${ONNX_LIB}" ]]; then
        echo "ERROR: libonnxruntime.a not found in ${ONNX_ARCHIVE}" >&2
        exit 1
    fi
    mkdir -p "${ONNX_DEST}/lib"
    cp "${ONNX_LIB}" "${ONNX_DEST}/lib/libonnxruntime.a"
    echo "Installed ${ONNX_DEST}/lib/libonnxruntime.a"
fi

ensure_punctuation_model

link_bridge_artifacts
echo "VocaMacSherpaBridge artifacts linked"
