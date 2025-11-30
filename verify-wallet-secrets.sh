#!/bin/bash

# Verify that wallet secrets in GitHub are valid base64
# This helps diagnose issues with secret uploads
#
# Note: GitHub doesn't allow reading secret values directly for security reasons.
# This script can only verify that secrets exist. To fully validate base64 format,
# you need to check the workflow logs or re-upload the secrets.

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
MISSING_SECRETS=()

for secret in "${WALLET_SECRETS[@]}"; do
    echo -n "Checking $secret... "
    
    # Check if secret exists
    if ! gh secret list --repo "$REPO_OWNER/$REPO_NAME" | grep -q "^$secret"; then
        echo "❌ NOT FOUND"
        ALL_OK=0
        MISSING_SECRETS+=("$secret")
        continue
    fi
    
    # GitHub doesn't allow reading secret values, so we can only verify they exist
    echo "✅ EXISTS"
done

echo ""

if [ $ALL_OK -eq 1 ]; then
    echo "✅ All wallet secrets exist in GitHub"
    echo ""
    echo "📋 Next Steps:"
    echo ""
    echo "1. If the workflow is failing with 'invalid base64' errors:"
    echo "   - The secrets might be empty or incorrectly encoded"
    echo "   - Re-upload them using: ./upload-wallet-to-github.sh"
    echo "   - Make sure wallet files are valid before uploading"
    echo ""
    echo "2. To verify base64 format, check the workflow logs:"
    echo "   - The 'Validate Wallet Secrets Format' step will show format issues"
    echo "   - The 'Create Oracle Wallet Secret' step will show decode errors"
    echo ""
    echo "3. Ensure encoding uses:"
    echo "   - GNU base64: base64 -w 0 <file>"
    echo "   - BSD base64: base64 <file> | tr -d '\\n'"
    echo ""
    echo "4. The workflow now includes validation steps that will:"
    echo "   - Check if secrets are non-empty"
    echo "   - Validate base64 character set"
    echo "   - Provide detailed error messages if decoding fails"
else
    echo "❌ Some secrets are missing:"
    for secret in "${MISSING_SECRETS[@]}"; do
        echo "   - $secret"
    done
    echo ""
    echo "To fix this:"
    echo "1. Upload missing secrets using:"
    echo "   ./upload-wallet-to-github.sh"
    echo ""
    echo "2. Or manually add them in GitHub:"
    echo "   Settings → Secrets and variables → Actions → New repository secret"
    echo ""
    echo "3. Use the encoding script to get base64 values:"
    echo "   ./encode-wallet-for-github.sh"
fi

