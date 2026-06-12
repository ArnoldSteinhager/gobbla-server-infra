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

# Ścieżka do pliku stanu

STATE_FILE="state/install-state.json"

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

# Sprawdzenie czy istnieje plik .env

if [ ! -f ".env" ]; then
echo "[ERROR] File .env not found" | tee -a "$REPORT_FILE"
exit 1
fi

# Wczytanie konfiguracji środowiska

echo "[INFO] Loading .env" | tee -a "$REPORT_FILE"

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

# Zapis konfiguracji do raportu

echo "[INFO] Install directory: $INSTALL_DIR" | tee -a "$REPORT_FILE"
echo "[INFO] SSH user: $SSH_USER" | tee -a "$REPORT_FILE"

# Sprawdzenie katalogu scripts

if [ ! -d "scripts" ]; then
echo "[ERROR] Directory scripts not found" | tee -a "$REPORT_FILE"
exit 1
fi

# Lista kroków instalacji

STEPS=(
"01-system-check"
"02-docker"
"03-directories"
)

# Utworzenie pliku stanu jeśli nie istnieje

if [ ! -f "$STATE_FILE" ]; then

cat > "$STATE_FILE" <<EOF
{
"01-system-check": "pending",
"02-docker": "pending",
"03-directories": "pending"
}
EOF

fi

# Odczyt stanu kroku

get_step_status() {
local step_name="$1"

```
jq -r --arg step "$step_name" '.[$step]' "$STATE_FILE"
```

}

# Zapis stanu kroku

set_step_status() {
local step_name="$1"
local status="$2"

```
local tmp_file
tmp_file=$(mktemp)

jq \
    --arg step "$step_name" \
    --arg status "$status" \
    '.[$step] = $status' \
    "$STATE_FILE" > "$tmp_file"

mv "$tmp_file" "$STATE_FILE"
```

}

# Uruchamianie kolejnych kroków

for STEP in "${STEPS[@]}"; do

```
STATUS=$(get_step_status "$STEP")

if [ "$STATUS" = "done" ]; then

    echo "[INFO] Skipping completed step: $STEP" | tee -a "$REPORT_FILE"

    continue

fi

SCRIPT_FILE="scripts/$STEP.sh"

# Sprawdzenie czy plik istnieje
if [ ! -f "$SCRIPT_FILE" ]; then
    echo "[ERROR] Missing script: $SCRIPT_FILE" | tee -a "$REPORT_FILE"
    exit 1
fi

echo "" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"
echo "START: $STEP" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"

bash "$SCRIPT_FILE"

set_step_status "$STEP" "done"

echo "========================================" | tee -a "$REPORT_FILE"
echo "FINISHED: $STEP" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"
```

done

# Zakończenie instalacji

echo "" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"
echo "[OK] INSTALLATION FINISHED" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"
