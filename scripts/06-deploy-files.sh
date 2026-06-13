#!/bin/bash

# Przerwij skrypt przy pierwszym błędzie

set -e

# Błąd przy użyciu niezdefiniowanej zmiennej

set -u

# Utworzenie katalogu logów jeśli nie istnieje

mkdir -p logs

# Ścieżka do raportu

REPORT_FILE="logs/install-report.log"

# Nagłówek

echo "" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"
echo "STEP 06 - DEPLOY FILES" | tee -a "$REPORT_FILE"
echo "$(date)" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"

# Root wymagany

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Run script as root." | tee -a "$REPORT_FILE"
    exit 1
fi

# .env wymagany

if [ ! -f ".env" ]; then
    echo "[ERROR] File .env not found." | tee -a "$REPORT_FILE"
    exit 1
fi

# shellcheck disable=SC1091

source .env

# Walidacja zmiennych

REQUIRED_VARS=(
    SSH_USER
    DEPLOY_DIR
    DOMAIN
    ENVIRONMENT
    MONGO_VERSION
    SERVER_LAN_IP
)

for VAR in "${REQUIRED_VARS[@]}"; do

    if [ -z "${!VAR:-}" ]; then
        echo "[ERROR] Missing variable in .env: $VAR" | tee -a "$REPORT_FILE"
        exit 1
    fi

done

# Walidacja template

if [ ! -f "templates/compose.yml.template" ]; then
    echo "[ERROR] Missing template: templates/compose.yml.template" | tee -a "$REPORT_FILE"
    exit 1
fi

if [ ! -f "templates/nginx/default.conf.template" ]; then
    echo "[ERROR] Missing template: templates/nginx/default.conf.template" | tee -a "$REPORT_FILE"
    exit 1
fi

# Tworzenie katalogów

mkdir -p "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR/nginx"

# Generowanie compose.yml

envsubst \
    < templates/compose.yml.template \
    > "$DEPLOY_DIR/compose.yml"

# Generowanie nginx config

envsubst \
    < templates/nginx/default.conf.template \
    > "$DEPLOY_DIR/nginx/default.conf"

# Właściciel

chown -R "$SSH_USER:$SSH_USER" "$DEPLOY_DIR"

# Raport

echo "[INFO] Generated: $DEPLOY_DIR/compose.yml" | tee -a "$REPORT_FILE"
echo "[INFO] Generated: $DEPLOY_DIR/nginx/default.conf" | tee -a "$REPORT_FILE"

echo "" | tee -a "$REPORT_FILE"
echo "[OK] STEP 06 COMPLETED" | tee -a "$REPORT_FILE"

exit 0