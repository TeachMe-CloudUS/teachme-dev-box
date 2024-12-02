@echo off

set CONFIG_FILE=.\config\services
set ENV_FILE=.env.dev

:generate_secret_key
    echo 🔑 Generating new 32-byte SECURITY_JWT_SECRET_KEY...
    for /f "tokens=*" %%i in ('openssl rand -hex 32') do set HEX_KEY=%%i
    for /f "tokens=*" %%j in ('echo %HEX_KEY% ^| openssl enc -base64 -A') do set BASE64_KEY=%%j

    if exist %ENV_FILE% (
        for /f "delims=" %%l in ('findstr /b "SECURITY_JWT_SECRET_KEY" %ENV_FILE%') do set FOUND_KEY=1
        if defined FOUND_KEY (
            powershell -Command "(gc '%ENV_FILE%') -replace '^SECURITY_JWT_SECRET_KEY=.*', 'SECURITY_JWT_SECRET_KEY=%BASE64_KEY%' | sc '%ENV_FILE%'"
            echo ✅ Updated SECURITY_JWT_SECRET_KEY in %ENV_FILE%.
        ) else (
            echo SECURITY_JWT_SECRET_KEY=%BASE64_KEY% >> %ENV_FILE%
            echo ✅ Added SECURITY_JWT_SECRET_KEY to %ENV_FILE%.
        )
    ) else (
        echo SECURITY_JWT_SECRET_KEY=%BASE64_KEY% >> %ENV_FILE%
        echo ✅ Added SECURITY_JWT_SECRET_KEY to new %ENV_FILE%.
    )
    goto :eof

if not exist %ENV_FILE% (
    echo ❌ Environment file not found: %ENV_FILE%. Creating a new one...
    echo. > %ENV_FILE%
)

call :generate_secret_key

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
