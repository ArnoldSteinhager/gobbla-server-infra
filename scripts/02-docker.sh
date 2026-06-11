#!/bin/bash

# Przerwij skrypt przy pierwszym błędzie

set -e

# Błąd przy użyciu niezdefiniowanej zmiennej

set -u

# Ścieżka do raportu instalacji

REPORT_FILE="logs/install-report.log"

# Nagłówek raportu

echo "" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"
echo "STEP 02 - DOCKER" | tee -a "$REPORT_FILE"
echo "$(date)" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"

# Sprawdzenie czy skrypt został uruchomiony jako root

if [ "$EUID" -ne 0 ]; then
echo "[ERROR] Uruchom skrypt jako root." | tee -a "$REPORT_FILE"
exit 1
fi

# Instalacja pakietów wymaganych przez repozytorium Docker

apt install -y ca-certificates curl gnupg

# Utworzenie katalogu na klucze repozytoriów APT

install -m 0755 -d /etc/apt/keyrings

# Pobranie klucza GPG repozytorium Docker

curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# Nadanie praw odczytu dla klucza

chmod a+r /etc/apt/keyrings/docker.asc

# Dodanie oficjalnego repozytorium Docker

echo 
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] 
https://download.docker.com/linux/ubuntu 
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" 
| tee /etc/apt/sources.list.d/docker.list > /dev/null

# Aktualizacja listy pakietów

apt update

# Instalacja lub aktualizacja Dockera do najnowszej wersji

apt install -y 
docker-ce 
docker-ce-cli 
containerd.io 
docker-buildx-plugin 
docker-compose-plugin

# Włączenie automatycznego startu usługi Docker

systemctl enable docker

# Uruchomienie usługi Docker

systemctl start docker

# Dodanie użytkownika instalacyjnego do grupy docker

if [ -n "${SUDO_USER:-}" ]; then
usermod -aG docker "$SUDO_USER"
echo "[OK] Added user to docker group: $SUDO_USER" | tee -a "$REPORT_FILE"
fi

# Zapis statusu usługi Docker

echo "[OK] Docker status: $(systemctl is-active docker)" | tee -a "$REPORT_FILE"
echo "[OK] Docker enabled: $(systemctl is-enabled docker)" | tee -a "$REPORT_FILE"

# Zapis wersji Docker Engine

echo "" | tee -a "$REPORT_FILE"
echo "--- DOCKER VERSION ---" | tee -a "$REPORT_FILE"
docker --version | tee -a "$REPORT_FILE"

# Zapis wersji Docker Compose

echo "" | tee -a "$REPORT_FILE"
echo "--- DOCKER COMPOSE VERSION ---" | tee -a "$REPORT_FILE"
docker compose version | tee -a "$REPORT_FILE"

# Informacja o konieczności ponownego logowania

echo "" | tee -a "$REPORT_FILE"
echo "[INFO] User must re-login for docker group membership to take effect." | tee -a "$REPORT_FILE"

# Zakończenie kroku

echo "" | tee -a "$REPORT_FILE"
echo "[OK] STEP 02 COMPLETED" | tee -a "$REPORT_FILE"
