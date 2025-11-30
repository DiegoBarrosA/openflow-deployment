#!/bin/bash

# Diagnostic script to check wallet secrets and help fix issues

set -e

REPO_OWNER="${1:-DiegoBarrosA}"
REPO_NAME="${2:-openflow-deployment}"

echo "🔍 Wallet Secrets Diagnostic Tool"
echo "=================================="
echo "Repository: $REPO_OWNER/$REPO_NAME"
echo ""

# Check GitHub CLI
if ! command -v gh >/dev/null 2>&1; then
    echo "❌ GitHub CLI (gh) not found"
    exit 1
fi

if ! gh auth status &>/dev/null; then
    echo "❌ GitHub CLI not authenticated"
    exit 1
fi

echo "1. Checking which wallet secrets exist..."
echo ""

REQUIRED_SECRETS=(
    "ORACLE_WALLET_CWALLET"
    "ORACLE_WALLET_EWALLET"
    "ORACLE_WALLET_KEYSTORE"
    "ORACLE_WALLET_OJDBC"
    "ORACLE_WALLET_SQLNET"
    "ORACLE_WALLET_TNSNAMES"
    "ORACLE_WALLET_TRUSTSTORE"
)

EXISTING_SECRETS=$(gh secret list --repo "$REPO_OWNER/$REPO_NAME" 2>/dev/null | awk '{print $1}')

MISSING=()
EXISTS=()

for secret in "${REQUIRED_SECRETS[@]}"; do
    if echo "$EXISTING_SECRETS" | grep -q "^$secret$"; then
        EXISTS+=("$secret")
        echo "  ✅ $secret"
    else
        MISSING+=("$secret")
        echo "  ❌ $secret (MISSING)"
    fi
done

echo ""

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "❌ Missing secrets: ${MISSING[*]}"
    echo ""
    echo "Upload missing secrets using:"
    echo "  ./upload-wallet-to-github.sh"
    exit 1
fi

echo "✅ All required secrets exist"
echo ""

# Check for old/incorrect secret names
echo "2. Checking for old/incorrect secret names..."
OLD_SECRETS=$(gh secret list --repo "$REPO_OWNER/$REPO_NAME" 2>/dev/null | grep "ORACLE_WALLET" | awk '{print $1}')

for old_secret in ORACLE_WALLET_P12 ORACLE_WALLET_PEM ORACLE_WALLET_SSO; do
    if echo "$OLD_SECRETS" | grep -q "^$old_secret$"; then
        echo "  ⚠️  Found old secret name: $old_secret"
        echo "     This is not used by the workflow. You can delete it."
    fi
done

echo ""

# Test local encoding
echo "3. Testing local wallet file encoding..."
if [ -d "wallet" ] && [ -f "wallet/cwallet.sso" ]; then
    if base64 -w 0 wallet/cwallet.sso > /tmp/test_encode.txt 2>/dev/null; then
        ENCODED_SIZE=$(wc -c < /tmp/test_encode.txt)
        echo "  ✅ Local encoding works (${ENCODED_SIZE} characters)"
        
        # Test decode
        if base64 -d /tmp/test_encode.txt > /tmp/test_decode.sso 2>/dev/null; then
            ORIGINAL_SIZE=$(wc -c < wallet/cwallet.sso)
            DECODED_SIZE=$(wc -c < /tmp/test_decode.sso)
            if [ "$ORIGINAL_SIZE" -eq "$DECODED_SIZE" ]; then
                echo "  ✅ Local decoding works ($ORIGINAL_SIZE bytes)"
            else
                echo "  ❌ Local decoding size mismatch"
            fi
            rm -f /tmp/test_decode.sso
        else
            echo "  ❌ Local decoding failed"
        fi
        rm -f /tmp/test_encode.txt
    else
        echo "  ❌ Local encoding failed"
    fi
else
    echo "  ⚠️  Wallet directory not found locally"
fi

echo ""

# Recommendations
echo "4. Recommendations:"
echo ""

if [ ${#MISSING[@]} -eq 0 ]; then
    echo "  All secrets exist, but workflow is failing to decode them."
    echo ""
    echo "  This usually means:"
    echo "  1. Secrets were uploaded incorrectly (not base64 encoded)"
    echo "  2. Secrets are empty"
    echo "  3. Secrets got corrupted"
    echo ""
    echo "  Solution: Re-upload all secrets:"
    echo "    ./upload-wallet-to-github.sh"
    echo ""
    echo "  Or use the quick re-upload script:"
    echo "    ./reupload-wallet-secrets.sh"
else
    echo "  Upload missing secrets using:"
    echo "    ./upload-wallet-to-github.sh"
fi

echo ""
echo "5. Test workflow:"
echo "  A test workflow has been created: .github/workflows/test-github-secret-workflow.yml"
echo "  Run it to test if secrets can be decoded in GitHub Actions"
echo ""

