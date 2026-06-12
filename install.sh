#!/bin/bash

# Przerwij skrypt przy pierwszym błędzie
set -e

# Błąd przy użyciu niezdefiniowanej zmiennej
set -u

# Utworzenie katalogu logów jeśli nie istnieje
mkdir -p logs

# Utworzenie katalogu state jeśli nie istnieje
mkdir -p state

# Ścieżka do raportu instalacji
REPORT_FILE="logs/install-report.log"

# Wyczyszczenie raportu z poprzedniego uruchomienia
: > "$REPORT_FILE"

# Nagłówek raportu
echo "========================================" | tee -a "$REPORT_FILE"
echo "GOBBLA SERVER INFRA INSTALLER" | tee -a "$REPORT_FILE"
echo "$(date)" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"

# Sprawdzenie czy instalator został uruchomiony jako root
if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Uruchom instalator jako root." | tee -a "$REPORT_FILE"
    exit 1
fi

# Wczytanie pliku .env jeśli istnieje
if [ -f ".env" ]; then
    echo "[INFO] Loading .env" | tee -a "$REPORT_FILE"

    # shellcheck disable=SC1091
    source .env
else
    echo "[WARN] File .env not found" | tee -a "$REPORT_FILE"
fi

# Sprawdzenie katalogu scripts
if [ ! -d "scripts" ]; then
    echo "[ERROR] Directory scripts not found" | tee -a "$REPORT_FILE"
    exit 1
fi

# Lista kroków instalacji
STEPS=(
    "01-system-check.sh"
    "02-docker.sh"
)

# Uruchamianie kolejnych kroków
for STEP in "${STEPS[@]}"; do

    # Sprawdzenie czy plik istnieje
    if [ ! -f "scripts/$STEP" ]; then
        echo "[ERROR] Missing script: scripts/$STEP" | tee -a "$REPORT_FILE"
        exit 1
    fi

    echo "" | tee -a "$REPORT_FILE"
    echo "========================================" | tee -a "$REPORT_FILE"
    echo "START: $STEP" | tee -a "$REPORT_FILE"
    echo "========================================" | tee -a "$REPORT_FILE"

    bash "scripts/$STEP"

    echo "========================================" | tee -a "$REPORT_FILE"
    echo "FINISHED: $STEP" | tee -a "$REPORT_FILE"
    echo "========================================" | tee -a "$REPORT_FILE"

done

# Zakończenie instalacji
echo "" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"
echo "[OK] INSTALLATION FINISHED" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"