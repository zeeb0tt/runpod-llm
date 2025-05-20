#!/bin/bash

# Install llama.cpp Python binding
echo "Installing llama.cpp Python binding..."
CMAKE_ARGS="-DGGML_CUDA=on -DGGML_CUDA_FA_ALL_QUANTS=ON" pip3 install --root-user-action=ignore llama-cpp-python[server]

# Start llama.cpp server
echo "Starting llama.cpp server..."

# Set the model path and alias
MODEL_PATH="${RUNPOD_LLM_MODEL_DIR}/${RUNPOD_LLM_MODEL_FILE_NAME}"
ARGS="--model ${MODEL_PATH} --model_alias ${RUNPOD_LLM_MODEL_ALIAS}"

# Offload all layers to GPU where possible
ARGS="${ARGS} --n_gpu_layers -1"

# Enable flash attention: 1 = enabled, 0 = disabled
if [ -n "${RUNPOD_LLM_FLASH_ATTENTION}" ]; then
    if [ "${RUNPOD_LLM_FLASH_ATTENTION}" = "1" ]; then
        ARGS="${ARGS} --flash_attn True"
    else
        ARGS="${ARGS} --flash_attn False"
    fi
fi

# Set the split mode to row
# LLAMA_SPLIT_MODE_NONE = 0
# LLAMA_SPLIT_MODE_LAYER = 1
# LLAMA_SPLIT_MODE_ROW = 2
ARGS="${ARGS} --split_mode 2"

# Set the context limit: 0 = model default, any other value = custom
if [ -n "${RUNPOD_LLM_CONTEXT_LIMIT}" ]; then
    ARGS="${ARGS} --n_ctx ${RUNPOD_LLM_CONTEXT_LIMIT}"
fi

# Set the quantization type
if [ -n "${RUNPOD_LLM_CACHE_QUANTIZATION}" ]; then
    # Map quantization string to integer value
    case "${RUNPOD_LLM_CACHE_QUANTIZATION}" in
        "f32")     QUANT_VALUE=0  ;;
        "f16")     QUANT_VALUE=1  ;;
        "bf16")    QUANT_VALUE=32 ;;
        "q8_0")    QUANT_VALUE=7  ;;
        "q4_0")    QUANT_VALUE=2  ;;
        "q4_1")    QUANT_VALUE=3  ;;
        "iq4_nl")  QUANT_VALUE=25 ;;
        "q5_0")    QUANT_VALUE=8  ;;
        "q5_1")    QUANT_VALUE=9  ;;
        *)          QUANT_VALUE=1  ;;
    esac
    
    ARGS="${ARGS} --type_k ${QUANT_VALUE} --type_v ${QUANT_VALUE}"
fi

# Set the host and port
ARGS="${ARGS} --host 0.0.0.0 --port 11434"

# Start the server
python3 -m llama_cpp.server $ARGS > /app/runtime_llamacpp.log 2>&1 &
sleep 10

if [ "$RUNPOD_LLM_SERVERLESS" = "1" ]; then
    echo "Starting the RunPod serverless handler..."
    python3 -u /app/3_runtime_runpod_serverless.py
else
    echo "Keeping the container running..."
    tail -f /dev/null
fi
