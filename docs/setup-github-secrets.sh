#!/bin/bash

set -euo pipefail
umask 077

# A projekt gyökere a docs mappa szülőmappája
PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$PROJECT_DIR/.env"

echo "======================================"
echo " GitHub Secrets Auto Setup"
echo "======================================"
echo

# 1. Ellenőrizzük, hogy a GitHub CLI (gh) telepítve van-e
if ! command -v gh >/dev/null 2>&1; then
    echo "ERROR: GitHub CLI (gh) is not installed."
    echo "Please install it using: sudo apt install gh"
    exit 1
fi

# 2. Ellenőrizzük a GitHub CLI bejelentkezési státuszát
if ! gh auth status >/dev/null 2>&1; then
    echo "ERROR: You are not logged in to GitHub CLI."
    echo "Please run 'gh auth login' first."
    exit 1
fi

# 3. Ellenőrizzük, hogy létezik-e a .env fájl
if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: .env file not found at $ENV_FILE"
    echo "Please run restore-database.sh first to generate database credentials."
    exit 1
fi

# 4. Beolvassuk a .env változókat
echo "Reading credentials from $ENV_FILE..."
set -a
source "$ENV_FILE"
set +a

if [ -z "${DB_URL:-}" ] || [ -z "${DB_USER:-}" ] || [ -z "${DB_PASS:-}" ]; then
    echo "ERROR: Missing DB_URL, DB_USER, or DB_PASS in .env file."
    exit 1
fi

# 5. Titkok feltöltése a GitHub repository-ba
echo
echo "Uploading secrets to GitHub repository..."

echo "$DB_URL" | gh secret set DB_URL
echo "-> DB_URL set successfully."

echo "$DB_USER" | gh secret set DB_USER
echo "-> DB_USER set successfully."

echo "$DB_PASS" | gh secret set DB_PASS
echo "-> DB_PASS set successfully."

echo
echo "======================================"
echo " SUCCESS! All GitHub secrets updated."
echo "======================================"
