#!/bin/bash

# Clean script cleanups the environment between tasks
# Usage: ./scripts/clean.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print error message and exit
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

# Function to print info message
info() {
    echo -e "${GREEN}INFO: $1${NC}"
}

# Function to print warning message
warn() {
    echo -e "${YELLOW}WARNING: $1${NC}" >&2
}

info "Cleaning folder ./agent"
git clean agent/ -fxd
