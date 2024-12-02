$CONFIG_FILE = "./config/services"
$ENV_FILE = ".env.dev"

function Generate-SecretKey {
    Write-Host "🔑 Generating new 32-byte SECURITY_JWT_SECRET_KEY..."
    $HEY_KEY = (openssl rand -hex 32)
    $BASE64_KEY = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($HEY_KEY))

    if (Test-Path $ENV_FILE) {
        $EnvContent = Get-Content $ENV_FILE
        if ($EnvContent -match "^SECURITY_JWT_SECRET_KEY=") {
            (Get-Content $ENV_FILE) -replace "^SECURITY_JWT_SECRET_KEY=.*", "SECURITY_JWT_SECRET_KEY=$BASE64_KEY" | Set-Content $ENV_FILE
            Write-Host "✅ Updated SECURITY_JWT_SECRET_KEY in $ENV_FILE."
        } else {
            Add-Content $ENV_FILE "SECURITY_JWT_SECRET_KEY=$BASE64_KEY"
            Write-Host "✅ Added SECURITY_JWT_SECRET_KEY to $ENV_FILE."
        }
    } else {
        New-Item -ItemType File -Path $ENV_FILE -Force | Out-Null
        Add-Content $ENV_FILE "SECURITY_JWT_SECRET_KEY=$BASE64_KEY"
        Write-Host "✅ Created $ENV_FILE and added SECURITY_JWT_SECRET_KEY."
    }
}

if (-Not (Test-Path $ENV_FILE)) {
    Write-Host "❌ Environment file not found: $ENV_FILE. Creating a new one..."
    New-Item -ItemType File -Path $ENV_FILE -Force | Out-Null
}

Generate-SecretKey

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
