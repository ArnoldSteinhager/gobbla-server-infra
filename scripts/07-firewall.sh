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
echo "STEP 07 - FIREWALL" | tee -a "$REPORT_FILE"
echo "$(date)" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"

# Sprawdzenie czy skrypt został uruchomiony jako root

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Run script as root." | tee -a "$REPORT_FILE"
    exit 1
fi

# Instalacja UFW

if ! command -v ufw >/dev/null 2>&1; then

    echo "[INFO] Installing UFW." | tee -a "$REPORT_FILE"

    apt update
    apt install -y ufw

else

    echo "[INFO] UFW already installed." | tee -a "$REPORT_FILE"

fi

# Domyślne polityki

ufw default deny incoming
ufw default allow outgoing

# Reguły Gobbla

ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Włączenie firewalla

ufw --force enable

# Raport

echo "" | tee -a "$REPORT_FILE"
echo "--- UFW STATUS ---" | tee -a "$REPORT_FILE"

ufw status verbose | tee -a "$REPORT_FILE"

echo "" | tee -a "$REPORT_FILE"
echo "[OK] STEP 07 COMPLETED" | tee -a "$REPORT_FILE"

exit 0