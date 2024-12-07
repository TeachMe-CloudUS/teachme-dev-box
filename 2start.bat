@echo off

set CONFIG_FILE=.\config\services
set ENV_FILE=.env.dev

if not exist "%CONFIG_FILE%" (
    echo ❌ Configuration file not found: %CONFIG_FILE%
    exit /b 1
)

docker compose -f ./docker-compose.yaml down --remove-orphans

docker compose --env-file "%ENV_FILE%" -f ./docker-compose.yaml up -d

for /F "tokens=*" %%i in (%CONFIG_FILE%) do (
    docker compose -f %%i down

    docker compose --env-file "%ENV_FILE%" -f %%i up -d
)

echo ✅ Successfully started dev-box 📦😊
