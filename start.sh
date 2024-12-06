#!/bin/bash

CONFIG_FILE="./config/services"
ENV_FILE=".env.dev"

generate_secret_key() {
    echo "🔑 Generating new 32-byte SECURITY_JWT_SECRET_KEY..."
    HEX_KEY=$(openssl rand -hex 32)
    BASE64_KEY=$(echo -n "$HEX_KEY" | base64)
    if grep -q "SECURITY_JWT_SECRET_KEY" "$ENV_FILE"; then
        sed -i '' "s/^SECURITY_JWT_SECRET_KEY=.*/SECURITY_JWT_SECRET_KEY=$BASE64_KEY/" "$ENV_FILE"
        sed -i '' "s/^SECRET_KEY=.*/SECRET_KEY=$BASE64_KEY/" "$ENV_FILE"
        echo "✅ Updated SECURITY_JWT_SECRET_KEY in $ENV_FILE."
    else
        echo "SECURITY_JWT_SECRET_KEY=$BASE64_KEY" >> "$ENV_FILE"
        echo "SECRET_KEY=$BASE64_KEY" >> "$ENV_FILE"
        echo "✅ Added SECURITY_JWT_SECRET_KEY to $ENV_FILE."
    fi
}

if [[ ! -f "$ENV_FILE" ]]; then
    echo "❌ Environment file not found: $ENV_FILE. Creating a new one..."
    touch "$ENV_FILE"
fi

generate_secret_key

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
