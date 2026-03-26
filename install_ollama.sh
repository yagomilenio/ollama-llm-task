#!/usr/bin/env bash

set -euo pipefail


# instalar ollama
if command -v ollama &>/dev/null; then
    echo "[INSTALL] Instalando Ollama en $OLLAMA_HOME..."
else
    echo "[INSTALL] Instalando Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
    echo "[INFO] Ollama instalado"
fi