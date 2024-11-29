# Dev-Box

This repository provides a development environment setup using Docker Compose for managing infrastructure and services of the TeachMe platform.
It includes a single start script for Windows, macOS, and Linux systems.

## Getting Started
### Prerequisites

Ensure you have the following installed:
- Docker
- Docker Compose
- Bash (Linux/macOS) or Command Prompt/PowerShell (Windows)

## Cloning the Repository

Since this repository uses Git submodules, follow these steps to ensure a complete clone:

1. Open a terminal.
2. Clone the repository with submodules:
```shell
git clone --recurse-submodules git@github.com:TeachMe-CloudUS/teachme-dev-box.git
```
3. If you’ve already cloned the repository without submodules, initialize and update the submodules:
```shell
git submodule update --init --recursive
```
4. To pull the latest changes, including submodule updates:
```shell
git pull --recurse-submodules
git submodule update --recursive --remote
```

## Starting Dev-Box

Depending on your operating system, follow the instructions below to start the development environment.

### Linux/macOS

1. Open a terminal.
2. Navigate to the repository directory.
3. Run the start script:
```shell
./start.sh
```
4. If the script isn’t executable, make it executable by running:
```shell
chmod +x start.sh
./start.sh
```

### Windows

#### Using Command Prompt (Batch)

1. Open Command Prompt.
2. Navigate to the repository directory.
3. Run the batch script:
```shell
start.bat
```

#### Using Powershell

1. Open PowerShell.
2. Navigate to the repository directory.
3. Run the PowerShell script:
```shell
./start.ps1
```