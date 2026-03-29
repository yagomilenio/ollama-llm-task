#!/usr/bin/env bash

set -euo pipefail

MODEL="${1:-llama3.2}"


# instalar ollama
if command -v ollama &>/dev/null; then  #a pesar de que necesita accesso root se va a detectar y se va a pedir consentimiento al usuario
    echo "[INSTALL] Instalando Ollama"
else
    echo "[INSTALL] Instalando Ollama..."
    sh install.sh
    echo "[INFO] Ollama instalado"
fi

# iniciar servicio
if ! curl -sf http://localhost:11434/api/tags &>/dev/null; then
    echo "[INFO] Arrancando servidor Ollama en background..."
    ollama serve &>/tmp/ollama.log &
    OLLAMA_PID=$!
    echo "[INFO] PID del servidor: $OLLAMA_PID"
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
echo "    make run WORD=\"Hola mundo\""
echo ""
