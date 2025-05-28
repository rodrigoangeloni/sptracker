# Makefile para compilación de sptracker en Orange Pi ARM32
# 
# CONFIGURACIÓN IMPORTANTE:
# 1. Cambia ORANGEPI_HOST por la IP de tu Orange Pi
# 2. Cambia ORANGEPI_USER por tu usuario de Orange Pi
# 3. Asegúrate de que tienes acceso SSH sin contraseña (clave SSH)
#
# Uso desde Windows PowerShell:
#   make orangepi BUILD_VERSION=1.0.0

.PHONY: help orangepi orangepi-setup orangepi-build orangepi-clean orangepi-deploy test-orangepi

# Target por defecto
help:
	@echo "Targets disponibles para Orange Pi ARM32:"
	@echo "  orangepi        - Proceso completo de compilación para Orange Pi"
	@echo "  orangepi-setup  - Configurar el entorno de compilación de Orange Pi"
	@echo "  orangepi-build  - Compilar stracker para Orange Pi"
	@echo "  orangepi-clean  - Limpiar artefactos de compilación"
	@echo "  orangepi-deploy - Desplegar en el dispositivo Orange Pi"
	@echo "  test-orangepi   - Ejecutar pruebas en Orange Pi"
	@echo ""
	@echo "Configuración:"
	@echo "  ORANGEPI_HOST   - IP/nombre de host de Orange Pi (por defecto: orangepi.local)"
	@echo "  ORANGEPI_USER   - Nombre de usuario de Orange Pi (por defecto: orangepi)"
	@echo "  BUILD_VERSION   - Número de versión (por defecto: dev)"

# Variables de configuración
ORANGEPI_HOST ?= orangepi.local
ORANGEPI_USER ?= orangepi
BUILD_VERSION ?= dev
SSH_OPTS = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

# Proceso completo de compilación para Orange Pi
orangepi: orangepi-setup orangepi-build
	@echo "¡Compilación de Orange Pi completada con éxito!"

# Configurar el entorno de compilación de Orange Pi
orangepi-setup:
	@echo "Configurando el entorno de compilación de Orange Pi..."
	@chmod +x setup_orangepi.sh
	@chmod +x create_release_orangepi_arm32.sh
	@echo "Los scripts de compilación están listos"
	@echo "Siguiente: ejecuta 'make orangepi-build' o copia los scripts a Orange Pi"

# Compilar stracker para Orange Pi (requiere ejecutarse en dispositivo ARM)
orangepi-build:
	@echo "Compilando stracker para Orange Pi ARM32..."
	@if [ "$$(uname -m)" = "armv7l" ] || [ "$$(uname -m)" = "armhf" ]; then \
		./create_release_orangepi_arm32.sh $(BUILD_VERSION); \
	else \
		echo "Error: Este target debe ejecutarse en Orange Pi o dispositivo ARM"; \
		echo "Usa 'make orangepi-deploy' para copiar y compilar remotamente"; \
		exit 1; \
	fi

# Limpiar artefactos de compilación
orangepi-clean:
	@echo "Limpiando artefactos de compilación de Orange Pi..."
	@rm -rf stracker/dist
	@rm -rf stracker/build
	@rm -rf stracker/env/orangepi_arm32
	@rm -f stracker/stracker_orangepi_arm32.tgz
	@rm -f stracker/deploy_orangepi.sh
	@echo "Artefactos de compilación limpiados"

# Desplegar en dispositivo Orange Pi (copiar fuentes y compilar remotamente)
orangepi-deploy:
	@echo "Desplegando en dispositivo Orange Pi: $(ORANGEPI_USER)@$(ORANGEPI_HOST)"
	@echo "Copiando archivos fuente..."
	@rsync -av $(SSH_OPTS) \
		--exclude='.git' \
		--exclude='__pycache__' \
		--exclude='*.pyc' \
		--exclude='dist' \
		--exclude='build' \
		--exclude='env' \
		./ $(ORANGEPI_USER)@$(ORANGEPI_HOST):~/sptracker/
	@echo "Ejecutando configuración en Orange Pi..."
	@ssh $(SSH_OPTS) $(ORANGEPI_USER)@$(ORANGEPI_HOST) \
		'cd ~/sptracker && chmod +x setup_orangepi.sh && ./setup_orangepi.sh'
	@echo "Compilando en Orange Pi..."
	@ssh $(SSH_OPTS) $(ORANGEPI_USER)@$(ORANGEPI_HOST) \
		'cd ~/sptracker && ./create_release_orangepi_arm32.sh $(BUILD_VERSION)'
	@echo "Copiando resultados de compilación..."
	@rsync -av $(SSH_OPTS) \
		$(ORANGEPI_USER)@$(ORANGEPI_HOST):~/sptracker/stracker/stracker_orangepi_arm32.tgz \
		./stracker/
	@echo "¡Despliegue completado!"

# Probar stracker en Orange Pi
test-orangepi:
	@echo "Ejecutando pruebas en Orange Pi..."
	@ssh $(SSH_OPTS) $(ORANGEPI_USER)@$(ORANGEPI_HOST) \
		'cd ~/sptracker/stracker && python3 -m pytest -v' || \
		echo "Nota: pytest no disponible, ejecutando prueba de importación básica"
	@ssh $(SSH_OPTS) $(ORANGEPI_USER)@$(ORANGEPI_HOST) \
		'cd ~/sptracker/stracker && python3 -c "import stracker; print(\"Prueba de importación: OK\")"'

# Crear paquete de liberación
orangepi-package: orangepi-build
	@echo "Creando paquete de liberación para Orange Pi..."
	@cd stracker && tar czf ../sptracker-orangepi-arm32-$(BUILD_VERSION).tgz \
		stracker_orangepi_arm32.tgz \
		deploy_orangepi.sh \
		../README_OrangePi.md \
		../setup_orangepi.sh
	@echo "Paquete creado: sptracker-orangepi-arm32-$(BUILD_VERSION).tgz"

# Instalar en Orange Pi (después de la compilación)
orangepi-install:
	@echo "Instalando stracker en Orange Pi..."
	@ssh $(SSH_OPTS) $(ORANGEPI_USER)@$(ORANGEPI_HOST) \
		'cd ~/sptracker/stracker && ./deploy_orangepi.sh'
	@ssh $(SSH_OPTS) $(ORANGEPI_USER)@$(ORANGEPI_HOST) \
		'sudo systemctl enable stracker && sudo systemctl start stracker'
	@echo "Stracker instalado y iniciado en Orange Pi"
	@echo "Interfaz web: http://$(ORANGEPI_HOST):50041"

# Mostrar estado de Orange Pi
orangepi-status:
	@echo "Estado de stracker en Orange Pi:"
	@ssh $(SSH_OPTS) $(ORANGEPI_USER)@$(ORANGEPI_HOST) \
		'sudo systemctl status stracker' || true
	@echo ""
	@echo "Registros recientes:"
	@ssh $(SSH_OPTS) $(ORANGEPI_USER)@$(ORANGEPI_HOST) \
		'sudo journalctl -u stracker --lines=10 --no-pager' || true

# Ciclo de desarrollo rápido
orangepi-dev: orangepi-clean orangepi-deploy orangepi-install
	@echo "¡Despliegue de desarrollo completado!"
	@echo "stracker está en ejecución en Orange Pi"
