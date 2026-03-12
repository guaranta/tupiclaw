---
summary: "Run OpenClaw with llama.cpp (OpenAI-compatible local server)"
read_when:
  - You want to run OpenClaw against a local llama.cpp server
  - You serve models via llama.cpp or llama-cpp-python
title: "llama.cpp"
---

# llama.cpp

llama.cpp provides a native HTTP server and llama-cpp-python provides a Python-based server, both exposing **OpenAI-compatible** `/v1` endpoints. OpenClaw can connect to either using the `openai-completions` API.

Use this provider when you run models directly with llama.cpp (e.g. GPT-OSS, LLaMA, Mistral) instead of via Ollama or vLLM.

## Quick start

1. Start the llama.cpp server with an OpenAI-compatible endpoint.

The server typically runs on port **8080** (llama.cpp native) or another configured port. Ensure it exposes:

- `GET /v1/models`
- `POST /v1/chat/completions`

2. Configure OpenClaw with explicit provider (no auto-discovery):

```json5
{
  models: {
    providers: {
      llamacpp: {
        baseUrl: "http://127.0.0.1:8080/v1",
        apiKey: "llamacpp-local",
        api: "openai-completions",
        models: [
          {
            id: "gpt-oss-20b",
            name: "GPT-OSS 20B",
            reasoning: false,
            input: ["text"],
            cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
            contextWindow: 32768,
            maxTokens: 8192,
          },
        ],
      },
    },
  },
  agents: {
    defaults: {
      model: { primary: "llamacpp/gpt-oss-20b" },
    },
  },
}
```

3. Verify the server is reachable:

```bash
curl http://127.0.0.1:8080/v1/models
```

## Docker (OpenClaw in container, llama.cpp on host)

When OpenClaw runs inside Docker and llama.cpp runs on the host:

- **Linux**: use the Docker bridge gateway IP (typically `172.17.0.1`)
- **Docker Desktop (Mac/Windows)**: use `host.docker.internal`

```json5
{
  models: {
    providers: {
      llamacpp: {
        baseUrl: "http://172.17.0.1:8080/v1",
        apiKey: "llamacpp-local",
        api: "openai-completions",
        models: [
          {
            id: "gpt-oss-20b",
            name: "GPT-OSS 20B",
            reasoning: false,
            input: ["text"],
            cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
            contextWindow: 32768,
            maxTokens: 8192,
          },
        ],
      },
    },
  },
}
```

## Model ID

The `id` in the models array must match the model ID returned by your llama.cpp server at `/v1/models`. If your server reports a different ID (e.g. `gpt-oss:20b` or the full path name), use that value.

## Tool calling

llama.cpp server supports function calling / tool use when built with the appropriate flags. If tool calling fails, ensure your llama.cpp build includes OpenAI-compatible tool support and that the model was trained for function calling.

## Troubleshooting

- **Connection refused**: Ensure the llama.cpp server is running and bound to the correct interface (`0.0.0.0` if accessible from Docker).
- **404 on /v1/models**: Some builds use different base paths; confirm the exact URL (e.g. `http://host:8080/v1` vs `http://host:8080`).
- **Tool calling issues**: Check [llama.cpp server docs](https://github.com/ggerganov/llama.cpp/tree/master/examples/server) for OpenAI compatibility and tool-use support.
