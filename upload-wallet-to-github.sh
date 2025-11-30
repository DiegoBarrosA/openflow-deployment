#!/bin/bash

# Oracle Wallet Uploader for GitHub Secrets
# This script encodes Oracle wallet files and uploads them to GitHub Secrets
# in the deployment repository using the GitHub API.
#
# Secrets are stored in the deployment repo (openflow-deployment), not the backend repo.

set -e

WALLET_DIR="./wallet"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 Oracle Wallet Uploader for GitHub Secrets${NC}"
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

# Check for GitHub CLI or provide instructions
USE_GH_CLI=false
if command -v gh >/dev/null 2>&1; then
    if gh auth status &>/dev/null; then
        USE_GH_CLI=true
        echo -e "${GREEN}✅ GitHub CLI (gh) found and authenticated${NC}"
    else
        echo -e "${YELLOW}⚠️  GitHub CLI found but not authenticated${NC}"
        echo "   Run: gh auth login"
    fi
else
    echo -e "${YELLOW}⚠️  GitHub CLI (gh) not found${NC}"
    echo "   Install: https://cli.github.com/"
    echo "   Or use Personal Access Token method (see below)"
fi

echo ""

# Get repository information
if [ "$USE_GH_CLI" = true ]; then
    REPO_OWNER=$(gh repo view --json owner -q .owner.login 2>/dev/null || echo "")
    REPO_NAME=$(gh repo view --json name -q .name 2>/dev/null || echo "")
    
    if [ -z "$REPO_OWNER" ] || [ -z "$REPO_NAME" ]; then
        echo -e "${YELLOW}⚠️  Could not detect repository from GitHub CLI${NC}"
        echo "   Please provide repository information manually"
        read -p "GitHub username/organization: " REPO_OWNER
        read -p "Repository name (should be 'openflow-deployment'): " REPO_NAME
    else
        echo -e "${GREEN}📦 Detected repository: $REPO_OWNER/$REPO_NAME${NC}"
        read -p "Is this correct? (Y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            read -p "GitHub username/organization: " REPO_OWNER
            read -p "Repository name (should be 'openflow-deployment'): " REPO_NAME
        fi
    fi
else
    echo "Please provide repository information:"
    read -p "GitHub username/organization: " REPO_OWNER
    read -p "Repository name (should be 'openflow-deployment'): " REPO_NAME
fi

# Verify it's the deployment repo
if [[ ! "$REPO_NAME" =~ [Dd]eployment ]]; then
    echo -e "${YELLOW}⚠️  Warning: Repository name doesn't contain 'deployment'${NC}"
    echo "   Secrets should be in the deployment repository (openflow-deployment)"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo -e "${YELLOW}⚠️  SECURITY WARNING:${NC}"
echo "   - Wallet files will be uploaded to GitHub Secrets"
echo "   - They will be encrypted by GitHub"
echo "   - Never commit wallet files to version control"
echo ""
read -p "Continue with upload? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Aborted."
    exit 0
fi
echo ""

# Check wallet directory exists (should already be checked, but double-check)
if [ ! -d "$WALLET_DIR" ]; then
    echo -e "${RED}❌ Wallet directory '$WALLET_DIR' not found!${NC}"
    exit 1
fi

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

# Check for required files
FOUND_COUNT=0
MISSING_FILES=()

echo "Checking for wallet files..."
for file in "${!WALLET_FILES[@]}"; do
    if [ -f "$WALLET_DIR/$file" ]; then
        FOUND_COUNT=$((FOUND_COUNT + 1))
        echo -e "  ${GREEN}✅${NC} Found: $file"
    else
        MISSING_FILES+=("$file")
        echo -e "  ${YELLOW}⚠️${NC}  Missing: $file"
    fi
done

echo ""

if [ $FOUND_COUNT -eq 0 ]; then
    echo -e "${RED}❌ No wallet files found!${NC}"
    exit 1
fi

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Warning: Some files are missing:${NC}"
    for file in "${MISSING_FILES[@]}"; do
        echo "   - $file"
    done
    echo ""
    read -p "Continue with available files? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "📤 Uploading wallet files to GitHub Secrets..."
echo "   Repository: $REPO_OWNER/$REPO_NAME"
echo ""

# Function to upload secret using GitHub CLI
upload_with_gh_cli() {
    local secret_name=$1
    local file_path=$2
    
    echo ""
    echo -e "${BLUE}📤 Preparing to upload: $secret_name${NC}"
    echo "   Source file: $file_path"
    
    # Show file info
    if [ -f "$file_path" ]; then
        file_size=$(wc -c < "$file_path")
        echo "   File size: $file_size bytes"
        
        # Calculate file hash for verification (if available)
        if command -v md5sum >/dev/null 2>&1; then
            file_hash=$(md5sum "$file_path" | cut -d' ' -f1)
            echo "   MD5 hash: $file_hash"
        elif command -v md5 >/dev/null 2>&1; then
            file_hash=$(md5 -q "$file_path")
            echo "   MD5 hash: $file_hash"
        fi
    else
        echo -e "${RED}❌ File not found: $file_path${NC}"
        return 1
    fi
    
    # GitHub CLI can handle binary files directly, but for consistency with workflow
    # we'll base64 encode the file content and upload it
    # The workflow will then base64 decode it
    
    if command -v base64 >/dev/null 2>&1; then
        echo "   Encoding to base64..."
        # Encode to base64 (no line breaks) - this is what the workflow expects
        # Try GNU base64 first (supports -w 0), fallback to BSD base64
        encoded=$(base64 -w 0 "$file_path" 2>/dev/null || base64 "$file_path" | tr -d '\n')
        
        if [ -z "$encoded" ]; then
            echo -e "${RED}❌ Failed to encode file${NC}"
            return 1
        fi
        
        # Show encoded value info
        encoded_length=${#encoded}
        echo "   Encoded length: $encoded_length characters"
        echo "   First 50 chars: ${encoded:0:50}..."
        echo "   Last 50 chars: ...${encoded: -50}"
        
        # Verify the encoded value is valid base64 (should only contain A-Z, a-z, 0-9, +, /, =)
        if ! echo "$encoded" | grep -qE '^[A-Za-z0-9+/]*={0,2}$'; then
            echo -e "${RED}❌ Encoded value contains invalid base64 characters${NC}"
            return 1
        fi
        echo "   ✅ Base64 format is valid"
        
        # Verify we can decode it back (sanity check)
        if ! echo -n "$encoded" | base64 -d >/dev/null 2>&1; then
            echo -e "${RED}❌ Encoded value cannot be decoded (encoding failed)${NC}"
            return 1
        fi
        echo "   ✅ Encoding verified (can be decoded)"
        
        echo -n "   Uploading to GitHub Secrets... "
        
        # Upload using gh CLI - pass base64 encoded value via stdin
        # GitHub CLI encrypts the value before sending to GitHub
        # Use -n flag to avoid adding newline
        if echo -n "$encoded" | gh secret set "$secret_name" --repo "$REPO_OWNER/$REPO_NAME" --body - >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Uploaded${NC}"
            
            # Verify the upload by checking if secret exists
            if gh secret list --repo "$REPO_OWNER/$REPO_NAME" | grep -q "^$secret_name"; then
                echo -e "   ${GREEN}✅ Verified: Secret exists in GitHub${NC}"
                return 0
            else
                echo -e "   ${YELLOW}⚠️  Warning: Secret uploaded but not found in list${NC}"
                return 0  # Still consider it success, might be a timing issue
            fi
        else
            echo -e "${RED}❌ Upload failed${NC}"
            echo "   Try running manually:"
            echo "   echo '<base64-value>' | gh secret set $secret_name --repo $REPO_OWNER/$REPO_NAME --body -"
            return 1
        fi
    else
        echo -e "${RED}❌ base64 command not found${NC}"
        return 1
    fi
}

# Function to upload secret using GitHub API
upload_with_api() {
    local secret_name=$1
    local file_path=$2
    local token=$3
    
    echo -n "   Uploading $secret_name... "
    
    # Get repository public key
    KEY_RESPONSE=$(curl -s -H "Authorization: token $token" \
        "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/secrets/public-key")
    
    KEY_ID=$(echo "$KEY_RESPONSE" | grep -o '"key_id":"[^"]*' | cut -d'"' -f4)
    KEY=$(echo "$KEY_RESPONSE" | grep -o '"key":"[^"]*' | cut -d'"' -f4)
    
    if [ -z "$KEY_ID" ] || [ -z "$KEY" ]; then
        echo -e "${RED}❌ Failed to get repository public key${NC}"
        return 1
    fi
    
    # Encode file to base64
    if command -v base64 >/dev/null 2>&1; then
        # Try GNU base64 first (supports -w 0), fallback to BSD base64
        encoded=$(base64 -w 0 "$file_path" 2>/dev/null || base64 "$file_path" | tr -d '\n')
        
        if [ -z "$encoded" ]; then
            echo -e "${RED}❌ Failed to encode file${NC}"
            return 1
        fi
        
        # Verify the encoded value is valid base64
        if ! echo "$encoded" | grep -qE '^[A-Za-z0-9+/]*={0,2}$'; then
            echo -e "${RED}❌ Encoded value contains invalid base64 characters${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ base64 not found${NC}"
        return 1
    fi
    
    # Encrypt using sodium (requires libsodium or openssl)
    # For simplicity, we'll use a Python script or provide instructions
    # Actually, GitHub API requires encryption with libsodium, which is complex in bash
    # Better to use gh CLI or provide clear instructions
    
    echo -e "${YELLOW}⚠️  API method requires encryption - use GitHub CLI instead${NC}"
    return 1
}

# Upload secrets
SUCCESS_COUNT=0
FAILED_SECRETS=()

if [ "$USE_GH_CLI" = true ]; then
    # Use GitHub CLI
    echo "Found $FOUND_COUNT wallet file(s) to upload"
    echo ""
    for file in "${!WALLET_FILES[@]}"; do
        secret_name="${WALLET_FILES[$file]}"
        
        if [ -f "$WALLET_DIR/$file" ]; then
            set +e  # Temporarily disable exit on error for upload function
            upload_with_gh_cli "$secret_name" "$WALLET_DIR/$file"
            UPLOAD_RESULT=$?
            set -e  # Re-enable exit on error
            if [ $UPLOAD_RESULT -eq 0 ]; then
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                FAILED_SECRETS+=("$secret_name")
            fi
        else
            echo -e "${YELLOW}⚠️  Skipping $file (not found)${NC}"
        fi
    done
else
    # Need to use API with token
    echo ""
    echo "GitHub CLI not available. You have two options:"
    echo ""
    echo "Option 1: Install GitHub CLI (recommended)"
    echo "  https://cli.github.com/"
    echo "  Then run: gh auth login"
    echo ""
    echo "Option 2: Use Personal Access Token"
    echo "  This requires encrypting secrets with libsodium, which is complex."
    echo "  It's easier to:"
    echo "  1. Run: ./encode-wallet-for-github.sh"
    echo "  2. Manually copy values from wallet-secrets-github.txt to GitHub Secrets"
    echo ""
    echo "Or install GitHub CLI and re-run this script."
    exit 1
fi

echo ""
echo "=================================================="

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo -e "${GREEN}✅ Successfully uploaded $SUCCESS_COUNT secret(s)${NC}"
fi

if [ ${#FAILED_SECRETS[@]} -gt 0 ]; then
    echo -e "${RED}❌ Failed to upload ${#FAILED_SECRETS[@]} secret(s):${NC}"
    for secret in "${FAILED_SECRETS[@]}"; do
        echo "   - $secret"
    done
fi

echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Verify secrets in GitHub:"
echo "   https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"
echo ""
echo "2. Re-run the deployment workflow to use the new secrets"
echo ""
echo "3. The workflow will create Kubernetes secrets from GitHub Secrets"
echo ""
echo -e "${GREEN}✅ Done!${NC}"

