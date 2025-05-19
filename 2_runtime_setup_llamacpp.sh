#!/bin/bash

# Install llama.cpp Python binding
echo "Installing llama.cpp Python binding..."
CMAKE_ARGS="-DGGML_CUDA=on" pip install llama-cpp-python[server]

# Start llama.cpp server
echo "Starting llama.cpp server..."
MODEL_PATH="${LLM_MODEL_DIR}/${LLM_MODEL_FILE_NAME}"
ARGS="--model ${MODEL_PATH} --host 0.0.0.0 --port 11434 --n_ctx ${LLM_MODEL_CONTEXT_LIMIT} --model_alias ${LLM_MODEL_ALIAS} --chat_format ${LLM_CHAT_FORMAT}"

# Add arguments if they are set
if [ -n "${CPU_THREADS}" ]; then
    ARGS="$ARGS --n_threads ${CPU_THREADS}"
fi

if [ -n "${GPU_LAYERS}" ]; then
    ARGS="$ARGS --n_gpu_layers ${GPU_LAYERS}"
fi

if [ -n "${FLASH_ATTENTION}" ] && [ "${FLASH_ATTENTION}" = "1" ]; then
    ARGS="$ARGS --flash_attn ${FLASH_ATTENTION}"
fi

# Start the server
python3 -m llama_cpp.server $ARGS > /app/runtime_llamacpp.log 2>&1 &
sleep 10

if [ "$RUNPOD_SERVERLESS" = "1" ]; then
    echo "Starting the RunPod serverless handler..."
    python3 -u /app/3_runtime_runpod_serverless.py
else
    echo "Keeping the container running..."
    tail -f /dev/null
fi
