#!/usr/bin/env bash
# Comandos para rodar no servidor
# Copie e cole estes comandos no terminal do servidor

set -euo pipefail

echo "======================================================"
echo "OPENCLAW DOCKER SETUP - SERVIDOR"
echo "======================================================"
echo ""

# Variáveis
PROJECT_DIR="/mnt/nvme1n1/projects/omtx_claw/tupiclaw"
DATA_DIR="/mnt/nvme1n1/openclaw-data"
WORKSPACE_DIR="/mnt/nvme1n1/openclaw-data/workspace"

echo "==> 1. Verificando estrutura de diretórios"
echo "Projeto: $PROJECT_DIR"
echo "Dados:   $DATA_DIR"
echo ""

# Navegar para projeto
cd "$PROJECT_DIR"
echo "✅ Diretório do projeto: $(pwd)"
echo ""

echo "==> 2. Criando diretórios de dados"
sudo mkdir -p "$DATA_DIR/workspace"
sudo mkdir -p "$DATA_DIR/identity"
sudo mkdir -p "$DATA_DIR/agents/main/agent"
sudo mkdir -p "$DATA_DIR/agents/main/sessions"
echo "✅ Diretórios criados"
echo ""

echo "==> 3. Ajustando permissões (uid 1000)"
sudo chown -R 1000:1000 "$DATA_DIR"
echo "✅ Permissões ajustadas"
echo ""

echo "==> 4. Configurando variáveis de ambiente"
export OPENCLAW_CONFIG_DIR="$DATA_DIR"
export OPENCLAW_WORKSPACE_DIR="$WORKSPACE_DIR"
export OPENCLAW_GATEWAY_PORT=18789
export OPENCLAW_GATEWAY_BIND="lan"

echo "OPENCLAW_CONFIG_DIR=$OPENCLAW_CONFIG_DIR"
echo "OPENCLAW_WORKSPACE_DIR=$OPENCLAW_WORKSPACE_DIR"
echo "OPENCLAW_GATEWAY_PORT=$OPENCLAW_GATEWAY_PORT"
echo "OPENCLAW_GATEWAY_BIND=$OPENCLAW_GATEWAY_BIND"
echo ""

echo "==> 5. Verificando Docker"
docker --version || { echo "❌ Docker não encontrado"; exit 1; }
docker compose version || { echo "❌ Docker Compose não encontrado"; exit 1; }
echo "✅ Docker OK"
echo ""

echo "==> 6. Verificando correções TypeScript aplicadas"
PENDING=$(grep -r "onPayload: (payload) =>" src/agents/ 2>/dev/null | wc -l || echo 0)
if [ "$PENDING" -gt 0 ]; then
  echo "⚠️  Ainda há $PENDING callbacks pendentes"
  echo ""
  echo "Opções:"
  echo "  A) Aplicar patch: patch -p1 < openclaw-typescript-fixes.patch"
  echo "  B) Rodar script: ./fix-typescript-callbacks.sh"
  echo "  C) Aplicar correções manualmente conforme GUIA_APLICACAO_SERVIDOR.md"
  echo ""
  read -p "Deseja continuar mesmo assim? (s/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Abortado. Aplique as correções primeiro."
    exit 1
  fi
else
  echo "✅ Correções TypeScript aplicadas"
fi
echo ""

echo "==> 7. Iniciando Docker build e setup"
echo "Isso vai:"
echo "  - Buildar imagem Docker (instala node_modules dentro do container)"
echo "  - Rodar onboarding wizard"
echo "  - Subir gateway"
echo ""
echo "Tempo estimado: 5-15 minutos (dependendo da máquina)"
echo ""
read -p "Pressione ENTER para continuar ou CTRL+C para cancelar"
echo ""

# Rodar setup
./docker-setup.sh

echo ""
echo "======================================================"
echo "✅ SETUP COMPLETO!"
echo "======================================================"
echo ""
echo "Gateway rodando em: http://127.0.0.1:18789"
echo ""
echo "Para pegar URL com token:"
echo "  docker compose run --rm openclaw-cli dashboard --no-open"
echo ""
echo "Para verificar status:"
echo "  docker compose ps"
echo "  docker compose logs openclaw-gateway"
echo ""
echo "Dados persistentes em: $DATA_DIR"
echo ""
