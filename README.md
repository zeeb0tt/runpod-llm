# Runpod-LLM

This repository provides container scripts for running large language models (LLMs) on [RunPod](https://runpod.io?ref=ov0r4j9r). It includes setup for *Ollama* and *llama.cpp* backends, allowing you to choose the model backend that best suits your workflow.

## Project Sponsor

This project is sponsored by [InstantAPI.ai](https://web.instantapi.ai/), a Web Scraping API with no selectors, no CAPTCHAs, zero maintenance-just clean JSON results.

## Configuration

Configuration is primarily controlled through environment variables in Dockerfile. Key options include:

- `LLM_BACKEND` – Select `llama.cpp` or `ollama`.
- `LLM_MODEL_DIR`, `OLLAMA_MODELS` – Directory where your model files are stored.
- `LLM_MODEL_DOWNLOAD_URL`, `LLM_MODEL_FILE_NAME` – Download URL and name of the local model file (for *llama.cpp* backend).
- `LLM_MODEL_OLLAMA_NAME` – Name of the model to pull when using *Ollama*.
- `LLM_MODEL_ALIAS` – Alias used when serving the model.
- `LLM_MODEL_CONTEXT_LIMIT` – Maximum token context length.
- `CPU_THREADS` – Number of CPU threads for *llama.cpp* (optional).
- `GPU_LAYERS` – GPU layer count for *llama.cpp* (optional).

Refer to the Dockerfile for additional environment variables and their default values.

## Docker Images

Prebuilt container images for this project are available on Docker Hub: <https://hub.docker.com/r/zeeb0t/runpod-llm>

Build a new image with:

```bash
docker build --tag you/your-repostitory:your-tag --push .
```

## Making a Request

Once you have your RunPod instance running, you can make a request to the RunPod run/runsync endpoints with the following JSON payload:

```json
{
  "input": {
    "path": "/v1/chat/completions",
    "payload": {
      "model": "llm-model",
      "temperature": 0.6,
      "top_p": 0.95,
      "presence_penalty": 1.5,
      "max_tokens": 32768,
      "messages": [
        {
          "role": "system",
          "content": "/think\n\nWhat is the meaning of life?"
        }
      ]
    }
  }
}
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
