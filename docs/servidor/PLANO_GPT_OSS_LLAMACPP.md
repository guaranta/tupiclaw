# Plano: GPT-OSS 20B via llama.cpp no servidor OMTX

Branch: `servidor/gpt-oss-20b-llamacpp`

## Objetivo

Configurar o OpenClaw (rodando em Docker no servidor) para consumir o modelo **GPT-OSS 20B** servido localmente via **llama.cpp**.

## Pré-requisitos

- [x] OpenClaw build Docker OK (`./docker-setup.sh`)
- [ ] llama.cpp server rodando no host com API OpenAI-compatível
- [ ] Modelo GPT-OSS 20B carregado no llama.cpp
- [ ] Porta exposta (padrão: 8080)

## Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│ Host (servidor)                                              │
│  ├─ llama.cpp server (porta 8080) → GPT-OSS 20B              │
│  └─ Docker daemon                                            │
│       └─ Container OpenClaw                                  │
│            └─ Gateway → HTTP 172.17.0.1:8080 (ou host)       │
└─────────────────────────────────────────────────────────────┘
```

## Sequência de implementação

### 1. Validar llama.cpp no host

```bash
# No host, fora do container
curl -s http://127.0.0.1:8080/v1/models
# Deve listar o modelo (ex: gpt-oss-20b ou similar)
```

Se a porta for diferente, ajuste o `baseUrl` no config.

### 2. Configurar provider no OpenClaw

Usando Docker Compose:

```bash
cd /mnt/nvme1n1/projects/omtx_claw/tupiclaw

# Definir baseUrl (host a partir do container)
docker compose run --rm openclaw-cli config set models.providers.llamacpp.baseUrl "http://172.17.0.1:8080/v1"
docker compose run --rm openclaw-cli config set models.providers.llamacpp.apiKey "llamacpp-local"
docker compose run --rm openclaw-cli config set models.providers.llamacpp.api "openai-completions"
```

Ou editar `$OPENCLAW_CONFIG_DIR/openclaw.json` diretamente (ver bloco JSON abaixo).

### 3. Definir modelo GPT-OSS 20B

O `id` do modelo deve corresponder ao retornado por `/v1/models`. Exemplo:

```bash
docker compose run --rm openclaw-cli config set agents.defaults.model.primary "llamacpp/gpt-oss-20b"
```

Se o ID no servidor for diferente (ex: `gpt-oss:20b`), use esse valor.

### 4. Config completo (referência)

```json5
{
  "gateway": {
    "mode": "local",
    "bind": "lan",
    "auth": { "token": "<seu-token>" }
  },
  "models": {
    "mode": "merge",
    "providers": {
      "llamacpp": {
        "baseUrl": "http://172.17.0.1:8080/v1",
        "apiKey": "llamacpp-local",
        "api": "openai-completions",
        "models": [
          {
            "id": "gpt-oss-20b",
            "name": "GPT-OSS 20B",
            "reasoning": false,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 32768,
            "maxTokens": 8192
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": { "primary": "llamacpp/gpt-oss-20b" }
    }
  }
}
```

**Ajustes possíveis:**

- `contextWindow`: confira o valor suportado pelo modelo (GPT-OSS 20B costuma ter ~32k)
- `maxTokens`: limite por resposta
- `id`: deve bater com o retorno de `/v1/models`

### 5. Reiniciar gateway

```bash
docker compose up -d openclaw-gateway --force-recreate
```

### 6. Validar

```bash
docker compose run --rm openclaw-cli models list
docker compose exec openclaw-gateway node dist/index.js health --token "$OPENCLAW_GATEWAY_TOKEN"
```

Enviar uma mensagem de teste via canal configurado (Telegram, WhatsApp, etc.).

## Variáveis de ambiente (opcional)

Para centralizar a URL do llama.cpp:

```bash
# .env no diretório do projeto
OPENCLAW_LLAMACPP_BASE_URL=http://172.17.0.1:8080/v1
```

Depois use `"baseUrl": "${OPENCLAW_LLAMACPP_BASE_URL}"` no config (ou mantenha hardcoded).

## Próximos passos (futuro)

- [ ] Fallback para modelo em nuvem (ex: Anthropic) se llama.cpp estiver indisponível
- [ ] Tune de `contextWindow`/`maxTokens` conforme uso real
- [ ] Monitorar latência e considerar cache/otimizações no llama.cpp

## Docs relacionados

- [llama.cpp provider](/providers/llamacpp)
- [Local models](/gateway/local-models)
- [Model providers](/concepts/model-providers)
