# Guia de Aplicação no Servidor - Correções TypeScript

## Resumo

Foram corrigidos **8 arquivos** no repo local para resolver erros TypeScript TS2554 (callbacks `onPayload` com assinatura incorreta).

**Total de mudanças**: 26 linhas alteradas (26 insertions, 26 deletions)

## Arquivos Modificados

1. `src/agents/anthropic-payload-log.ts`
2. `src/agents/openai-ws-stream.ts`
3. `src/agents/pi-embedded-runner/anthropic-stream-wrappers.ts`
4. `src/agents/pi-embedded-runner/extra-params.ts`
5. `src/agents/pi-embedded-runner/moonshot-stream-wrappers.ts`
6. `src/agents/pi-embedded-runner/openai-stream-wrappers.ts`
7. `src/agents/pi-embedded-runner/proxy-stream-wrappers.ts`
8. `src/agents/pi-embedded-runner/run/attempt.ts`

## Opção A: Aplicar via Patch (Recomendado)

### No servidor:

```bash
cd /mnt/nvme1n1/projects/omtx_claw/tupiclaw

# Copiar o patch do repo local para o servidor
# (via scp, rsync, ou copiar conteúdo manualmente)

# Aplicar o patch
patch -p1 < openclaw-typescript-fixes.patch

# Verificar aplicação
git diff --stat
```

O arquivo `openclaw-typescript-fixes.patch` foi gerado e está no repo local.

## Opção B: Aplicar Manualmente via Regex

Se não puder usar patch, use busca/substituição em um editor:

### Regex 1: Declaração de callbacks
**Buscar:**
```regex
onPayload:\s*\(payload\)\s*=>
```

**Substituir por:**
```
onPayload: (payload, meta) =>
```

### Regex 2: Chamadas de callback
**Buscar:**
```regex
(originalOnPayload|onPayload)\?\.\(payload\)([^,])
```

**Substituir por:**
```
$1?.(payload, meta)$2
```

### Regex 3: Assinatura com tipo explícito
**Buscar:**
```regex
\(payload: unknown\)\s*=>
```

**Substituir por:**
```
(payload: unknown, meta?: unknown) =>
```

## Arquivos Adicionais do Fork (Servidor Apenas)

Os erros mostram arquivos que não existem no repo local. Aplicar o mesmo padrão nestes:

### ct-embedded-runner (equivalente a pi-embedded-runner)
- `src/agents/ct-embedded-runner/moonshot-stream-wrappers.ts`
  - Linhas: 30, 58, 93
- `src/agents/ct-embedded-runner/proxy-stream-wrappers.ts`
  - Linhas: 36, 95, 141
- `src/agents/ct-embedded-runner/run/attempt.ts`
  - Linha: 243

### Outros providers customizados
- `src/agents/ct-embedded-runner/condor-stream-wrappers.ts` (linha 63)
- `src/agents/ct-embedded-runner/ocenai-stream-wrappers.ts` (linha 280)
- `src/agents/ct-embedded-runner/seraph-stream-wrappers.ts` (linha 220)

**Em todos estes arquivos:**
1. Trocar `onPayload: (payload) =>` por `onPayload: (payload, meta) =>`
2. Trocar `originalOnPayload?.(payload)` por `originalOnPayload?.(payload, meta)`
3. Trocar `onPayload?.(payload)` por `onPayload?.(payload, meta)`

## Resolver om.ts (Erro Específico do Fork)

**Arquivo:** `src/agents/openclaw/operations/om.ts`  
**Linha 12:** Import de `loadPiperAIData` não existe

### Opção 1: Comentar temporariamente
```typescript
// import { loadPiperAIData } from "@mariozechner/pi-ai";

// ... e comentar uso da função
```

### Opção 2: Verificar typo no package.json
Confirmar que está escrito:
```json
"@mariozechner/pi-ai": "0.57.1"
```

E não `@mariocaschner` (com 'c').

### Opção 3: Substituir por função equivalente
Se `loadPiperAIData` foi renomeada ou está em outro pacote, identificar substituto correto.

## Teste no Servidor

Após aplicar todas as correções:

```bash
cd /mnt/nvme1n1/projects/omtx_claw/tupiclaw

# Definir variáveis
export OPENCLAW_CONFIG_DIR=/mnt/nvme1n1/openclaw-data
export OPENCLAW_WORKSPACE_DIR=/mnt/nvme1n1/openclaw-data/workspace

# Build via Docker (não precisa de node_modules no host)
./docker-setup.sh
```

## Estrutura de Diretórios no Servidor

```
/mnt/nvme1n1/
├── projects/omtx_claw/tupiclaw/   # código do projeto
└── openclaw-data/                 # dados persistentes
    ├── identity/
    ├── agents/
    ├── credentials/
    ├── media/
    └── workspace/
```

## Validação Pós-Build

Após build bem-sucedido:

```bash
# Verificar gateway rodando
docker compose ps

# Pegar URL com token
docker compose run --rm openclaw-cli dashboard --no-open

# Acessar
# http://<IP-servidor>:18789/
```

## Mudanças Necessárias

### Resumo por tipo de mudança:

| Tipo | Ocorrências | Descrição |
|------|-------------|-----------|
| Assinatura callback | ~15x | `(payload)` → `(payload, meta)` |
| Chamada callback | ~15x | `?.(payload)` → `?.(payload, meta)` |
| Import typo | 1x | Verificar `getOAuthProviders` em oauth.ts |
| Import inexistente | 1x | Resolver `loadPiperAIData` em om.ts |

### Arquivos repo local: ✅ Corrigidos (8 arquivos)
### Arquivos fork servidor: ⏳ Aplicar manualmente (~5 arquivos adicionais)

## Próximos Passos

1. ✅ Correções aplicadas no repo local
2. ⏳ Transferir correções para o servidor
3. ⏳ Aplicar correções em arquivos específicos do fork
4. ⏳ Resolver erro `om.ts`
5. ⏳ Rodar build no servidor
6. ⏳ Validar gateway funcionando
