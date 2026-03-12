# ✅ Correções TypeScript Build - Resumo Executivo

## Status: Correções Aplicadas no Repo Local

✅ **8 arquivos corrigidos**  
✅ **26 linhas alteradas**  
✅ **Patch gerado**: `openclaw-typescript-fixes.patch`  
✅ **Script helper criado**: `fix-typescript-callbacks.sh`

---

## 📋 O Que Foi Corrigido

### Problema Principal: TS2554
Callbacks `onPayload` esperavam 2 argumentos mas recebiam apenas 1.

**Correção aplicada:**
```typescript
// ANTES ❌
onPayload: (payload) => {
  return originalOnPayload?.(payload);
}

// DEPOIS ✅
onPayload: (payload, meta) => {
  return originalOnPayload?.(payload, meta);
}
```

### Arquivos Corrigidos (repo local):
- `src/agents/anthropic-payload-log.ts`
- `src/agents/openai-ws-stream.ts`
- `src/agents/pi-embedded-runner/anthropic-stream-wrappers.ts`
- `src/agents/pi-embedded-runner/extra-params.ts`
- `src/agents/pi-embedded-runner/moonshot-stream-wrappers.ts`
- `src/agents/pi-embedded-runner/openai-stream-wrappers.ts`
- `src/agents/pi-embedded-runner/proxy-stream-wrappers.ts`
- `src/agents/pi-embedded-runner/run/attempt.ts`

---

## 🚀 Como Aplicar no Servidor

### Método 1: Via Patch (Mais Rápido)

```bash
# 1. Copiar o patch para o servidor
scp openclaw-typescript-fixes.patch usuario@servidor:/mnt/nvme1n1/projects/omtx_claw/tupiclaw/

# 2. No servidor, aplicar
cd /mnt/nvme1n1/projects/omtx_claw/tupiclaw
patch -p1 < openclaw-typescript-fixes.patch
```

### Método 2: Via Git (Sincronizar com Local)

```bash
# 1. Commitar mudanças no local
cd /Users/guaranta/Documents/Projetos/OMTX/open_claw/tupiclaw
git add src/agents/
git commit -m "fix: adjust onPayload callbacks to accept meta parameter (TS2554)"

# 2. Push para origin/branch
git push origin HEAD

# 3. No servidor, pull
cd /mnt/nvme1n1/projects/omtx_claw/tupiclaw
git pull origin <branch>
```

### Método 3: Via Script Automatizado

```bash
# No servidor
cd /mnt/nvme1n1/projects/omtx_claw/tupiclaw

# Copiar fix-typescript-callbacks.sh para o servidor
# Depois rodar:
./fix-typescript-callbacks.sh
```

---

## ⚠️ Arquivos Específicos do Fork (Ação Manual Necessária)

O servidor possui arquivos que não existem no repo local. Aplicar o **mesmo padrão** nestes:

### ct-embedded-runner (equivalente a pi-embedded-runner no fork)
```
src/agents/ct-embedded-runner/moonshot-stream-wrappers.ts (linhas 30, 58, 93)
src/agents/ct-embedded-runner/proxy-stream-wrappers.ts (linhas 36, 95, 141)
src/agents/ct-embedded-runner/run/attempt.ts (linha 243)
```

### Providers customizados
```
src/agents/ct-embedded-runner/condor-stream-wrappers.ts (linha 63)
src/agents/ct-embedded-runner/ocenai-stream-wrappers.ts (linha 280)
src/agents/ct-embedded-runner/seraph-stream-wrappers.ts (linha 220)
```

**Em cada um destes:**
- Trocar `onPayload: (payload) =>` por `onPayload: (payload, meta) =>`
- Trocar `originalOnPayload?.(payload)` por `originalOnPayload?.(payload, meta)`

### om.ts - Resolver import inexistente

**Arquivo:** `src/agents/openclaw/operations/om.ts` (linha 12)

**Erro:** `Module "@mariocaschner/pi-ai" has no exported member 'loadPiperAIData'`

**Solução rápida (build funcionar):**
```typescript
// Comentar o import
// import { loadPiperAIData } from "@mariozechner/pi-ai";

// E comentar uso da função no código
```

**Verificar também:**
- Package.json deve ter `@mariozechner` (com 'z'), não `@mariocaschner` (com 'c')

---

## 🏗️ Build no Servidor

Após aplicar todas as correções:

```bash
cd /mnt/nvme1n1/projects/omtx_claw/tupiclaw

# Criar diretórios de dados
sudo mkdir -p /mnt/nvme1n1/openclaw-data/workspace
sudo chown -R 1000:1000 /mnt/nvme1n1/openclaw-data

# Definir variáveis
export OPENCLAW_CONFIG_DIR=/mnt/nvme1n1/openclaw-data
export OPENCLAW_WORKSPACE_DIR=/mnt/nvme1n1/openclaw-data/workspace

# Rodar build
./docker-setup.sh
```

O script:
1. Faz build da imagem Docker (instala node_modules dentro do container)
2. Roda onboarding
3. Sobe o gateway

**Não precisa** instalar node_modules no host - tudo acontece dentro do Docker.

---

## 📦 Arquivos Gerados

| Arquivo | Descrição |
|---------|-----------|
| `openclaw-typescript-fixes.patch` | Patch completo com todas as mudanças |
| `fix-typescript-callbacks.sh` | Script para aplicação automatizada via regex |
| `CORRECOES_SERVIDOR.md` | Documentação detalhada das correções |
| `GUIA_APLICACAO_SERVIDOR.md` | Este guia |

---

## 🎯 Checklist Final

- [ ] Aplicar correções do repo local no servidor (via patch, git, ou script)
- [ ] Corrigir arquivos específicos do fork (ct-embedded-runner/*)
- [ ] Resolver om.ts (comentar ou substituir loadPiperAIData)
- [ ] Verificar package.json (@mariozechner, não @mariocaschner)
- [ ] Rodar `./docker-setup.sh` no servidor
- [ ] Validar que o build passou sem erros TS2554

---

## 📞 Se Ainda Houver Erros

1. Copiar output completo do erro
2. Verificar se é mesmo padrão (onPayload com 1 arg)
3. Aplicar mesma correção: adicionar `meta` como segundo parâmetro
4. Se for erro diferente, analisar nova causa raiz
