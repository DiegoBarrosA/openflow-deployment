# GitHub Secrets Setup Guide

This guide explains how to configure GitHub Secrets for deploying OpenFlow to AWS EKS with Oracle Autonomous Database.

## Overview

GitHub Secrets are used to securely store sensitive information required for deployment. These secrets are accessed by GitHub Actions workflows and used to create Kubernetes secrets in your EKS cluster.

## Prerequisites

- GitHub repository with Actions enabled
- AWS account with EKS access
- Oracle Autonomous Database instance
- Database wallet files downloaded

## Step 1: Access GitHub Secrets

1. Navigate to your GitHub repository
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** to add each secret

## Step 2: Configure AWS Credentials

### AWS_ACCESS_KEY_ID
- **Description**: AWS access key ID for EKS cluster access
- **How to get**: AWS Console → IAM → Users → Security credentials → Access keys
- **Format**: `AKIAIOSFODNN7EXAMPLE`
- **Required**: Yes

### AWS_SECRET_ACCESS_KEY
- **Description**: AWS secret access key
- **How to get**: Same as above (shown only once when created)
- **Format**: Secret string
- **Required**: Yes

### AWS_SESSION_TOKEN (Optional)
- **Description**: Session token for temporary credentials
- **When needed**: Only if using temporary AWS credentials
- **Required**: No (unless using temporary credentials)

## Step 3: Configure Oracle Database Secrets

### ORACLE_DB_USERNAME
- **Description**: Oracle Autonomous Database username
- **Format**: Database username (e.g., `admin`, `openflow_user`)
- **Example**: `admin`
- **Required**: Yes

### ORACLE_DB_PASSWORD
- **Description**: Oracle Autonomous Database password
- **Format**: Database password
- **Security**: Use a strong password
- **Required**: Yes

### ORACLE_DB_URL
- **Description**: Oracle database service name (TNS name)
- **Format**: Service name from `tnsnames.ora` (e.g., `s5fjid90p5pnlifv_high`)
- **How to find**: 
  1. Extract wallet ZIP file
  2. Open `tnsnames.ora`
  3. Find service name (usually ends with `_high`, `_medium`, or `_low`)
  4. Use the service name (not the full TNS descriptor)
- **Example**: `s5fjid90p5pnlifv_high`
- **Required**: Yes

## Step 4: Configure Application Secrets

### JWT_SECRET
- **Description**: Secret key for JWT token signing
- **How to generate**:
  ```bash
  openssl rand -base64 32
  ```
- **Format**: Base64-encoded random string
- **Security**: Use a strong, random secret
- **Required**: Yes

## Step 5: Encode Oracle Wallet Files

### Download Wallet

1. Log in to Oracle Cloud Console
2. Navigate to your Autonomous Database
3. Go to **DB Connection** → **Download Wallet**
4. Download the wallet ZIP file
5. Extract to a temporary location

### Encode Wallet Files

1. **Prepare wallet directory:**
   ```bash
   cd openflow-deployment
   mkdir -p wallet
   # Extract wallet files to wallet/ directory
   unzip Wallet_yourdb.zip -d wallet/
   ```

2. **Run encoding script:**
   ```bash
   ./encode-wallet.sh
   ```

3. **Review output:**
   The script creates `wallet-secrets.env` with base64-encoded values.

4. **⚠️ SECURITY WARNING:**
   - Copy values to GitHub Secrets immediately
   - Delete `wallet-secrets.env` after use
   - Delete `wallet/` directory after use
   - Never commit these files to version control

### Required Wallet Secrets

Copy each value from `wallet-secrets.env` to GitHub Secrets:

#### ORACLE_WALLET_CWALLET
- **Source file**: `cwallet.sso`
- **Format**: Base64-encoded file content
- **Required**: Yes

#### ORACLE_WALLET_EWALLET
- **Source file**: `ewallet.p12`
- **Format**: Base64-encoded file content
- **Required**: Yes

#### ORACLE_WALLET_KEYSTORE
- **Source file**: `keystore.jks`
- **Format**: Base64-encoded file content
- **Required**: Yes

#### ORACLE_WALLET_OJDBC
- **Source file**: `ojdbc.properties`
- **Format**: Base64-encoded file content
- **Required**: Yes

#### ORACLE_WALLET_SQLNET
- **Source file**: `sqlnet.ora`
- **Format**: Base64-encoded file content
- **Required**: Yes

#### ORACLE_WALLET_TNSNAMES
- **Source file**: `tnsnames.ora`
- **Format**: Base64-encoded file content
- **Required**: Yes

#### ORACLE_WALLET_TRUSTSTORE
- **Source file**: `truststore.jks`
- **Format**: Base64-encoded file content
- **Required**: Yes

## Step 6: Verify Secrets

### Check Secret Names

Ensure all secrets use **exact** names as listed above. The workflow is case-sensitive.

### Required Secrets Checklist

- [ ] `AWS_ACCESS_KEY_ID`
- [ ] `AWS_SECRET_ACCESS_KEY`
- [ ] `ORACLE_DB_USERNAME`
- [ ] `ORACLE_DB_PASSWORD`
- [ ] `ORACLE_DB_URL`
- [ ] `JWT_SECRET`
- [ ] `ORACLE_WALLET_CWALLET`
- [ ] `ORACLE_WALLET_EWALLET`
- [ ] `ORACLE_WALLET_KEYSTORE`
- [ ] `ORACLE_WALLET_OJDBC`
- [ ] `ORACLE_WALLET_SQLNET`
- [ ] `ORACLE_WALLET_TNSNAMES`
- [ ] `ORACLE_WALLET_TRUSTSTORE`

## Troubleshooting

### Secret Not Found Error

**Error**: `Secret 'ORACLE_DB_USERNAME' not found`

**Solution**:
1. Verify secret name matches exactly (case-sensitive)
2. Check secret is in the correct repository
3. Ensure secret is added to Actions secrets (not Dependabot secrets)

### Wallet Encoding Issues

#### Error: `base64: invalid input` or `Failed to decode cwallet.sso`

**Symptoms**:
- Workflow fails at "Create Oracle Wallet Secret" step
- Error message: "Failed to decode [filename]"
- Error message: "This usually means the secret is not valid base64"

**Root Causes**:
1. Secrets contain newlines or whitespace that break base64 decoding
2. Secrets were not properly base64 encoded during upload
3. Secrets are empty or corrupted
4. Encoding used wrong base64 flags (added line breaks)

**Solution**:

1. **Re-upload wallet secrets** (recommended):
   ```bash
   cd openflow-deployment
   ./upload-wallet-to-github.sh
   ```
   This script ensures proper encoding and validation.

2. **Verify secrets exist and are non-empty**:
   ```bash
   ./verify-wallet-secrets.sh
   ```

3. **Check workflow logs** for detailed error messages:
   - The "Validate Wallet Secrets Format" step shows format issues
   - The "Create Oracle Wallet Secret" step shows decode errors with diagnostic info

4. **Manual encoding** (if scripts don't work):
   ```bash
   # For GNU base64 (Linux)
   base64 -w 0 wallet/cwallet.sso
   
   # For BSD base64 (macOS)
   base64 wallet/cwallet.sso | tr -d '\n'
   ```
   Copy the output (single line, no newlines) to the GitHub Secret.

5. **Verify encoding requirements**:
   - Base64 string must contain only: A-Z, a-z, 0-9, +, /, =
   - No newlines or whitespace
   - Padding with `=` at the end is allowed (0-2 characters)

6. **Common mistakes to avoid**:
   - ❌ Copying base64 with line breaks
   - ❌ Adding extra spaces or newlines
   - ❌ Using wrong base64 variant (must be standard base64, not URL-safe)
   - ❌ Encoding already-encoded values (double encoding)

**Prevention**:
- Always use `./upload-wallet-to-github.sh` or `./encode-wallet-for-github.sh`
- These scripts validate encoding before upload
- The workflow now includes validation steps that catch issues early

### Database Connection Failure

**Error**: Backend pod fails with database connection error

**Solution**:
1. Verify `ORACLE_DB_URL` matches service name in `tnsnames.ora`
2. Check database credentials are correct
3. Verify wallet files are properly encoded
4. Check wallet secret is created in Kubernetes

### Manual Wallet Encoding

If the scripts don't work, encode manually:

```bash
# For GNU base64 (Linux) - no line wrapping
base64 -w 0 wallet/cwallet.sso

# For BSD base64 (macOS) - remove newlines
base64 wallet/cwallet.sso | tr -d '\n'

# Verify the encoding is valid (should decode successfully)
echo "YOUR_BASE64_STRING" | base64 -d > /tmp/test.bin && echo "✅ Valid base64"
```

**Important**: 
- Copy the entire output (single line, no newlines)
- Paste directly into GitHub Secret value field
- Do not add any spaces or line breaks
- The encoded value should be a long string of characters

### Finding Service Name

1. Extract wallet ZIP
2. Open `tnsnames.ora` in a text editor
3. Find entry like:
   ```
   s5fjid90p5pnlifv_high = (description=...)
   ```
4. Use `s5fjid90p5pnlifv_high` as `ORACLE_DB_URL` value

## Security Best Practices

1. **Never commit secrets to version control**
   - Add `wallet/` and `wallet-secrets.env` to `.gitignore`
   - Review commits before pushing

2. **Use environment-specific secrets**
   - Create separate secrets for staging/production
   - Use GitHub Environments feature

3. **Rotate secrets regularly**
   - Update JWT_SECRET periodically
   - Rotate AWS credentials as per policy
   - Update database passwords regularly

4. **Limit secret access**
   - Use least-privilege IAM policies
   - Restrict GitHub Actions permissions
   - Use environment protection rules

5. **Monitor secret usage**
   - Review GitHub Actions logs
   - Audit secret access
   - Set up alerts for failed deployments

## Updating Secrets

To update a secret:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Find the secret to update
3. Click **Update**
4. Enter new value
5. Save changes
6. Redeploy application (secrets are recreated on each deployment)

## Next Steps

- Review [Installation Guide](installation.md) for deployment steps
- Check [Architecture Documentation](overview.md) for system overview
- See [Workflow Documentation](workflows.md) for CI/CD details

