#!/bin/bash

# Start llama.cpp server as a drop-in replacement for Ollama

echo "Starting llama.cpp server..."

MODEL_PATH="/app/models/${LLM_MODEL_NAME}"
ARGS="--model ${MODEL_PATH} --host 0.0.0.0 --port 11434 --n_ctx ${LLM_CONTEXT_LIMIT}"

if [ -n "${LLAMA_CPP_THREADS}" ]; then
    ARGS="$ARGS --n_threads ${LLAMA_CPP_THREADS}"
fi

if [ -n "${LLAMA_CPP_GPU_LAYERS}" ] && [ "${LLAMA_CPP_GPU_LAYERS}" -gt 0 ]; then
    ARGS="$ARGS --n_gpu_layers ${LLAMA_CPP_GPU_LAYERS}"
fi

python3 -m llama_cpp.server $ARGS > /app/runtime_llamacpp.log 2>&1 &

sleep 10

if [ "$RUNPOD_SERVERLESS" = "1" ]; then
    echo "Starting the RunPod serverless handler..."
    python3 -u /app/3_runtime_runpod_serverless.py
else
    echo "Keeping the container running..."
    tail -f /dev/null
fi
