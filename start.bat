@echo off

set CONFIG_FILE=.\config\services
set ENV_FILE=.env.dev

if not exist "%CONFIG_FILE%" (
    echo ❌ Configuration file not found: %CONFIG_FILE%
    exit /b 1
)

echo 🛑 Bringing down existing infrastructure services...
docker compose -f ./docker-compose.yaml down --remove-orphans
if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to bring down infrastructure services. Please check the Docker Compose file.
    exit /b 1
)

echo 🚀 Starting infrastructure services...
docker compose --env-file "%ENV_FILE%" -f ./docker-compose.yaml up -d
if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to start infrastructure services. Please check the Docker Compose file.
    exit /b 1
)

for /f "tokens=*" %%i in (%CONFIG_FILE%) do (
    set compose_file=%%i
    if not "%compose_file%"=="" (
        echo 🚀 Starting service from compose file: %compose_file%...

        if exist "%compose_file%" (
            echo 🛑 Bringing down existing service for: %compose_file% and removing orphans...
            docker compose -f "%compose_file%" down
            if %ERRORLEVEL% neq 0 (
                echo ❌ Failed to bring down service for: %compose_file%. Please check its Docker Compose file.
                exit /b 1
            )

            docker compose --env-file "%ENV_FILE%" -f "%compose_file%" up -d
            if %ERRORLEVEL% neq 0 (
                echo ❌ Failed to start service for: %compose_file%. Please check its Docker Compose file.
                exit /b 1
            )
        ) else (
            echo ❌ Compose file not found: %compose_file%
            exit /b 1
        )
    )
)

echo ✅ Successfully started dev-box 📦😊
