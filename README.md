# ollama-llm-task

Tarea dinámica para la **plataforma de paralelización**. Ejecuta un LLM local sobre una lista de prompts, distribuyendo el trabajo entre workers.

## Cómo encaja en la plataforma

```
Plataforma de paralelización
  │
  ├── lee config.toml
  │     ├── inputs.file_single → inputs/prompts.txt
  │     └── runner.command     → python run.py
  │
  └── lanza por cada worker:
        python run.py --start 0   --end 4    → outputs/results_0_4.jsonl
        python run.py --start 5   --end 9    → outputs/results_5_9.jsonl
        python run.py --start 10  --end 14   → outputs/results_10_14.jsonl
        ...
```

Cada worker llama a Ollama de forma independiente. Los resultados se escriben en ficheros `.jsonl` separados (sin conflictos de escritura) y al final se pueden unir con `merge_results.py`.

## Estructura

```
ollama-llm-task/
├── config.toml          # Configuración para la plataforma + parámetros del LLM
├── run.py               # Worker — lee prompts, llama al LLM, escribe .jsonl
├── merge_results.py     # Utilidad para unir los .jsonl parciales
├── setup.sh             # Instala Ollama y el modelo
├── Makefile             # Atajos para setup, test y ejecución
├── inputs/
│   └── prompts.txt      # Un prompt por línea ← edita esto
└── outputs/             # Los workers escriben aquí (git-ignored)
    └── results_0_4.jsonl
    └── results_5_9.jsonl
    └── ...
```

## Requisitos

- Python 3.11+ (usa `tomllib` nativo; en 3.10 instala `tomli`)
- [Ollama](https://ollama.com) instalado y corriendo, **o** LM Studio con servidor activo
- `pip install requests`

## Setup

```bash
make setup                  # instala Ollama + modelo llama3.2 (por defecto)
make setup MODEL=mistral    # usa otro modelo
```

## Uso manual

```bash
make test                   # procesa prompts 0-2 → outputs/test.jsonl
make run START=0 END=9      # procesa prompts 0-9
make merge                  # une todos los .jsonl → outputs/all_results.jsonl
```

## Configurar el LLM

Edita la sección `[llm]` en `config.toml`:

```toml
[llm]
model      = "llama3.2"               # modelo Ollama
api_base   = "http://localhost:11434" # URL del servidor
system     = "Responde siempre en español y de forma concisa."
max_tokens = 512
timeout    = 120
```

### Usar LM Studio en lugar de Ollama

1. Abre LM Studio → Local Server → activa **"OpenAI Compatible Server"**
2. Cambia `api_base` en `config.toml`:

```toml
api_base = "http://localhost:1234"
```

> **Nota:** LM Studio usa el endpoint `/v1/chat/completions` (compatible OpenAI), no `/api/generate` (Ollama). La versión actual de `run.py` usa la API de Ollama. Si prefieres LM Studio, consulta la sección [Adaptadores](#adaptadores) más abajo.

## Formato de salida

Cada línea del `.jsonl` de salida tiene este formato:

```json
{
  "prompt_idx": 0,
  "prompt": "Explica qué es la inteligencia artificial en una frase.",
  "model": "llama3.2",
  "response": "La inteligencia artificial es...",
  "tokens_prompt": 14,
  "tokens_eval": 38,
  "elapsed_s": 2.4,
  "error": null
}
```

## Añadir tus propios prompts

Edita `inputs/prompts.txt` — un prompt por línea:

```
Traduce al inglés: "El cielo es azul"
Resume este texto: ...
Clasifica el sentimiento de: "Me encanta este producto"
```

Ajusta el rango en `config.toml` si tienes más de 250 prompts:

```toml
[inputs.range_continuous]  # no aplica aquí, esto es file_single
# la plataforma calcula automáticamente el total de líneas
```

## Adaptadores

### OpenAI / LM Studio (endpoint `/v1/chat/completions`)

Si quieres usar LM Studio o cualquier backend compatible con OpenAI, sustituye la función `call_ollama` en `run.py` por:

```python
def call_openai_compat(prompt: str) -> dict:
    url = f"{API_BASE}/v1/chat/completions"
    messages = []
    if SYSTEM_MSG:
        messages.append({"role": "system", "content": SYSTEM_MSG})
    messages.append({"role": "user", "content": prompt})
    payload = {
        "model": MODEL,
        "messages": messages,
        "max_tokens": MAX_TOKENS,
    }
    r = requests.post(url, json=payload, timeout=TIMEOUT)
    r.raise_for_status()
    data = r.json()
    return {
        "response": data["choices"][0]["message"]["content"],
        "prompt_eval_count": data.get("usage", {}).get("prompt_tokens", 0),
        "eval_count":        data.get("usage", {}).get("completion_tokens", 0),
    }
```
