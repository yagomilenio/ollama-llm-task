MODEL  ?= llama3.2

.PHONY: help setup run test clean

help:
	@echo ""
	@echo "  make setup                      		instala Ollama y el modelo"
	@echo "  make setup MODEL=mistral        		instala con un modelo concreto"
	@echo "  make run WORD="Que día es hoy"         procesa el prompt especificado"
	@echo ""

setup:
	bash setup.sh $(MODEL)

run:
	node app.js "$(WORD)"

test:
	node app.js "Cuentame un chiste"

clean:
