$ConfigFile = "./config/services"

if (-Not (Test-Path $ConfigFile)) {
    Write-Host "❌ Configuration file not found: $ConfigFile" -ForegroundColor Red
    exit 1
}

# Start infrastructure services
Write-Host "🚀 Starting infrastructure services..."
if (-Not (docker compose up -d)) {
    Write-Host "❌ Failed to start infrastructure services. Please check the Docker Compose file." -ForegroundColor Red
    exit 1
}

Get-Content $ConfigFile | ForEach-Object {
    $service = $_.Trim()
    if ($service) {
        $composeFile = "./services/$service/docker-compose.yml"
        if (Test-Path $composeFile) {
            Write-Host "🚀 Starting service: $service..."
            if (-Not (docker compose -f $composeFile up -d)) {
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
