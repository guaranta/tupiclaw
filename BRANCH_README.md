# Branch: servidor/fix-typescript-callbacks

## 🎯 Objetivo

Esta branch contém todas as correções necessárias para resolver os erros de build TypeScript no servidor relacionados aos callbacks `onPayload` que esperavam 2 argumentos mas recebiam apenas 1.

## 📦 O que está incluído

### Correções de Código (8 arquivos)
- ✅ `src/agents/anthropic-payload-log.ts`
- ✅ `src/agents/openai-ws-stream.ts`
- ✅ `src/agents/pi-embedded-runner/anthropic-stream-wrappers.ts`
- ✅ `src/agents/pi-embedded-runner/extra-params.ts`
- ✅ `src/agents/pi-embedded-runner/moonshot-stream-wrappers.ts`
- ✅ `src/agents/pi-embedded-runner/openai-stream-wrappers.ts`
- ✅ `src/agents/pi-embedded-runner/proxy-stream-wrappers.ts`
- ✅ `src/agents/pi-embedded-runner/run/attempt.ts`

### Ferramentas de Deployment (6 arquivos)
- 📄 `README_CORRECOES.md` - Sumário executivo
- 📄 `GUIA_APLICACAO_SERVIDOR.md` - Guia completo de aplicação
- 📄 `CORRECOES_SERVIDOR.md` - Documentação técnica detalhada
- 🔧 `openclaw-typescript-fixes.patch` - Patch Git pronto para aplicar
- 🔧 `fix-typescript-callbacks.sh` - Script automatizado de correção
- 🔧 `servidor-setup.sh` - Script completo de setup no servidor

## 🚀 Como usar no servidor

### Opção 1: Clone/Pull desta branch

```bash
# No servidor
cd /mnt/nvme1n1/projects/omtx_claw/tupiclaw

# Se já tem o repo, fetch a nova branch
git fetch origin servidor/fix-typescript-callbacks

# Checkout da branch
git checkout servidor/fix-typescript-callbacks

# Ou se ainda não tem o repo
git clone -b servidor/fix-typescript-callbacks <repo-url> tupiclaw
```

### Opção 2: Aplicar o patch

```bash
# Copiar o patch para o servidor
scp openclaw-typescript-fixes.patch servidor:/mnt/nvme1n1/projects/omtx_claw/tupiclaw/

# No servidor
cd /mnt/nvme1n1/projects/omtx_claw/tupiclaw
patch -p1 < openclaw-typescript-fixes.patch
```

### Opção 3: Script automatizado

```bash
# No servidor, na branch
./servidor-setup.sh
```

## 📋 Checklist para o Servidor

Após fazer checkout/pull desta branch:

- [ ] Verificar se está na branch correta: `git branch`
- [ ] Aplicar correções em arquivos específicos do fork (se existirem):
  - [ ] `ct-embedded-runner/moonshot-stream-wrappers.ts`
  - [ ] `ct-embedded-runner/proxy-stream-wrappers.ts`
  - [ ] `ct-embedded-runner/run/attempt.ts`
  - [ ] `condor-stream-wrappers.ts`
  - [ ] `ocenai-stream-wrappers.ts`
  - [ ] `seraph-stream-wrappers.ts`
  - [ ] `om.ts` (resolver loadPiperAIData)
- [ ] Configurar variáveis de ambiente
- [ ] Rodar `./docker-setup.sh`
- [ ] Validar build sem erros

## 🔧 Mudanças Aplicadas

**Padrão de correção:**
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

**Total:**
- 14 arquivos alterados
- 961 linhas adicionadas (documentação + scripts)
- 26 linhas modificadas (correções de código)

## 📚 Documentação

Consulte os arquivos de documentação incluídos nesta branch:

1. **README_CORRECOES.md** - Comece aqui para visão geral
2. **GUIA_APLICACAO_SERVIDOR.md** - Instruções passo a passo
3. **CORRECOES_SERVIDOR.md** - Detalhes técnicos completos

## 🎓 Contexto Técnico

### Problema
TypeScript error TS2554: "Expected 2 arguments, but got 1"

Os callbacks `onPayload` na versão 0.57.1 do `@mariozechner/pi-ai` foram atualizados para aceitar um segundo parâmetro `meta`, mas o código estava passando apenas o primeiro (`payload`).

### Solução
Atualizar todas as assinaturas de callbacks e chamadas para incluir o segundo parâmetro `meta`.

### Compatibilidade
- `@mariozechner/pi-ai`: v0.57.1
- `@mariozechner/pi-agent-core`: v0.57.1
- `@mariozechner/pi-coding-agent`: v0.57.1

## 🔗 Próximos Passos

Após aplicar esta branch no servidor e validar o build:

1. Testar gateway funcionando
2. Validar canais (WhatsApp, Telegram, etc.)
3. Se tudo OK, considerar merge para main (ou manter como branch de servidor)
4. Documentar quaisquer diferenças adicionais do fork

## 📞 Suporte

Se encontrar novos erros após aplicar esta branch:

1. Verificar se são o mesmo padrão (callbacks com 1 argumento)
2. Aplicar a mesma correção
3. Se for erro diferente, documentar e analisar nova causa

---

**Branch criada em:** 2026-03-12  
**Commit:** 37ebbbd86  
**Base:** main (ff47876e6)
