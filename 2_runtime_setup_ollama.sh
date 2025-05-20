#!/bin/bash

# Generate the model configuration file for Ollama
echo "Generating model configuration file..."

# Create a safe filename by replacing special characters
SAFE_MODEL_NAME=$(echo "$RUNPOD_LLM_OLLAMA_MODEL_NAME" | tr -c '[:alnum:]._-' '_')
MODEL_FILE="/app/ModelFile_$SAFE_MODEL_NAME"
echo "FROM $RUNPOD_LLM_OLLAMA_MODEL_NAME" > "$MODEL_FILE"

# Set the context limit: 0 = model default, any other value = custom
if [ -n "${RUNPOD_LLM_CONTEXT_LIMIT}" ]; then
    echo "PARAMETER num_ctx $RUNPOD_LLM_CONTEXT_LIMIT" >> "$MODEL_FILE"
fi

# Start the Ollama server and redirect logs
echo "Starting the Ollama server..."
ollama serve > /app/runtime_ollama.log 2>&1 &
sleep 10  # Wait for the server to start

# Create the model using the model file
echo "Creating the model from the ModelFile..."
ollama create "$RUNPOD_LLM_MODEL_ALIAS" -f "$MODEL_FILE"

if [ "$RUNPOD_LLM_SERVERLESS" = "1" ]; then
    echo "Starting the RunPod serverless handler..."
    python3 -u /app/3_runtime_runpod_serverless.py
else
    echo "Keeping the container running..."
    tail -f /dev/null
fi
