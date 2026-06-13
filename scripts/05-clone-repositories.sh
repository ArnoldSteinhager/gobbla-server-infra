#!/bin/bash

# Przerwij skrypt przy pierwszym błędzie

set -e

# Błąd przy użyciu niezdefiniowanej zmiennej

set -u

# Utworzenie katalogu logów jeśli nie istnieje

mkdir -p logs

# Ścieżka do raportu instalacji

REPORT_FILE="logs/install-report.log"

# Nagłówek raportu

echo "" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"
echo "STEP 05 - CLONE REPOSITORIES" | tee -a "$REPORT_FILE"
echo "$(date)" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"

# Sprawdzenie czy skrypt został uruchomiony jako root

if [ "$EUID" -ne 0 ]; then
echo "[ERROR] Run script as root." | tee -a "$REPORT_FILE"
exit 1
fi

# Sprawdzenie czy istnieje plik .env

if [ ! -f ".env" ]; then
echo "[ERROR] File .env not found." | tee -a "$REPORT_FILE"
exit 1
fi

# shellcheck disable=SC1091

source .env

# Walidacja zmiennych

REQUIRED_VARS=(
    SSH_USER
    API_REPO
    UI_REPO
    API_DIR
    UI_DIR
    API_BRANCH
    UI_BRANCH
)

for VAR in "${REQUIRED_VARS[@]}"; do


if [ -z "${!VAR:-}" ]; then
    echo "[ERROR] Missing variable in .env: $VAR" | tee -a "$REPORT_FILE"
    exit 1
fi
done

# Weryfikacja użytkownika

if ! id "$SSH_USER" >/dev/null 2>&1; then
    echo "[ERROR] User does not exist: $SSH_USER" | tee -a "$REPORT_FILE"
    exit 1
fi

# Test połączenia z GitHub

set +e

sudo -u "$SSH_USER" ssh 
-o BatchMode=yes 
-o StrictHostKeyChecking=yes 
-T [git@github.com](mailto:git@github.com) >/tmp/github-test.log 2>&1

SSH_RESULT=$?

set -e

if [ "$SSH_RESULT" -ne 1 ]; then
    echo "[ERROR] GitHub SSH authentication failed." | tee -a "$REPORT_FILE"
    cat /tmp/github-test.log | tee -a "$REPORT_FILE"
    exit 1
fi

echo "[OK] GitHub SSH authentication verified." | tee -a "$REPORT_FILE"

# Klonowanie API

if [ ! -d "$API_DIR/.git" ]; then
    echo "[INFO] Cloning API repository." | tee -a "$REPORT_FILE"
    sudo -u "$SSH_USER" git clone \
        "$API_REPO" \
        "$API_DIR"
else

echo "[INFO] API repository already exists." | tee -a "$REPORT_FILE"
fi

# Klonowanie UI

if [ ! -d "$UI_DIR/.git" ]; then
    echo "[INFO] Cloning UI repository." | tee -a "$REPORT_FILE"
    sudo -u "$SSH_USER" git clone \
        "$UI_REPO" \
        "$UI_DIR"

else
    echo "[INFO] UI repository already exists." | tee -a "$REPORT_FILE"
fi

# Checkout API branch

sudo -u "$SSH_USER" git 
-C "$API_DIR" 
checkout "$API_BRANCH"

# Checkout UI branch

sudo -u "$SSH_USER" git 
-C "$UI_DIR" 
checkout "$UI_BRANCH"

# Właściciel katalogów

chown -R "$SSH_USER:$SSH_USER" "$API_DIR"
chown -R "$SSH_USER:$SSH_USER" "$UI_DIR"

# Informacje o commitach

echo "" | tee -a "$REPORT_FILE"
echo "--- API COMMIT ---" | tee -a "$REPORT_FILE"

sudo -u "$SSH_USER" git 
-C "$API_DIR" 
rev-parse HEAD | tee -a "$REPORT_FILE"

echo "" | tee -a "$REPORT_FILE"
echo "--- UI COMMIT ---" | tee -a "$REPORT_FILE"

sudo -u "$SSH_USER" git 
-C "$UI_DIR" 
rev-parse HEAD | tee -a "$REPORT_FILE"

# Zakończenie kroku

echo "" | tee -a "$REPORT_FILE"
echo "[OK] STEP 05 COMPLETED" | tee -a "$REPORT_FILE"

exit 0
