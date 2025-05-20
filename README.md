# Runpod-LLM

**Runpod-LLM** provides ready-to-use container scripts for running large language models (LLMs) easily on [RunPod](https://runpod.io?ref=ov0r4j9r). You can choose between two popular backends: **Ollama** and **llama.cpp**.

## 🚀 Features

- **Easy Setup**: Quickly deploy LLMs using Docker.
- **Flexible**: Supports Ollama and llama.cpp backends.
- **RunPod Modes**: Use serverless mode or POD mode as needed.

## 🛠 Installation

### Using Docker Hub Images:

Pull a pre-built image from Docker Hub:

```bash
docker pull zeeb0t/runpod-llm:ollama-qwen3-4b-q4_k_m

Pre-built images: https://hub.docker.com/r/zeeb0t/runpod-llm/tags
```

### Building Your Own Image:

```bash
docker build --tag yourname/runpod-llm:your-tag --push .
```

## ⚙️ Configuration

Customize your deployment by setting these environment variables in your Dockerfile:

### Common Variables

| Variable                          | Description                                                                                           | Example         |
|-----------------------------------|-------------------------------------------------------------------------------------------------------|-----------------|
| `RUNPOD_LLM_SERVERLESS`           | RunPod mode: `1` for serverless, `-1` for POD mode.                                                   | `1`             |
| `RUNPOD_LLM_BACKEND`              | Backend selection: `ollama` or `llama.cpp`.                                                           | `ollama`        |
| `RUNPOD_LLM_MODEL_DIR`            | Directory path to store model files.                                                                  | `/app/models`   |
| `RUNPOD_LLM_MODEL_ALIAS`          | Alias to serve your model with.                                                                       | `llm-model`     |
| `RUNPOD_LLM_FLASH_ATTENTION`      | Flash attention optimization (`1` enable, `-1` disable).                                              | `1`             |
| `RUNPOD_LLM_CONTEXT_LIMIT`        | Custom context length (`0` default).                                                                  | `40960`         |
| `RUNPOD_LLM_CACHE_QUANTIZATION`   | Cache quantization type: `f32`, `f16`, `bf16`, `q8_0`, `q4_0`, `q4_1`, `iq4_nl`, `q5_0`, or `q5_1`.   | `q8_0`          |

### Backend-Specific Variables

**For Ollama Backend:**

| Variable                         | Description                                       | Example             |
|----------------------------------|---------------------------------------------------|---------------------|
| `RUNPOD_LLM_OLLAMA_MODEL_NAME`   | Name of the Ollama model to pull and run.         | `qwen3:4b-q4_K_M`   |
| `OLLAMA_KEEP_ALIVE`              | Keep model loaded (`1`) or disable (`-1`).        | `-1`                |
| `OLLAMA_SCHED_SPREAD`            | GPU usage: all GPUs (`1`) or single GPU (`-1`).   | `1`                 |

**For llama.cpp Backend:**

| Variable                          | Description                                          | Example                                                                                       |
|-----------------------------------|------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| `RUNPOD_LLM_MODEL_DOWNLOAD_URL`   | URL for downloading the model file (Hugging Face).   | `https://huggingface.co/Qwen/Qwen3-4B-GGUF/resolve/main/Qwen3-4B-Q4_K_M.gguf?download=true`   |
| `RUNPOD_LLM_MODEL_FILE_NAME`      | Name for the downloaded model file locally.          | `Qwen3-4B-Q4_K_M.gguf`                                                                        |

## 📌 Example Usage

Once your RunPod instance is running, interact with your deployed LLM using RunPod’s `/run` or `/runsync` API endpoints.

### Sample Request JSON:

```json
{
  "input": {
    "path": "/v1/chat/completions",
    "payload": {
      "model": "llm-model",
      "temperature": 0.6,
      "top_p": 0.95,
      "presence_penalty": 1.5,
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

Replace `"model": "llm-model"` with the alias you've set in `RUNPOD_LLM_MODEL_ALIAS`.

## 💡 Sponsor

This project is sponsored by InstantAPI.ai, a powerful [Web Scraping API](https://web.instantapi.ai/) designed for simplicity:

- **No HTML selectors** needed
- **Automatic CAPTCHA handling**
- **No setup or maintenance**
- **Clean JSON data** delivered directly to you

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for full details.