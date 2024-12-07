$CONFIG_FILE = "./config/services"
$ENV_FILE = ".env.dev"

if (-not (Test-Path $CONFIG_FILE)) {
    Write-Host "❌ Configuration file not found: $CONFIG_FILE" -ForegroundColor Red
    exit 1
}

# Bring down infrastructure services
Write-Host "🛑 Bringing down existing infrastructure services..."
if (-not (docker compose -f ./docker-compose.yaml down --remove-orphans)) {
    Write-Host "❌ Failed to bring down infrastructure services. Please check the Docker Compose file." -ForegroundColor Red
    exit 1
}

# Start infrastructure services
Write-Host "🚀 Starting infrastructure services..."
if (-not (docker compose --env-file $ENV_FILE -f ./docker-compose.yaml up -d)) {
    Write-Host "❌ Failed to start infrastructure services. Please check the Docker Compose file." -ForegroundColor Red
    exit 1
}

Get-Content $CONFIG_FILE | ForEach-Object {
    $compose_file = $_.Trim()
    if ($compose_file -ne "") {
        Write-Host "🚀 Starting service from compose file: $compose_file..."

        if (Test-Path $compose_file) {
            Write-Host "🛑 Bringing down existing service for: $compose_file and removing orphans..."
            if (-not (docker compose -f $compose_file down)) {
                Write-Host "❌ Failed to bring down service for: $compose_file. Please check its Docker Compose file." -ForegroundColor Red
                exit 1
            }

            if (-not (docker compose --env-file $ENV_FILE -f $compose_file up -d)) {
                Write-Host "❌ Failed to start service for: $compose_file. Please check its Docker Compose file." -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "❌ Compose file not found: $compose_file" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host "✅ Successfully started dev-box 📦😊" -ForegroundColor Green
