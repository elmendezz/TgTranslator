#!/bin/bash

# --- Configuración ---
# Usamos un nombre de imagen local ya que no se usará PC ni Docker Hub
DOCKER_IMAGE="tg-translator-local:latest"
CONTAINER_NAME="tg-translator"

# --- Lógica del Script ---

# Si el primer argumento es "build", se compila la imagen localmente.
if [ "$1" == "build" ]; then
    echo "Iniciando compilación de la imagen de Docker localmente..."
    echo "Esto puede tardar varios minutos."
    # Usamos el Dockerfile en el directorio actual para construir la imagen
    docker build -t "$DOCKER_IMAGE" .
    if [ $? -ne 0 ]; then
        echo "Error: La compilación de Docker falló."
        exit 1
    fi
    echo "Compilación completada con éxito."
fi

# Busca el archivo .env en el mismo directorio que el script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ENV_FILE="$SCRIPT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: Archivo de configuración .env no encontrado."
    echo "Por favor, crea un archivo .env en el directorio $SCRIPT_DIR"
    exit 1
fi

# Exporta las variables del .env para que Docker las pueda usar
export $(grep -v '^#' "$ENV_FILE" | xargs)

echo "Deteniendo y eliminando contenedor anterior (si existe)..."
docker stop "$CONTAINER_NAME" >/dev/null 2>&1
docker rm "$CONTAINER_NAME" >/dev/null 2>&1

echo "Actualizando la imagen base por si hay nuevas versiones..."
docker pull mcr.microsoft.com/dotnet/aspnet:8.0-alpine-arm32v7 >/dev/null 2>&1

echo "Iniciando nuevo contenedor..."
docker run -d --restart always \
  -p 8080:8080 \
  -e "ConnectionStrings__TgTranslatorContext=${CONNECTION_STRING}" \
  -e "telegram__botToken=${TELEGRAM_BOT_TOKEN}" \
  --name "$CONTAINER_NAME" \
  "$DOCKER_IMAGE"

echo "¡Contenedor '$CONTAINER_NAME' iniciado con éxito!"
