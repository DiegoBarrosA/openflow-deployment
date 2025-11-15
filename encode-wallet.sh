#!/bin/bash

# Oracle Wallet Encoder for GitHub Secrets
# This script encodes Oracle wallet files for GitHub Secrets

set -e

WALLET_DIR="./wallet"
OUTPUT_FILE="wallet-secrets.env"

if [ ! -d "$WALLET_DIR" ]; then
    echo "❌ Wallet directory '$WALLET_DIR' not found!"
    echo ""
    echo "📋 Please ensure your Oracle wallet files are in a 'wallet' directory:"
    echo "   - cwallet.sso"
    echo "   - ewallet.p12"
    echo "   - ewallet.pem"
    echo "   - tnsnames.ora"
    echo "   - sqlnet.ora"
    echo ""
    echo "💡 Download wallet from Oracle Cloud Console:"
    echo "   Autonomous Database → DB Connection → Download Wallet"
    exit 1
fi

echo "🔐 Encoding Oracle Wallet Files for GitHub Secrets"
echo "=================================================="

# Create output file
> "$OUTPUT_FILE"

# Encode each wallet file
files=("cwallet.sso" "ewallet.p12" "ewallet.pem" "tnsnames.ora" "sqlnet.ora")

for file in "${files[@]}"; do
    if [ -f "$WALLET_DIR/$file" ]; then
        echo "📄 Encoding $file..."
        encoded=$(base64 -w 0 "$WALLET_DIR/$file")

        # Map to GitHub secret names
        case $file in
            "cwallet.sso")
                secret_name="ORACLE_WALLET_SSO"
                ;;
            "ewallet.p12")
                secret_name="ORACLE_WALLET_P12"
                ;;
            "ewallet.pem")
                secret_name="ORACLE_WALLET_PEM"
                ;;
            "tnsnames.ora")
                secret_name="ORACLE_TNSNAMES"
                ;;
            "sqlnet.ora")
                secret_name="ORACLE_SQLNET"
                ;;
        esac

        echo "${secret_name}=${encoded}" >> "$OUTPUT_FILE"
        echo "✅ $file → $secret_name"
    else
        echo "⚠️  $file not found, skipping..."
    fi
done

echo ""
echo "🎉 Wallet encoding complete!"
echo ""
echo "📋 Copy these values to GitHub Secrets (Settings → Secrets and variables → Actions):"
echo ""
cat "$OUTPUT_FILE"
echo ""
echo "🔒 Keep '$OUTPUT_FILE' secure and delete after use!"
echo ""
echo "💡 GitHub Secrets names:"
echo "   - ORACLE_WALLET_SSO"
echo "   - ORACLE_WALLET_P12"
echo "   - ORACLE_WALLET_PEM"
echo "   - ORACLE_TNSNAMES"
echo "   - ORACLE_SQLNET"