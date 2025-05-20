# Use RunPod's base image to avoid manual installation
FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

# Set environment variables
ENV PYTHONUNBUFFERED="1" \
    RUNPOD_LLM_SERVERLESS="1" \
    RUNPOD_LLM_BACKEND="ollama" \
    RUNPOD_LLM_MODEL_DIR="/app/models" \
    RUNPOD_LLM_OLLAMA_MODEL_NAME="gemma3:12b-it-qat" \
    RUNPOD_LLM_MODEL_DOWNLOAD_URL="https://huggingface.co/google/gemma-3-12b-it-qat-q4_0-gguf/resolve/main/gemma-3-12b-it-q4_0.gguf?download=true" \
    RUNPOD_LLM_MODEL_FILE_NAME="gemma-3-12b-it-q4_0.gguf" \
    RUNPOD_LLM_MODEL_ALIAS="llm-model" \
    \
    OLLAMA_KEEP_ALIVE="-1" \
    OLLAMA_SCHED_SPREAD="1" \
    \
    RUNPOD_LLM_FLASH_ATTENTION="-1" \
    RUNPOD_LLM_CONTEXT_LIMIT="128000" \
    RUNPOD_LLM_CACHE_QUANTIZATION=""

# Set Ollama-specific environment variables
ENV OLLAMA_MODELS="${RUNPOD_LLM_MODEL_DIR}" \
    OLLAMA_FLASH_ATTENTION="${RUNPOD_LLM_FLASH_ATTENTION}" \
    OLLAMA_KV_CACHE_TYPE="${RUNPOD_LLM_CACHE_QUANTIZATION}"

# Set working directory
WORKDIR /app

# Create models directory
RUN mkdir -p "$RUNPOD_LLM_MODEL_DIR"

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    dos2unix \
    lshw \
    python3 \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Install Python modules
RUN pip3 install --root-user-action=ignore --no-cache-dir \
    runpod \
    requests

# Copy application scripts and configuration
COPY 1_runtime_entrypoint.py \
     2_runtime_setup_ollama.sh \
     2_runtime_setup_llamacpp.sh \
     3_runtime_runpod_serverless.py \
     test_input.json \
     /app/

# Convert line endings and make scripts executable
RUN dos2unix /app/* && chmod +x /app/*.py /app/*.sh

# Install Ollama if RUNPOD_LLM_BACKEND is ollama
RUN if [ "$RUNPOD_LLM_BACKEND" = "ollama" ]; then \
        curl -fsSL https://ollama.com/install.sh -o /tmp/install.sh && \
        sed -i 's|red="$(.*)"|red=""|' /tmp/install.sh && \
        sed -i 's|plain="$(.*)"|plain=""|' /tmp/install.sh && \
        chmod +x /tmp/install.sh && \
        sh -x /tmp/install.sh && \
        rm -f /tmp/install.sh; \
    fi

# Download model if RUNPOD_LLM_BACKEND is ollama
RUN if [ "$RUNPOD_LLM_BACKEND" = "ollama" ]; then \
        ollama serve > /app/buildtime_ollama.log 2>&1 & \
        sleep 10 && \
        ollama pull $RUNPOD_LLM_OLLAMA_MODEL_NAME && \
        sleep 10 && \
        pkill -f "ollama"; \
    fi

# Download model if RUNPOD_LLM_BACKEND is llama.cpp
RUN if [ "$RUNPOD_LLM_BACKEND" = "llama.cpp" ]; then \
        curl -L $RUNPOD_LLM_MODEL_DOWNLOAD_URL -o $RUNPOD_LLM_MODEL_DIR/$RUNPOD_LLM_MODEL_FILE_NAME; \
    fi

# Set the entrypoint script
ENTRYPOINT ["/app/1_runtime_entrypoint.py"]
