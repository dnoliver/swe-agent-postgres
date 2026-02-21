#!/bin/bash

# Save script for backing up agent configuration and task files
# This script reads the TASK variable from .env and copies relevant files to .output/

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

# Get the repository root (scripts directory's parent)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Check if .env file exists
ENV_FILE="${REPO_ROOT}/.env"
if [[ ! -f "${ENV_FILE}" ]]; then
    error_exit ".env file not found at ${ENV_FILE}"
fi

# Read and extract TASK variable from .env
TASK=$(grep -E '^TASK=' "${ENV_FILE}" | cut -d'=' -f2- | tr -d '"' | tr -d "'")

# Validate TASK variable
if [[ -z "${TASK}" ]]; then
    error_exit "TASK variable is not set or empty in ${ENV_FILE}"
fi

info "TASK variable found: ${TASK}"

# Define output directory
OUTPUT_DIR="${REPO_ROOT}/.output"
TASK_OUTPUT_DIR="${OUTPUT_DIR}/${TASK}"

# Create .output directory if it doesn't exist
if [[ ! -d "${OUTPUT_DIR}" ]]; then
    info "Creating .output directory at ${OUTPUT_DIR}"
    mkdir -p "${OUTPUT_DIR}" || error_exit "Failed to create ${OUTPUT_DIR}"
else
    info "Output directory already exists at ${OUTPUT_DIR}"
fi

# Create task-specific output directory
if [[ -d "${TASK_OUTPUT_DIR}" ]]; then
    warn "Task output directory already exists: ${TASK_OUTPUT_DIR}"
    info "Contents will be updated"
fi

mkdir -p "${TASK_OUTPUT_DIR}" || error_exit "Failed to create ${TASK_OUTPUT_DIR}"

# Check if agent directory exists
AGENT_DIR="${REPO_ROOT}/agent"
if [[ ! -d "${AGENT_DIR}" ]]; then
    error_exit "agent directory not found at ${AGENT_DIR}"
fi

# Copy agent output recursively to task output directory
info "Copying agent output to ${TASK_OUTPUT_DIR}"
cp -R "${AGENT_DIR}/." "${TASK_OUTPUT_DIR}" || error_exit "Failed to copy agent output"

# Check for task files matching the pattern
TASK_FILES=$(find "${REPO_ROOT}/tasks" -maxdepth 1 -type f -name "${TASK}.*" 2>/dev/null || true)

if [[ -z "${TASK_FILES}" ]]; then
    warn "No files found matching pattern tasks/${TASK}.*"
else
    # Copy all matching task files
    info "Copying task files matching pattern ${TASK}.*"
    while IFS= read -r -d '' file; do
        info "  Copying $(basename "${file}")"
        cp "${file}" "${TASK_OUTPUT_DIR}/" || error_exit "Failed to copy ${file}"
    done < <(find "${REPO_ROOT}/tasks" -maxdepth 1 -type f -name "${TASK}.*" -print0)
fi

# Verify the output
info "Verifying output directory contents..."

# Check for result files
RESULT_FILES=$(find "${TASK_OUTPUT_DIR}" -maxdepth 1 -type f -name "result.*" 2>/dev/null || true)
if [[ -n "${RESULT_FILES}" ]]; then
    RESULT_COUNT=$(echo "${RESULT_FILES}" | wc -l | xargs)
    info "  ✓ ${RESULT_COUNT} result file(s) found"
else
    warn "  ! No result files found (expected: result.*)"
fi

# Check for trajectory.json
if [[ -f "${TASK_OUTPUT_DIR}/trajectory.json" ]]; then
    info "  ✓ trajectory.json found"
else
    warn "  ! trajectory.json not found"
fi

# Check for tasks files
TASK_FILE_COUNT=$(find "${TASK_OUTPUT_DIR}" -maxdepth 1 -type f -name "${TASK}.*" 2>/dev/null | wc -l | xargs)
info "  ✓ ${TASK_FILE_COUNT} task file(s) copied"

info "Save completed successfully! Output location: ${TASK_OUTPUT_DIR}"
exit 0
