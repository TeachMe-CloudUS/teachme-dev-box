#!/bin/bash

CONFIG_FILE="./config/services"
ENV_FILE=".env.dev"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Bring down infrastructure services
echo "🛑 Bringing down existing infrastructure services..."
if ! docker compose -f ./docker-compose.yaml down --remove-orphans; then
    echo "❌ Failed to bring down infrastructure services. Please check the Docker Compose file."
    exit 1
fi

# Start infrastructure services
echo "🚀 Starting infrastructure services..."
if ! docker compose --env-file "$ENV_FILE" -f ./docker-compose.yaml up -d --build; then
    echo "❌ Failed to start infrastructure services. Please check the Docker Compose file."
    exit 1
fi

# Start each service specified in the configuration file
while IFS= read -r compose_file || [[ -n "$compose_file" ]]; do
    if [[ -n "$compose_file" ]]; then
        echo "🚀 Starting service from compose file: $compose_file..."

        if [[ -f "$compose_file" ]]; then
            # Bring down the existing service
            echo "🛑 Bringing down existing service for: $compose_file and removing orphans..."
            if ! docker compose -f "$compose_file" down; then
                echo "❌ Failed to bring down service for: $compose_file. Please check its Docker Compose file."
                exit 1
            fi

            # Start the service
            if ! docker compose --env-file "$ENV_FILE" -f "$compose_file" up -d --build; then
                echo "❌ Failed to start service for: $compose_file. Please check its Docker Compose file."
                exit 1
            fi
        else
            echo "❌ Compose file not found: $compose_file"
            exit 1
        fi
    fi
done < "$CONFIG_FILE"

echo "✅ Successfully started dev-box 📦😊"
