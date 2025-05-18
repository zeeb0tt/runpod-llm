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
        "RUNPOD_SERVERLESS": 1
    }

    # Update default config with provided config
    default_config.update(config)

    # Set environment variables
    for key, value in default_config.items():
        os.environ[key] = str(value)
        print(f"Set environment variable {key}={value}")

    print("Running 2_runtime_setup_ollama.sh")
    subprocess.run(["/bin/sh", "/app/2_runtime_setup_ollama.sh"])

if __name__ == "__main__":
    main()
