@echo off
setlocal enabledelayedexpansion

set "CONFIG_FILE=.\config\services"

if not exist "%CONFIG_FILE%" (
    echo ❌ Configuration file not found: %CONFIG_FILE%
    exit /b 1
)

:: Start infrastructure services
echo 🚀 Starting infrastructure services...
docker compose up -d
if errorlevel 1 (
    echo ❌ Failed to start infrastructure services. Please check the Docker Compose file.
    exit /b 1
)

for /f "usebackq tokens=*" %%A in ("%CONFIG_FILE%") do (
    set "service=%%A"
    if not "!service!"=="" (
        set "COMPOSE_FILE=.\services\!service!\docker-compose.yml"
        if exist "!COMPOSE_FILE!" (
            echo 🚀 Starting service: !service!...
            docker compose -f "!COMPOSE_FILE!" up -d
            if errorlevel 1 (
                echo ❌ Failed to start service: !service!. Please check its Docker Compose file.
                exit /b 1
            )
        ) else (
            echo ❌ Compose file not found for service: !service!
            exit /b 1
        )
    )
)

echo ✅ Successfully started dev-box 📦😊
