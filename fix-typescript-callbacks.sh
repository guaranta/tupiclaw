#!/usr/bin/env bash
# Script para aplicar correções TypeScript no servidor
# Uso: ./fix-typescript-callbacks.sh

set -euo pipefail

echo "==> Aplicando correções de callbacks onPayload"

# Contar ocorrências antes
echo "Verificando arquivos..."
BEFORE_COUNT=$(grep -r "onPayload: (payload) =>" src/agents/ 2>/dev/null | wc -l || echo 0)
echo "  Callbacks com 1 parâmetro encontrados: $BEFORE_COUNT"

# Aplicar correções via sed
echo ""
echo "==> Aplicando correção 1/3: onPayload: (payload) => ..."

find src/agents/ -type f -name "*.ts" ! -name "*.test.ts" -exec sed -i.bak \
  's/onPayload: (payload) =>/onPayload: (payload, meta) =>/g' {} +

echo "==> Aplicando correção 2/3: originalOnPayload?.(payload)"

find src/agents/ -type f -name "*.ts" ! -name "*.test.ts" -exec sed -i.bak \
  's/originalOnPayload?\.(\(payload\))/originalOnPayload?.(payload, meta)/g' {} +

echo "==> Aplicando correção 3/3: onPayload?.(payload) [não test files]"

find src/agents/ -type f -name "*.ts" ! -name "*.test.ts" -exec sed -i.bak \
  's/\([^a-zA-Z]\)onPayload?\.(\(payload\))/\1onPayload?.(payload, meta)/g' {} +

echo "==> Aplicando correção 4/3: (payload: unknown) => com tipo explícito"

find src/agents/ -type f -name "*.ts" ! -name "*.test.ts" -exec sed -i.bak \
  's/(payload: unknown) =>/(payload: unknown, meta?: unknown) =>/g' {} +

# Remover backups
find src/agents/ -type f -name "*.ts.bak" -delete

# Contar ocorrências depois
AFTER_COUNT=$(grep -r "onPayload: (payload) =>" src/agents/ 2>/dev/null | wc -l || echo 0)
echo ""
echo "==> Resultado:"
echo "  Callbacks antes: $BEFORE_COUNT"
echo "  Callbacks depois: $AFTER_COUNT"
echo ""

if [ "$AFTER_COUNT" -eq 0 ]; then
  echo "✅ Todas as correções aplicadas com sucesso!"
else
  echo "⚠️  Ainda há $AFTER_COUNT callbacks pendentes. Verificar manualmente."
fi

echo ""
echo "==> Verificando diferenças..."
git diff --stat src/agents/ || echo "(git não disponível)"

echo ""
echo "==> Próximo passo: ./docker-setup.sh"
