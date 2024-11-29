#!/bin/bash

CONFIG_FILE="./config/services"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

echo "🛑 Bringing down existing infrastructure services..."
if ! docker compose -f ./docker-compose.infrastructure.yaml down --remove-orphans; then
    echo "❌ Failed to bring down infrastructure services. Please check the Docker Compose file."
    exit 1
fi

# Start infrastructure services
echo "🚀 Starting infrastructure services..."
if ! docker compose -f ./docker-compose.infrastructure.yaml up -d; then
    echo "❌ Failed to start infrastructure services. Please check the Docker Compose file."
    exit 1
fi

while IFS= read -r service || [[ -n "$service" ]]; do
    if [[ -n "$service" ]]; then
        echo "🚀 Starting service: $service..."
        COMPOSE_FILE="./services/$service/docker-compose.yml"

        if [[ -f "$COMPOSE_FILE" ]]; then
            echo "🛑 Bringing down existing service: $service and removing orphans..."
            if ! docker compose -f "$COMPOSE_FILE" down --remove-orphans; then
                echo "❌ Failed to bring down service: $service. Please check its Docker Compose file."
                exit 1
            fi

            # Start the service
            if ! docker compose -f "$COMPOSE_FILE" up -d; then
                echo "❌ Failed to start service: $service. Please check its Docker Compose file."
                exit 1
            fi
        else
            echo "❌ Compose file not found for service: $service"
            exit 1
        fi
    fi
done < "$CONFIG_FILE"


echo "✅ Successfully started dev-box 📦😊"
