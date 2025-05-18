# Use RunPod's base image to avoid manual installation
FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    OLLAMA_MODELS=/app/models \
    OLLAMA_DIR=/app/ollama

# Set working directory
WORKDIR /app

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
     3_runtime_runpod_serverless.py \
     test_input.json \
     /app/

# Convert line endings and make scripts executable
RUN dos2unix /app/* && chmod +x /app/*.py /app/*.sh

# Step 1: Download the script
RUN curl -fsSL https://ollama.com/install.sh -o /tmp/install.sh

# Step 2: Remove tput
RUN sed -i 's|red="$(.*)"|red=""|' /tmp/install.sh
RUN sed -i 's|plain="$(.*)"|plain=""|' /tmp/install.sh

# Step 3: Set execute permissions
RUN chmod +x /tmp/install.sh

# Step 4: Execute the script
RUN sh -x /tmp/install.sh

# Step 5: Clean up
RUN rm -f /tmp/install.sh

# Download model files
RUN ollama serve > /app/buildtime_ollama.log 2>&1 & \
    sleep 10 && \
    ollama pull hf.co/Qwen/Qwen3-30B-A3B-GGUF:Q8_0 && \
    sleep 10 && \
    pkill -f "ollama"

# Set the entrypoint script
ENTRYPOINT ["/app/1_runtime_entrypoint.py"]

# Define the default command
CMD ["{\"LLM_MODEL_NAME\":\"hf.co/Qwen/Qwen3-30B-A3B-GGUF:Q8_0\",\"LLM_CONTEXT_LIMIT\":32768,\"OLLAMA_KEEP_ALIVE\":-1,\"OLLAMA_FLASH_ATTENTION\":1,\"OLLAMA_SCHED_SPREAD\":1,\"RUNPOD_SERVERLESS\":1}"]
