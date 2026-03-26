#!/usr/bin/env bash

set -euo pipefail

MODEL="${1:-llama3.2}"

# iniciar servicio
if ! curl -sf http://localhost:11434/api/tags &>/dev/null; then
    echo "[INSTALL] Arrancando servidor Ollama en background..."
    ollama serve &>/tmp/ollama.log &
    OLLAMA_PID=$!
    echo "[INSTALL] PID del servidor: $OLLAMA_PID"
    sleep 3
fi

# descargar modelo
echo "[INSTALL] Descargando modelo: $MODEL"
ollama pull "$MODEL"
echo "[INFO] Modelo $MODEL listo"

# instalar dependencias
echo "[INSTALL] Instalando dependencias Python..."
npm install axios yaml
echo "[INFO] Dependencias instaladas"

echo ""
echo "[INFO] Setup completado. Puedes hacer:"
echo "    make test"
echo "    make run START=0 END=9"
echo ""
