#!/bin/bash

# Przerwij skrypt przy pierwszym błędzie

set -e

# Błąd przy użyciu niezdefiniowanej zmiennej

set -u

# Ścieżka do raportu instalacji

REPORT_FILE="logs/install-report.log"

# Utworzenie katalogu logów jeśli nie istnieje

mkdir -p logs

# Nagłówek raportu

echo "" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"
echo "STEP 01 - SYSTEM CHECK" | tee -a "$REPORT_FILE"
echo "$(date)" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"

# Sprawdzenie czy skrypt został uruchomiony jako root

if [ "$EUID" -ne 0 ]; then
echo "[ERROR] Uruchom skrypt jako root." | tee -a "$REPORT_FILE"
exit 1
fi

# Aktualizacja listy pakietów

echo "[INFO] Updating package lists" | tee -a "$REPORT_FILE"
apt update

# Aktualizacja zainstalowanych pakietów

echo "[INFO] Upgrading installed packages" | tee -a "$REPORT_FILE"
apt upgrade -y

# Instalacja podstawowych narzędzi wymaganych przez kolejne kroki

PACKAGES=(
git
curl
wget
jq
ca-certificates
gnupg
)

for package in "${PACKAGES[@]}"; do
if dpkg -s "$package" >/dev/null 2>&1; then
echo "[OK] Package already installed: $package" | tee -a "$REPORT_FILE"
else
echo "[INFO] Installing package: $package" | tee -a "$REPORT_FILE"
apt install -y "$package"
fi
done

# Sprawdzenie czy OpenSSH Server jest zainstalowany

if ! dpkg -s openssh-server >/dev/null 2>&1; then
echo "[INFO] Installing OpenSSH Server" | tee -a "$REPORT_FILE"
apt install -y openssh-server
fi

# Włączenie automatycznego startu SSH

systemctl enable ssh

# Uruchomienie usługi SSH

systemctl start ssh

# Zapis statusu SSH do raportu

echo "[OK] SSH status: $(systemctl is-active ssh)" | tee -a "$REPORT_FILE"
echo "[OK] SSH enabled: $(systemctl is-enabled ssh)" | tee -a "$REPORT_FILE"

# Sprawdzenie dostępności interpretera Python

if command -v python3 >/dev/null 2>&1; then
echo "[OK] Python3 found: $(python3 --version)" | tee -a "$REPORT_FILE"
else
echo "[WARN] Python3 not found" | tee -a "$REPORT_FILE"
fi

# Informacje o użytkowniku uruchamiającym instalację

echo "" | tee -a "$REPORT_FILE"
echo "--- USER ---" | tee -a "$REPORT_FILE"

if [ -n "${SUDO_USER:-}" ]; then
    echo "[INFO] Installation user: $SUDO_USER" | tee -a "$REPORT_FILE"
    id "$SUDO_USER" | tee -a "$REPORT_FILE"
else
    echo "[INFO] Installation user: root" | tee -a "$REPORT_FILE"
    id | tee -a "$REPORT_FILE"
fi

# Informacje o pamięci RAM

echo "" | tee -a "$REPORT_FILE"
echo "--- MEMORY ---" | tee -a "$REPORT_FILE"
free -h | tee -a "$REPORT_FILE"

# Informacje o zajętości dysków

echo "" | tee -a "$REPORT_FILE"
echo "--- DISKS ---" | tee -a "$REPORT_FILE"
df -h | tee -a "$REPORT_FILE"

# Lista usług w stanie failed

echo "" | tee -a "$REPORT_FILE"
echo "--- FAILED SERVICES ---" | tee -a "$REPORT_FILE"
systemctl --failed | tee -a "$REPORT_FILE"

# Zakończenie kroku

echo "" | tee -a "$REPORT_FILE"
echo "[OK] STEP 01 COMPLETED" | tee -a "$REPORT_FILE"
