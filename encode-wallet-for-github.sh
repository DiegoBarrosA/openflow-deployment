#!/bin/bash

# Oracle Wallet Encoder for GitHub Secrets
# This script encodes Oracle wallet files and prepares them for GitHub Secrets
# The encoded values should be added to GitHub Secrets, which the workflow will use
# to create Kubernetes secrets during deployment.

set -e

WALLET_DIR="./wallet"
OUTPUT_FILE="wallet-secrets-github.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔐 Encoding Oracle Wallet Files for GitHub Secrets"
echo "=================================================="
echo ""

# Check if wallet directory exists
if [ ! -d "$WALLET_DIR" ]; then
    echo -e "${RED}❌ Wallet directory '$WALLET_DIR' not found!${NC}"
    echo ""
    echo "📋 Please ensure your Oracle wallet files are in a 'wallet' directory:"
    echo "   - cwallet.sso"
    echo "   - ewallet.p12"
    echo "   - keystore.jks"
    echo "   - ojdbc.properties"
    echo "   - sqlnet.ora"
    echo "   - tnsnames.ora"
    echo "   - truststore.jks"
    echo ""
    echo "💡 Download wallet from Oracle Cloud Console:"
    echo "   Autonomous Database → DB Connection → Download Wallet"
    echo ""
    echo "📦 Extract the ZIP file:"
    echo "   unzip Wallet_yourdb.zip -d wallet/"
    exit 1
fi

# Create output file
> "$OUTPUT_FILE"

echo -e "${YELLOW}⚠️  SECURITY WARNING:${NC}"
echo "   - This script creates a file with base64-encoded secrets"
echo "   - NEVER commit $OUTPUT_FILE or wallet files to version control"
echo "   - Delete $OUTPUT_FILE immediately after copying values to GitHub Secrets"
echo "   - Keep wallet files secure and delete them after encoding"
echo ""

# Required wallet files and their GitHub Secret names
declare -A WALLET_FILES=(
    ["cwallet.sso"]="ORACLE_WALLET_CWALLET"
    ["ewallet.p12"]="ORACLE_WALLET_EWALLET"
    ["keystore.jks"]="ORACLE_WALLET_KEYSTORE"
    ["ojdbc.properties"]="ORACLE_WALLET_OJDBC"
    ["sqlnet.ora"]="ORACLE_WALLET_SQLNET"
    ["tnsnames.ora"]="ORACLE_WALLET_TNSNAMES"
    ["truststore.jks"]="ORACLE_WALLET_TRUSTSTORE"
)

# Track which files were found
FOUND_COUNT=0
MISSING_FILES=()

# Encode each wallet file
for file in "${!WALLET_FILES[@]}"; do
    secret_name="${WALLET_FILES[$file]}"
    
    if [ -f "$WALLET_DIR/$file" ]; then
        echo -e "${GREEN}📄 Encoding $file...${NC}"
        
        # Encode to base64 (no line breaks)
        if command -v base64 >/dev/null 2>&1; then
            # Try with -w 0 (no wrap) first (GNU base64)
            # Fallback to BSD base64 and remove newlines
            encoded=$(base64 -w 0 "$WALLET_DIR/$file" 2>/dev/null || base64 "$WALLET_DIR/$file" | tr -d '\n')
            
            if [ -z "$encoded" ]; then
                echo -e "${RED}❌ Failed to encode $file${NC}"
                exit 1
            fi
            
            # Verify the encoded value is valid base64
            if ! echo "$encoded" | grep -qE '^[A-Za-z0-9+/]*={0,2}$'; then
                echo -e "${RED}❌ Encoded $file contains invalid base64 characters${NC}"
                exit 1
            fi
            
            # Verify we can decode it back (sanity check)
            if ! echo -n "$encoded" | base64 -d >/dev/null 2>&1; then
                echo -e "${RED}❌ Encoded $file cannot be decoded (encoding failed)${NC}"
                exit 1
            fi
        else
            echo -e "${RED}❌ base64 command not found!${NC}"
            exit 1
        fi
        
        # Write to output file
        echo "# $file → $secret_name" >> "$OUTPUT_FILE"
        echo "$secret_name=$encoded" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        echo -e "   ${GREEN}✅${NC} $file → $secret_name"
        ((FOUND_COUNT++))
    else
        echo -e "${YELLOW}⚠️  $file not found, skipping...${NC}"
        MISSING_FILES+=("$file")
    fi
done

echo ""
echo "=================================================="

if [ $FOUND_COUNT -eq 0 ]; then
    echo -e "${RED}❌ No wallet files found!${NC}"
    exit 1
fi

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Warning: Some files were missing:${NC}"
    for file in "${MISSING_FILES[@]}"; do
        echo "   - $file"
    done
    echo ""
fi

echo -e "${GREEN}🎉 Wallet encoding complete!${NC}"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Copy the values below to GitHub Secrets:"
echo "   Repository → Settings → Secrets and variables → Actions"
echo ""
echo "2. For each secret name, click 'New repository secret' and paste the value"
echo ""
echo "3. After copying all secrets, DELETE this file:"
echo "   ${RED}rm $OUTPUT_FILE${NC}"
echo ""
echo "4. Re-run the deployment workflow to create Kubernetes secrets"
echo ""
echo "=================================================="
echo ""
echo "GitHub Secrets to add:"
echo ""

# Display the encoded values
cat "$OUTPUT_FILE"

echo ""
echo "=================================================="
echo ""
echo -e "${YELLOW}⚠️  REMEMBER:${NC}"
echo "   - Delete $OUTPUT_FILE after copying to GitHub Secrets"
echo "   - Never commit wallet files or this output file to git"
echo "   - Add to .gitignore if not already present"
echo ""

# Check if .gitignore exists and contains wallet
if [ -f ".gitignore" ]; then
    if ! grep -q "wallet" .gitignore 2>/dev/null; then
        echo -e "${YELLOW}💡 Consider adding to .gitignore:${NC}"
        echo "   echo 'wallet/' >> .gitignore"
        echo "   echo '$OUTPUT_FILE' >> .gitignore"
    fi
else
    echo -e "${YELLOW}💡 Create .gitignore to protect wallet files:${NC}"
    echo "   echo 'wallet/' > .gitignore"
    echo "   echo '$OUTPUT_FILE' >> .gitignore"
fi

echo ""
echo -e "${GREEN}✅ Done! Copy the values above to GitHub Secrets.${NC}"

