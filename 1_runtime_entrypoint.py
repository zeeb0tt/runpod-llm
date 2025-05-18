#!/usr/bin/env python3

import os
import subprocess

def main():
    # Run the appropriate setup script based on the LLM_BACKEND environment variable
    backend = os.environ.get("LLM_BACKEND", "ollama").lower()
    if backend == "llama.cpp":
        script = "/app/2_runtime_setup_llamacpp.sh"
    else:
        script = "/app/2_runtime_setup_ollama.sh"

    print(f"Running {script}")
    subprocess.run(["/bin/sh", script])

if __name__ == "__main__":
    main()
