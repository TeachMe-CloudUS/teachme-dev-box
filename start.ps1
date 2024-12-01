$ConfigFile = "./config/services"

if (-Not (Test-Path $ConfigFile)) {
    Write-Host "❌ Configuration file not found: $ConfigFile" -ForegroundColor Red
    exit 1
}

Write-Host "🛑 Bringing down existing infrastructure services..."
docker compose -f ./docker-compose.infrastructure.yaml down --remove-orphans
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to bring down service: $service. Please check its Docker Compose file." -ForegroundColor Red
    exit 1
}

# Start infrastructure services
Write-Host "🚀 Starting infrastructure services..."
if (-Not (docker compose --env-file .env.dev -f ./docker-compose.infrastructure.yaml up)) {
    Write-Host "❌ Failed to start infrastructure services. Please check the Docker Compose file." -ForegroundColor Red
    exit 1
}

Get-Content $ConfigFile | ForEach-Object {
    $service = $_.Trim()
    if ($service) {
        $composeFile = "./services/$service/docker-compose.yml"
        if (Test-Path $composeFile) {

            Write-Host "🛑 Bringing down existing service: $service and removing orphans..."
            docker compose -f $composeFile down --remove-orphans
            if ($LASTEXITCODE -ne 0) {
                Write-Host "❌ Failed to bring down service: $service. Please check its Docker Compose file." -ForegroundColor Red
                exit 1
            }

            # Start the service
            Write-Host "🚀 Starting service: $service..."
            docker compose --env-file .env.dev -f $composeFile up -d
            if ($LASTEXITCODE -ne 0) {
                Write-Host "❌ Failed to start service: $service. Please check its Docker Compose file." -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "❌ Compose file not found for service: $service" -ForegroundColor Red
            exit 1
        }
    }
}


Write-Host "✅ Successfully started dev-box 📦😊" -ForegroundColor Green
