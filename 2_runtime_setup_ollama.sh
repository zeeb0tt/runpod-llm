#!/bin/bash

# Generate the model configuration file for Ollama
echo "Generating model configuration file..."
# Create a safe filename by replacing special characters
SAFE_MODEL_NAME=$(echo "$LLM_MODEL_NAME" | tr -c '[:alnum:]._-' '_')
MODEL_FILE="/app/ModelFile_$SAFE_MODEL_NAME"
echo "FROM $LLM_MODEL_NAME" > "$MODEL_FILE"
echo "PARAMETER num_ctx $LLM_CONTEXT_LIMIT" >> "$MODEL_FILE"

# Start the Ollama server and redirect logs
echo "Starting the Ollama server..."
ollama serve > /app/runtime_ollama.log 2>&1 &
sleep 10  # Wait for the server to start

# Create the model using the model file
echo "Creating the model from the ModelFile..."
ollama create llm-model -f "$MODEL_FILE"

if [ "$RUNPOD_SERVERLESS" = "1" ]; then
    echo "Starting the RunPod serverless handler..."
    python3 -u /app/3_runtime_runpod_serverless.py
else
    echo "Keeping the container running..."
    tail -f /dev/null
fi
