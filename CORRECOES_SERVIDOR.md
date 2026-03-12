# Correções TypeScript Build - Aplicar no Servidor

Este documento lista todas as mudanças necessárias para corrigir os erros de build TypeScript.

## Resumo das Mudanças

Foram corrigidos **callbacks `onPayload`** que esperavam 2 argumentos mas recebiam apenas 1.

**Padrão de correção aplicado:**
- Trocar `(payload) =>` por `(payload, meta) =>`
- Trocar `onPayload?.(payload)` por `onPayload?.(payload, meta)`

## Arquivos Corrigidos no Repo Local

### 1. `src/agents/anthropic-payload-log.ts`
- Linha ~139: `const nextOnPayload = (payload: unknown, meta?: unknown) => {`
- Linha ~148: `return options?.onPayload?.(payload, meta);`

### 2. `src/agents/pi-embedded-runner/anthropic-stream-wrappers.ts`
- Linha ~280: `onPayload: (payload, meta) => {`
- Linha ~301: `return originalOnPayload?.(payload, meta);`

### 3. `src/agents/pi-embedded-runner/extra-params.ts`
- **Função `createGoogleThinkingPayloadWrapper`** (linha ~225):
  - `onPayload: (payload, meta) => {`
  - `return onPayload?.(payload, meta);`
- **Função `createZaiToolStreamWrapper`** (linha ~261):
  - `onPayload: (payload, meta) => {`
  - `return originalOnPayload?.(payload, meta);`

### 4. `src/agents/pi-embedded-runner/moonshot-stream-wrappers.ts`
- **Função `createSiliconFlowThinkingWrapper`** (linha ~56):
  - `onPayload: (payload, meta) => {`
  - `return originalOnPayload?.(payload, meta);`
- **Função `createMoonshotThinkingWrapper`** (linha ~92):
  - `onPayload: (payload, meta) => {`
  - `return originalOnPayload?.(payload, meta);`

### 5. `src/agents/pi-embedded-runner/openai-stream-wrappers.ts`
- **Função `createOpenAIResponsesContextManagementWrapper`** (linha ~190):
  - `onPayload: (payload, meta) => {`
  - `return originalOnPayload?.(payload, meta);`
- **Função `createOpenAIServiceTierWrapper`** (linha ~222):
  - `onPayload: (payload, meta) => {`
  - `return originalOnPayload?.(payload, meta);`

### 6. `src/agents/pi-embedded-runner/proxy-stream-wrappers.ts`
- **Função `createOpenRouterSystemCacheWrapper`** (linha ~76):
  - `onPayload: (payload, meta) => {`
  - `return originalOnPayload?.(payload, meta);`
- **Função `createOpenRouterWrapper`** (linha ~114):
  - `onPayload: (payload, meta) => {`
  - `return onPayload?.(payload, meta);`
- **Função `createKilocodeWrapper`** (linha ~139):
  - `onPayload: (payload, meta) => {`
  - `return onPayload?.(payload, meta);`

### 7. `src/agents/pi-embedded-runner/run/attempt.ts`
- **Função `wrapOllamaCompatNumCtx`** (linhas ~234 e ~243):
  - `onPayload: (payload: unknown, meta?: unknown) => {`
  - `return options?.onPayload?.(payload, meta);` (2 ocorrências)

### 8. `src/agents/openai-ws-stream.ts`
- Linha ~800: `const nextPayload = options?.onPayload?.(payload, meta);`

## Arquivos Específicos do Servidor (Fork)

Aplicar o **mesmo padrão** nos arquivos que só existem no servidor:

### ct-embedded-runner (equivalente a pi-embedded-runner)
- `src/agents/ct-embedded-runner/moonshot-stream-wrappers.ts` (linhas 30, 58, 93)
- `src/agents/ct-embedded-runner/proxy-stream-wrappers.ts` (linhas 36, 95, 141)
- `src/agents/ct-embedded-runner/run/attempt.ts` (linha 243)

**Padrão de correção:**
```typescript
// ANTES
onPayload: (payload) => {
  return originalOnPayload?.(payload);
}

// DEPOIS
onPayload: (payload, meta) => {
  return originalOnPayload?.(payload, meta);
}
```

### Outros arquivos do fork mencionados nos erros
- `condor-stream-wrappers.ts` (linha 63)
- `ocenai-stream-wrappers.ts` (linha 280)
- `seraph-stream-wrappers.ts` (linha 220)

Aplicar o mesmo padrão `meta` em todos.

## Erro om.ts (arquivo específico do servidor)

**Arquivo:** `src/agents/openclaw/operations/om.ts`  
**Linha 12:** `Module "@mariocaschner/pi-ai" has no exported member 'loadPiperAIData'`

### Ações:
1. **Verificar typo no package.json**: deve ser `@mariozechner/pi-ai` (com 'z'), não `@mariocaschner`
2. **Verificar se `loadPiperAIData` existe** em `@mariozechner/pi-ai` versão 0.57.1
3. Se não existir:
   - Remover o import: `import { loadPiperAIData } from ...`
   - Comentar/remover o uso dessa função
   - Ou substituir por função equivalente

## Regex para Busca/Substituição no Servidor

Para acelerar aplicação no servidor, use regex:

### Buscar callbacks com 1 parâmetro:
```regex
onPayload:\s*\(payload\)\s*=>
```

### Substituir por:
```
onPayload: (payload, meta) =>
```

### Depois, buscar chamadas:
```regex
(originalOnPayload|onPayload)\?\.\(payload\)
```

### Substituir por:
```
$1?.(payload, meta)
```

## Checklist para Aplicar no Servidor

- [ ] Copiar todos os arquivos corrigidos do repo local para o servidor
- [ ] Aplicar correções em arquivos exclusivos do fork (ct-embedded-runner/*, condor, ocenai, seraph)
- [ ] Resolver `om.ts` - loadPiperAIData
- [ ] Verificar package.json - nome correto do pacote (@mariozechner)
- [ ] Rodar build: `./docker-setup.sh`
- [ ] Verificar que não há mais erros TS2554

## Comandos no Servidor

```bash
cd /mnt/nvme1n1/projects/omtx_claw/tupiclaw

# Definir variáveis
export OPENCLAW_CONFIG_DIR=/mnt/nvme1n1/openclaw-data
export OPENCLAW_WORKSPACE_DIR=/mnt/nvme1n1/openclaw-data/workspace

# Criar dirs (se não existir)
sudo mkdir -p /mnt/nvme1n1/openclaw-data/workspace
sudo chown -R 1000:1000 /mnt/nvme1n1/openclaw-data

# Build (após aplicar correções)
./docker-setup.sh
```

## Total de Mudanças

- **8 arquivos** corrigidos no repo local
- **~15-20 ocorrências** de callback ajustadas
- **3-5 arquivos adicionais** no fork do servidor (estimativa)
