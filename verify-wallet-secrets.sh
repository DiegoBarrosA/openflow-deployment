#!/bin/bash

# Verify that wallet secrets in GitHub are valid base64
# This helps diagnose issues with secret uploads

set -e

REPO_OWNER="${1:-DiegoBarrosA}"
REPO_NAME="${2:-openflow-deployment}"

echo "🔍 Verifying Wallet Secrets in GitHub"
echo "Repository: $REPO_OWNER/$REPO_NAME"
echo ""

if ! command -v gh >/dev/null 2>&1; then
    echo "❌ GitHub CLI (gh) not found"
    echo "Install: https://cli.github.com/"
    exit 1
fi

if ! gh auth status &>/dev/null; then
    echo "❌ GitHub CLI not authenticated"
    echo "Run: gh auth login"
    exit 1
fi

WALLET_SECRETS=(
    "ORACLE_WALLET_CWALLET"
    "ORACLE_WALLET_EWALLET"
    "ORACLE_WALLET_KEYSTORE"
    "ORACLE_WALLET_OJDBC"
    "ORACLE_WALLET_SQLNET"
    "ORACLE_WALLET_TNSNAMES"
    "ORACLE_WALLET_TRUSTSTORE"
)

echo "Checking secrets..."
echo ""

ALL_OK=1

for secret in "${WALLET_SECRETS[@]}"; do
    echo -n "Checking $secret... "
    
    # Check if secret exists
    if ! gh secret list --repo "$REPO_OWNER/$REPO_NAME" | grep -q "^$secret"; then
        echo "❌ NOT FOUND"
        ALL_OK=0
        continue
    fi
    
    # Try to get secret value (this won't work directly, but we can check if it exists)
    # GitHub doesn't allow reading secret values, so we can only verify they exist
    echo "✅ EXISTS"
done

echo ""

if [ $ALL_OK -eq 1 ]; then
    echo "✅ All wallet secrets exist in GitHub"
    echo ""
    echo "If the workflow is still failing with 'invalid base64' errors:"
    echo "1. The secrets might be empty or incorrectly encoded"
    echo "2. Re-upload them using: ./upload-wallet-to-github.sh"
    echo "3. Make sure wallet files are valid before uploading"
else
    echo "❌ Some secrets are missing"
    echo ""
    echo "Upload missing secrets using:"
    echo "  ./upload-wallet-to-github.sh"
fi

