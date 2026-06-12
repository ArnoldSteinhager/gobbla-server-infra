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
echo "STEP 02 - DOCKER" | tee -a "$REPORT_FILE"
echo "$(date)" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"

# Sprawdzenie czy skrypt został uruchomiony jako root
if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Uruchom skrypt jako root." | tee -a "$REPORT_FILE"
    exit 1
fi

# Lista pakietów wymaganych do instalacji Docker
PACKAGES=(
    ca-certificates
    curl
    gnupg
)

# Instalacja wymaganych pakietów
for package in "${PACKAGES[@]}"; do
    if dpkg -s "$package" >/dev/null 2>&1; then
        echo "[OK] Package already installed: $package" | tee -a "$REPORT_FILE"
    else
        echo "[INFO] Installing package: $package" | tee -a "$REPORT_FILE"
        apt install -y "$package"
    fi
done

# Utworzenie katalogu na klucze repozytoriów APT
install -m 0755 -d /etc/apt/keyrings

# Usunięcie starych kluczy Docker jeśli istnieją
rm -f /etc/apt/keyrings/docker.asc
rm -f /etc/apt/keyrings/docker.gpg

# Pobranie i konwersja klucza Docker do formatu GPG
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg

# Nadanie praw odczytu do klucza
chmod a+r /etc/apt/keyrings/docker.gpg

# Dodanie repozytorium Docker do APT
cat <<EOF >/etc/apt/sources.list.d/docker.list
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable
EOF

# Aktualizacja listy pakietów
echo "[INFO] Updating package lists" | tee -a "$REPORT_FILE"
apt update

# Instalacja Docker Engine oraz Docker Compose Plugin
apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Włączenie automatycznego uruchamiania Docker po starcie systemu
systemctl enable docker

# Uruchomienie usługi Docker
systemctl start docker

# Dodanie użytkownika wykonującego sudo do grupy docker
if [ -n "${SUDO_USER:-}" ]; then
    usermod -aG docker "$SUDO_USER"
    echo "[OK] Added user to docker group: $SUDO_USER" | tee -a "$REPORT_FILE"
fi

# Zapis statusu usługi Docker
echo "[OK] Docker status: $(systemctl is-active docker)" | tee -a "$REPORT_FILE"
echo "[OK] Docker enabled: $(systemctl is-enabled docker)" | tee -a "$REPORT_FILE"

# Zapis wersji Docker
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