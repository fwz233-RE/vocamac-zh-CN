#!/usr/bin/env bash
# stage-bundled-models.sh
# Ensures bundled Whisper Tiny (CoreML + tokenizers) and punctuation ONNX exist under Vendor/.
#
# Used by local builds and CI release/nightly pipelines so GitHub downloads ship
# with everything needed for offline first-run — no extra model downloads.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
WHISPER_DEST="${REPO_ROOT}/Vendor/whisperkit-coreml"
TINY_DIR="${WHISPER_DEST}/openai_whisper-tiny"
PUNCT_MODEL="${REPO_ROOT}/Vendor/punctuation/model.int8.onnx"

"${SCRIPT_DIR}/vendor-sherpa-onnx.sh"

needs_whisper=false
if [[ ! -d "${TINY_DIR}/MelSpectrogram.mlmodelc" ]] \
    || [[ ! -d "${TINY_DIR}/AudioEncoder.mlmodelc" ]] \
    || [[ ! -d "${TINY_DIR}/TextDecoder.mlmodelc" ]] \
    || [[ ! -f "${TINY_DIR}/tokenizer.json" ]] \
    || [[ ! -f "${TINY_DIR}/tokenizer_config.json" ]]; then
    needs_whisper=true
fi

if [[ "${needs_whisper}" == true ]]; then
    echo "Fetching bundled Whisper Tiny model (CoreML + tokenizers)..."
    if ! command -v hf >/dev/null 2>&1; then
        echo "ERROR: huggingface-cli (hf) is required. Install with: pip install huggingface_hub" >&2
        exit 1
    fi
    mkdir -p "${WHISPER_DEST}"
    hf download argmaxinc/whisperkit-coreml \
        --include "openai_whisper-tiny/*" \
        --local-dir "${WHISPER_DEST}"
    hf download openai/whisper-tiny \
        tokenizer.json tokenizer_config.json \
        --local-dir "${TINY_DIR}"
    rm -rf "${WHISPER_DEST}/.cache" "${TINY_DIR}/.cache" 2>/dev/null || true
else
    echo "Whisper Tiny bundled model already present"
fi

test -d "${TINY_DIR}/MelSpectrogram.mlmodelc"
test -d "${TINY_DIR}/AudioEncoder.mlmodelc"
test -d "${TINY_DIR}/TextDecoder.mlmodelc"
test -f "${TINY_DIR}/tokenizer.json"
test -f "${TINY_DIR}/tokenizer_config.json"
test -f "${PUNCT_MODEL}"

echo "✅ Bundled models ready:"
echo "   ${TINY_DIR}"
echo "   ${PUNCT_MODEL}"
