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
echo "📋 Where should secrets be uploaded?"
echo ""
echo "   The workflow uses an environment context (staging/production)."
echo "   Secrets MUST be set at the environment level for the workflow to access them."
echo ""
echo "   1) Environment level (recommended for workflows with environments)"
echo "   2) Repository level (if workflow doesn't use environments)"
echo ""
read -p "Choose option (1 or 2, default: 1): " SECRET_LOCATION
echo ""

# Clear any leftover input
SECRET_LOCATION=$(echo "$SECRET_LOCATION" | tr -d '[:space:]')

if [[ "$SECRET_LOCATION" == "2" ]]; then
    UPLOAD_TO_ENV=false
    ENV_NAME=""
    echo -e "${YELLOW}⚠️  Note: If your workflow uses an environment, repository-level secrets won't be accessible${NC}"
    echo ""
else
    UPLOAD_TO_ENV=true
    echo "Which environment should secrets be uploaded to?"
    echo "   (Enter 'staging' or 'production', or press Enter for default: staging)"
    read -r ENV_NAME
    
    # Trim whitespace and handle empty input
    ENV_NAME=$(echo "$ENV_NAME" | xargs)
    
    # If empty or looks like a yes/no answer from previous prompt, use default
    if [ -z "$ENV_NAME" ] || [[ "$ENV_NAME" =~ ^[YyNn]$ ]]; then
        ENV_NAME="staging"
        echo -e "${YELLOW}   Using default environment: staging${NC}"
    fi
    
    # Validate it's a reasonable environment name
    if [[ ! "$ENV_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo -e "${RED}❌ Invalid environment name: $ENV_NAME${NC}"
        echo "   Environment names must contain only letters, numbers, hyphens, and underscores"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Will upload to environment: $ENV_NAME${NC}"
    echo ""
    
    # Verify environment exists
    if command -v gh >/dev/null 2>&1; then
        echo "Verifying environment exists..."
        if gh api "repos/$REPO_OWNER/$REPO_NAME/environments/$ENV_NAME" >/dev/null 2>&1; then
            echo -e "   ${GREEN}✅ Environment '$ENV_NAME' exists${NC}"
        else
            echo -e "${YELLOW}⚠️  Warning: Environment '$ENV_NAME' may not exist${NC}"
            echo "   Available environments:"
            gh api "repos/$REPO_OWNER/$REPO_NAME/environments" 2>/dev/null | grep -o '"name":"[^"]*' | cut -d'"' -f4 || echo "   (Could not list environments)"
            echo ""
            read -p "Continue anyway? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
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
echo "📋 Choose output method:"
echo ""
echo "   1) Display secrets for manual copy (recommended if upload fails)"
echo "   2) Upload to GitHub Secrets automatically"
echo ""
read -p "Choose option (1 or 2, default: 1): " OUTPUT_METHOD
OUTPUT_METHOD=$(echo "$OUTPUT_METHOD" | tr -d '[:space:]')
OUTPUT_METHOD="${OUTPUT_METHOD:-1}"

if [[ "$OUTPUT_METHOD" == "1" ]]; then
    echo ""
    echo "=================================================="
    echo "📋 SECRET VALUES FOR MANUAL COPY"
    echo "=================================================="
    echo ""
    echo "Copy each secret value below and paste it into GitHub:"
    echo "Settings → Environments → staging → Secrets → New secret"
    echo ""
    echo "⚠️  IMPORTANT: Copy the ENTIRE value (it's a long single line)"
    echo ""
fi

echo ""
echo "📤 Processing wallet files..."
echo "   Repository: $REPO_OWNER/$REPO_NAME"
if [ "$OUTPUT_METHOD" == "2" ]; then
    echo "   Upload method: Automatic"
else
    echo "   Upload method: Manual copy (display only)"
fi
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
            # Create temp file for encoded value - write directly to avoid shell variable size limits
            TEMP_FILE=$(mktemp)
            
            # Encode directly to temp file (no shell variable)
            # Try GNU base64 first (supports -w 0), fallback to BSD base64
            if base64 -w 0 "$file_path" > "$TEMP_FILE" 2>/dev/null; then
                # GNU base64 worked
                :
            elif base64 "$file_path" | tr -d '\n' > "$TEMP_FILE" 2>/dev/null; then
                # BSD base64 worked
                :
            else
                echo -e "${RED}❌ Failed to encode file${NC}"
                rm -f "$TEMP_FILE"
                return 1
            fi
            
            # Verify the encoded file was created and has content
            encoded_length=$(wc -c < "$TEMP_FILE")
            if [ "$encoded_length" -eq 0 ]; then
                echo -e "${RED}❌ Encoded file is empty${NC}"
                rm -f "$TEMP_FILE"
                return 1
            fi
            
            echo "   Encoded length: $encoded_length characters"
            
            # Verify encoding worked by checking file size matches expected
            EXPECTED_BASE64_SIZE=$(( (file_size + 2) / 3 * 4 ))
            if [ $encoded_length -lt $EXPECTED_BASE64_SIZE ]; then
                echo -e "${YELLOW}⚠️  Warning: Encoded length ($encoded_length) is shorter than expected (~$EXPECTED_BASE64_SIZE)${NC}"
            fi
            
            # Show first and last 50 chars for verification
            echo "   First 50 chars: $(head -c 50 "$TEMP_FILE")..."
            echo "   Last 50 chars: ...$(tail -c 50 "$TEMP_FILE")"
            
            # Verify the encoded value is valid base64
            if ! head -c 100 "$TEMP_FILE" | grep -qE '^[A-Za-z0-9+/]*={0,2}$'; then
                echo -e "${RED}❌ Encoded value contains invalid base64 characters${NC}"
                rm -f "$TEMP_FILE"
                return 1
            fi
            echo "   ✅ Base64 format is valid"
            
            # Verify we can decode it back (sanity check)
            if ! base64 -d "$TEMP_FILE" >/dev/null 2>&1; then
                echo -e "${RED}❌ Encoded value cannot be decoded (encoding failed)${NC}"
                rm -f "$TEMP_FILE"
                return 1
            fi
            echo "   ✅ Encoding verified (can be decoded)"
            
            # If manual copy mode, display the secret value
            if [ "$OUTPUT_METHOD" == "1" ]; then
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "📋 Secret: $secret_name"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                echo "Copy the ENTIRE value below (it's one long line):"
                echo ""
                cat "$TEMP_FILE"
                echo ""
                echo ""
                echo "📍 Where to paste:"
                if [ "$UPLOAD_TO_ENV" = true ]; then
                    echo "   GitHub → Settings → Environments → $ENV_NAME → Secrets → New secret"
                else
                    echo "   GitHub → Settings → Secrets and variables → Actions → New repository secret"
                fi
                echo "   Secret name: $secret_name"
                echo "   Value: (paste the entire base64 string above)"
                echo ""
                echo "Press Enter to continue to next secret..."
                read -r
                echo ""
                rm -f "$TEMP_FILE"
                return 0
            fi
            
            echo -n "   Uploading to GitHub Secrets... "
        
        if [ "$UPLOAD_TO_ENV" = true ]; then
            # Upload to environment level
            # Use input redirection - this is more reliable than piping
            # Capture both stdout and stderr to see any errors
            UPLOAD_OUTPUT=$(gh secret set "$secret_name" --repo "$REPO_OWNER/$REPO_NAME" --env "$ENV_NAME" --body - < "$TEMP_FILE" 2>&1)
            UPLOAD_EXIT=$?
            
            if [ $UPLOAD_EXIT -eq 0 ]; then
                echo -e "${GREEN}✅ Uploaded to environment: $ENV_NAME${NC}"
                
                # Verify the upload by checking if secret exists
                if gh secret list --repo "$REPO_OWNER/$REPO_NAME" --env "$ENV_NAME" | grep -q "^$secret_name"; then
                    echo -e "   ${GREEN}✅ Verified: Secret exists in environment $ENV_NAME${NC}"
                    return 0
                else
                    echo -e "   ${YELLOW}⚠️  Warning: Secret uploaded but not found in list${NC}"
                    return 0  # Still consider it success, might be a timing issue
                fi
            else
                echo -e "${RED}❌ Upload failed (exit code: $UPLOAD_EXIT)${NC}"
                echo "   Error output: $UPLOAD_OUTPUT"
                echo "   Try running manually:"
                echo "   gh secret set $secret_name --repo $REPO_OWNER/$REPO_NAME --env $ENV_NAME --body - < <temp-file>"
                echo "   Or test with: echo 'test' | base64 | gh secret set TEST --repo $REPO_OWNER/$REPO_NAME --env $ENV_NAME --body -"
                rm -f "$TEMP_FILE"
                return 1
            fi
        else
            # Upload to repository level
            # Use input redirection - this is more reliable than piping
            UPLOAD_OUTPUT=$(gh secret set "$secret_name" --repo "$REPO_OWNER/$REPO_NAME" --body - < "$TEMP_FILE" 2>&1)
            UPLOAD_EXIT=$?
            
            if [ $UPLOAD_EXIT -eq 0 ]; then
                echo -e "${GREEN}✅ Uploaded to repository${NC}"
                
                # Verify the upload by checking if secret exists
                if gh secret list --repo "$REPO_OWNER/$REPO_NAME" | grep -q "^$secret_name"; then
                    echo -e "   ${GREEN}✅ Verified: Secret exists in repository${NC}"
                    return 0
                else
                    echo -e "   ${YELLOW}⚠️  Warning: Secret uploaded but not found in list${NC}"
                    return 0  # Still consider it success, might be a timing issue
                fi
            else
                echo -e "${RED}❌ Upload failed (exit code: $UPLOAD_EXIT)${NC}"
                echo "   Error output: $UPLOAD_OUTPUT"
                echo "   Try running manually:"
                echo "   gh secret set $secret_name --repo $REPO_OWNER/$REPO_NAME --body - < <temp-file>"
                rm -f "$TEMP_FILE"
                return 1
            fi
        fi
        
        # Clean up temp file (if it still exists - it may have been removed already)
        rm -f "$TEMP_FILE" 2>/dev/null || true
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

if [ "$OUTPUT_METHOD" == "1" ]; then
    echo -e "${GREEN}✅ All secrets displayed for manual copy${NC}"
    echo ""
    echo "📋 Summary:"
    echo "   - Total secrets processed: $FOUND_COUNT"
    echo ""
    echo "📍 Next Steps:"
    echo ""
    if [ "$UPLOAD_TO_ENV" = true ]; then
        echo "1. Go to: https://github.com/$REPO_OWNER/$REPO_NAME/settings/environments/$ENV_NAME/secrets"
        echo ""
        echo "2. For each secret shown above:"
        echo "   - Click 'New secret'"
        echo "   - Name: (use the secret name shown, e.g., ORACLE_WALLET_CWALLET)"
        echo "   - Value: (paste the ENTIRE base64 string - it's one long line)"
        echo "   - Click 'Add secret'"
    else
        echo "1. Go to: https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"
        echo ""
        echo "2. For each secret shown above:"
        echo "   - Click 'New repository secret'"
        echo "   - Name: (use the secret name shown, e.g., ORACLE_WALLET_CWALLET)"
        echo "   - Value: (paste the ENTIRE base64 string - it's one long line)"
        echo "   - Click 'Add secret'"
    fi
    echo ""
    echo "3. After adding all secrets, re-run the deployment workflow"
    echo ""
    echo -e "${GREEN}✅ Done!${NC}"
else
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
    if [ "$UPLOAD_TO_ENV" = true ]; then
        echo "1. Verify secrets in GitHub:"
        echo "   https://github.com/$REPO_OWNER/$REPO_NAME/settings/environments/$ENV_NAME/secrets"
        echo ""
        echo "2. Secrets are set at environment level: $ENV_NAME"
        echo "   The workflow should now be able to access them"
    else
        echo "1. Verify secrets in GitHub:"
        echo "   https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"
        echo ""
        echo "2. ⚠️  If your workflow uses an environment context, you may need to:"
        echo "   - Copy these secrets to the environment level, OR"
        echo "   - Remove the environment requirement from the workflow"
    fi
    echo ""
    echo "3. Re-run the deployment workflow to use the new secrets"
    echo ""
    echo "4. The workflow will create Kubernetes secrets from GitHub Secrets"
    echo ""
    echo -e "${GREEN}✅ Done!${NC}"
fi

