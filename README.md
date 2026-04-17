# ollama-llm-task
[![Ask DeepWiki](https://devin.ai/assets/askdeepwiki.png)](https://deepwiki.com/yagomilenio/ollama-llm-task)

Tarea dinámica para la **plataforma de paralelización**. Instala Ollama, descarga un modelo y ejecuta un LLM local sobre un prompt recibido como argumento, escribiendo la respuesta por stdout.

## Cómo encaja en la plataforma

```
Plataforma de paralelización
  │
  ├── lee config.toml
  │     ├── inputs.type  → dynamic   (el prompt viene como argumento)
  │     └── outputs.mode → stdout    (la respuesta se escribe por stdout)
  │
  └── lanza por cada worker:
        node app.js "¿Qué es la computación distribuida?"
        node app.js "Explica el algoritmo de Dijkstra"
        ...
```

Cada worker llama a Ollama de forma independiente. La respuesta se emite directamente por stdout, sin ficheros intermedios.

## Estructura

```
ollama-llm-task/
├── config.toml          # Configuración para la plataforma (requisitos, I/O)
├── server_config.yml    # Parámetros del servidor Ollama y del modelo
├── app.js               # Worker — recibe el prompt, llama al LLM, imprime la respuesta
├── setup.sh             # Instala Ollama, arranca el servidor y descarga el modelo
└── Makefile             # Atajos para setup, test y ejecución
```

## Requisitos

- Node.js y npm
- `curl`, `zstd` (instalados vía `config.toml`)
- [Ollama](https://ollama.com) (instalado automáticamente con `make setup`)

## Setup

```bash
make setup                    # instala Ollama + modelo llama3.2 (por defecto)
make setup MODEL=mistral      # usa otro modelo
```

El script `setup.sh` realiza los siguientes pasos:
1. Descarga e instala Ollama si no está presente.
2. Arranca el servidor Ollama en background (`localhost:11434`).
3. Descarga el modelo especificado con `ollama pull`.
4. Instala las dependencias npm (`axios`, `yaml`).

## Uso manual

```bash
make test                         # ejecuta un prompt de prueba ("Cuentame un chiste")
make run WORD="tu prompt aquí"    # ejecuta el prompt especificado
```

Ejemplo:

```bash
make run WORD="Explica qué es una red neuronal en una frase"
# → Una red neuronal es un modelo computacional inspirado en el cerebro...
```

## Configuración del modelo

Edita `server_config.yml` para cambiar el modelo o la URL del servidor:

```yaml
server:
  api_base: "http://localhost:11434"
  timeout: 120

model:
  name: "llama3.2"
  max_tokens: 512

retry:
  retries: 3
  retry_wait: 5

system:
  prompt: ""
```

### Usar LM Studio en lugar de Ollama

1. Abre LM Studio → Local Server → activa **"OpenAI Compatible Server"**.
2. Cambia `api_base` en `server_config.yml`:

```yaml
server:
  api_base: "http://localhost:1234"
```

> **Nota:** LM Studio expone el endpoint `/v1/chat/completions` (compatible OpenAI), mientras que `app.js` usa `/api/generate` (API nativa de Ollama). Si usas LM Studio, deberás adaptar la llamada en `app.js`.

## Formato de salida

La respuesta del modelo se escribe directamente por stdout como texto plano:

```
La inteligencia artificial es la simulación de procesos cognitivos humanos por parte de sistemas informáticos.
```

## Comandos del Makefile

- `make setup`: Instala Ollama y descarga el modelo.
- `make setup MODEL=<nombre>`: Instala con un modelo concreto.
- `make run WORD="<prompt>"`: Ejecuta el prompt especificado.
- `make test`: Ejecuta un prompt de prueba rápido.
- `make clean`: (Sin efecto — no hay archivos de salida que limpiar.)
