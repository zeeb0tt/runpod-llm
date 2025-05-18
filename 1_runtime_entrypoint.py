#!/usr/bin/env python3

import sys
import os
import json
import subprocess
import time

def main():
    # Check if an argument is provided
    if len(sys.argv) > 1:
        arg = sys.argv[1]
        print(f"Argument provided: {arg}")
        try:
            config = json.loads(arg)
        except json.JSONDecodeError as e:
            print(f"Error parsing JSON: {e}")
            config = {}
    else:
        print("No argument provided. Using default settings.")
        config = {}

    # Set default values
    default_config = {
        "LLM_MODEL_NAME": "hf.co/Qwen/Qwen3-30B-A3B-GGUF:Q8_0",
        "LLM_CONTEXT_LIMIT": 32768,
        "OLLAMA_KEEP_ALIVE": -1,
        "OLLAMA_FLASH_ATTENTION": 1,
        "OLLAMA_SCHED_SPREAD": 1,
        "RUNPOD_SERVERLESS": 1,
        "LLM_BACKEND": "ollama",
        "LLAMA_CPP_THREADS": 8,
        "LLAMA_CPP_GPU_LAYERS": 0
    }

    # Update default config with provided config
    default_config.update(config)

    # Set environment variables
    for key, value in default_config.items():
        os.environ[key] = str(value)
        print(f"Set environment variable {key}={value}")

    backend = os.environ.get("LLM_BACKEND", "ollama").lower()
    if backend == "llamacpp" or backend == "llama.cpp" or backend == "llama_cpp":
        script = "/app/2_runtime_setup_llamacpp.sh"
    else:
        script = "/app/2_runtime_setup_ollama.sh"

    print(f"Running {script}")
    subprocess.run(["/bin/sh", script])

if __name__ == "__main__":
    main()
