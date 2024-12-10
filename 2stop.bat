@echo off

set CONFIG_FILE=.\config\services
set ENV_FILE=.env.dev

for /F "tokens=*" %%i in (%CONFIG_FILE%) do (
    docker compose -f %%i down
)

docker compose -f ./docker-compose.yaml down --remove-orphans


echo ✅ Successfully started dev-box 📦😊
