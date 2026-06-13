#!/bin/bash

# Przerwij skrypt przy pierwszym błędzie
set -e

# Błąd przy użyciu niezdefiniowanej zmiennej
set -u

# Utworzenie katalogu logów jeśli nie istnieje
mkdir -p logs

# Ścieżka do raportu instalacji
REPORT_FILE="logs/install-report.log"

echo "" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"
echo "STEP 04 - GITHUB SSH" | tee -a "$REPORT_FILE"
echo "$(date)" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"

# Root required
if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Run script as root." | tee -a "$REPORT_FILE"
    exit 1
fi

# Load .env
if [ ! -f ".env" ]; then
    echo "[ERROR] File .env not found." | tee -a "$REPORT_FILE"
    exit 1
fi

# shellcheck disable=SC1091
source .env

# Validation
if [ -z "${SSH_USER:-}" ]; then
    echo "[ERROR] SSH_USER is not defined in .env" | tee -a "$REPORT_FILE"
    exit 1
fi

SSH_KEY_TYPE="${SSH_KEY_TYPE:-ed25519}"

SSH_DIR="/home/$SSH_USER/.ssh"
PRIVATE_KEY="$SSH_DIR/id_$SSH_KEY_TYPE"
PUBLIC_KEY="$PRIVATE_KEY.pub"

# Ensure .ssh directory exists
mkdir -p "$SSH_DIR"

chown "$SSH_USER:$SSH_USER" "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Generate key if missing
if [ ! -f "$PRIVATE_KEY" ]; then

    echo "[INFO] Generating SSH key." | tee -a "$REPORT_FILE"

    sudo -u "$SSH_USER" ssh-keygen \
        -t "$SSH_KEY_TYPE" \
        -N "" \
        -f "$PRIVATE_KEY"

    chmod 600 "$PRIVATE_KEY"
    chmod 644 "$PUBLIC_KEY"

fi

# Add GitHub to known_hosts
if ! grep -q "github.com" "$SSH_DIR/known_hosts" 2>/dev/null; then
    echo "[INFO] Adding github.com to known_hosts." | tee -a "$REPORT_FILE"
    sudo -u "$SSH_USER" ssh-keyscan github.com >> "$SSH_DIR/known_hosts"

fi

chmod 644 "$SSH_DIR/known_hosts"

# Test GitHub connection
set +e

sudo -u "$SSH_USER" ssh \
    -o BatchMode=yes \
    -o StrictHostKeyChecking=yes \
    -T git@github.com >/tmp/github-test.log 2>&1

SSH_RESULT=$?

set -e

# Success
if [ "$SSH_RESULT" -eq 1 ]; then
    echo "[OK] GitHub SSH connection verified." | tee -a "$REPORT_FILE"
    exit 0

fi

# Manual action required
echo ""
echo "############################################################"
echo "#                                                          #"
echo "#                    ACTION REQUIRED                       #"
echo "#                                                          #"
echo "############################################################"
echo ""

echo "Add the following SSH key to GitHub:"
echo ""

cat "$PUBLIC_KEY"

echo ""
echo "GitHub page:"
echo "https://github.com/settings/keys"
echo ""

echo "After adding the key run:"
echo ""
echo "sudo ./install.sh"
echo ""

exit 10