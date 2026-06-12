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
echo "STEP 03 - DIRECTORIES" | tee -a "$REPORT_FILE"
echo "$(date)" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"

# Sprawdzenie czy skrypt został uruchomiony jako root
if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Uruchom skrypt jako root." | tee -a "$REPORT_FILE"
    exit 1
fi

# Sprawdzenie czy istnieje plik .env
if [ ! -f ".env" ]; then
    echo "[ERROR] File .env not found." | tee -a "$REPORT_FILE"
    exit 1
fi

# Wczytanie konfiguracji środowiska
# shellcheck disable=SC1091
source .env

# Sprawdzenie wymaganych zmiennych
if [ -z "${INSTALL_DIR:-}" ]; then
    echo "[ERROR] INSTALL_DIR is not defined in .env" | tee -a "$REPORT_FILE"
    exit 1
fi

if [ -z "${SSH_USER:-}" ]; then
    echo "[ERROR] SSH_USER is not defined in .env" | tee -a "$REPORT_FILE"
    exit 1
fi

# Sprawdzenie czy użytkownik istnieje
if ! id "$SSH_USER" >/dev/null 2>&1; then
    echo "[ERROR] User does not exist: $SSH_USER" | tee -a "$REPORT_FILE"
    exit 1
fi

# Utworzenie katalogu głównego aplikacji
mkdir -p "$INSTALL_DIR"

# Utworzenie katalogu deploy
mkdir -p "$INSTALL_DIR/deploy"

# Utworzenie katalogu scripts
mkdir -p "$INSTALL_DIR/scripts"

# Nadanie właściciela katalogów
chown "$SSH_USER:$SSH_USER" "$INSTALL_DIR"
chown "$SSH_USER:$SSH_USER" "$INSTALL_DIR/deploy"
chown "$SSH_USER:$SSH_USER" "$INSTALL_DIR/scripts"

# Wyświetlenie informacji o katalogach
echo "[OK] Directory exists: $INSTALL_DIR" | tee -a "$REPORT_FILE"
echo "[OK] Directory exists: $INSTALL_DIR/deploy" | tee -a "$REPORT_FILE"
echo "[OK] Directory exists: $INSTALL_DIR/scripts" | tee -a "$REPORT_FILE"

# Wyświetlenie właściciela katalogów
echo "[OK] Owner set to: $SSH_USER" | tee -a "$REPORT_FILE"

# Wyświetlenie struktury katalogów
echo "" | tee -a "$REPORT_FILE"
echo "--- DIRECTORY STRUCTURE ---" | tee -a "$REPORT_FILE"

ls -ld \
    "$INSTALL_DIR" \
    "$INSTALL_DIR/deploy" \
    "$INSTALL_DIR/scripts" | tee -a "$REPORT_FILE"

# Zakończenie kroku
echo "" | tee -a "$REPORT_FILE"
echo "[OK] STEP 03 COMPLETED" | tee -a "$REPORT_FILE"