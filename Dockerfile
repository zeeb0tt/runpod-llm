# Use RunPod's base image to avoid manual installation
FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    RUNPOD_SERVERLESS=1 \
    LLM_BACKEND="llama.cpp" \
    LLM_MODEL_DIR=/app/models \
    OLLAMA_MODELS=/app/models \
    OLLAMA_DIR=/app/ollama \
    LLM_MODEL_OLLAMA_NAME="hf.co/Qwen/Qwen3-0.6B-GGUF:Q8_0" \
    LLM_MODEL_DOWNLOAD_URL="https://huggingface.co/Qwen/Qwen3-0.6B-GGUF/resolve/main/Qwen3-0.6B-Q8_0.gguf?download=true" \
    LLM_MODEL_FILE_NAME="Qwen3-0_6B-GGUF-Q8_0.gguf" \
    LLM_CHAT_FORMAT="qwen" \
    LLM_MODEL_ALIAS="llm-model" \
    LLM_MODEL_CONTEXT_LIMIT=32768 \
    OLLAMA_KEEP_ALIVE=-1 \
    OLLAMA_FLASH_ATTENTION=1 \
    OLLAMA_SCHED_SPREAD=1 \
    FLASH_ATTENTION=1 \
    CPU_THREADS=-1 \
    GPU_LAYERS=-1

# Set working directory
WORKDIR /app

# Create models directory
RUN mkdir -p "$LLM_MODEL_DIR"

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    dos2unix \
    lshw \
    python3 \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Install Python modules
RUN pip3 install --no-cache-dir \
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

# Install Ollama if LLM_BACKEND is ollama
RUN if [ "$LLM_BACKEND" = "ollama" ]; then \
        curl -fsSL https://ollama.com/install.sh -o /tmp/install.sh && \
        sed -i 's|red="$(.*)"|red=""|' /tmp/install.sh && \
        sed -i 's|plain="$(.*)"|plain=""|' /tmp/install.sh && \
        chmod +x /tmp/install.sh && \
        sh -x /tmp/install.sh && \
        rm -f /tmp/install.sh; \
    fi

# Download model if LLM_BACKEND is ollama
RUN if [ "$LLM_BACKEND" = "ollama" ]; then \
        ollama serve > /app/buildtime_ollama.log 2>&1 & \
        sleep 10 && \
        ollama pull $LLM_MODEL_OLLAMA_NAME && \
        sleep 10 && \
        pkill -f "ollama"; \
    fi

# Download model if LLM_BACKEND is llama.cpp
RUN if [ "$LLM_BACKEND" = "llama.cpp" ]; then \
        curl -L $LLM_MODEL_DOWNLOAD_URL -o $LLM_MODEL_DIR/$LLM_MODEL_FILE_NAME; \
    fi

# Set the entrypoint script
ENTRYPOINT ["/app/1_runtime_entrypoint.py"]
