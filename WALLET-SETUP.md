# Oracle Wallet Setup Guide

This guide explains how to set up Oracle wallet files for GitHub Secrets, ensuring secrets are stored securely in GitHub and used by the deployment workflow to create Kubernetes secrets.

## Overview

**Important:** Wallet files should NEVER be packaged into Docker images or committed to git. They must be:
1. Encoded locally
2. Stored as GitHub Secrets
3. Decoded by the workflow to create Kubernetes secrets

## Step 1: Download Wallet from Oracle Cloud

1. Log in to Oracle Cloud Console
2. Navigate to your Autonomous Database
3. Go to **DB Connection** → **Download Wallet**
4. Download the wallet ZIP file
5. Extract it to a `wallet/` directory:
   ```bash
   unzip Wallet_yourdb.zip -d wallet/
   ```

## Step 2: Upload Wallet Files to GitHub Secrets

### Option A: Automatic Upload (Recommended)

Use the upload script to automatically encode and upload wallet files:

```bash
./upload-wallet-to-github.sh
```

**Prerequisites:**
- GitHub CLI (`gh`) installed and authenticated
- Run `gh auth login` if not already authenticated

This script will:
- Check for all required wallet files
- Encode each file to base64
- Upload directly to GitHub Secrets in the deployment repository
- Verify the upload was successful

### Option B: Manual Upload

If you prefer manual setup or don't have GitHub CLI:

```bash
./encode-wallet-for-github.sh
```

This creates `wallet-secrets-github.txt` with encoded values that you can manually copy to GitHub Secrets.

**Required wallet files:**
- `cwallet.sso`
- `ewallet.p12`
- `keystore.jks`
- `ojdbc.properties`
- `sqlnet.ora`
- `tnsnames.ora`
- `truststore.jks`

## Step 3: Add to GitHub Secrets (Manual Method Only)

**Note:** If you used `upload-wallet-to-github.sh`, this step is already done! Skip to Step 4.

If you used the manual encoding script:

1. Go to your GitHub repository: `openflow-deployment`
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. For each secret name shown in the output, click **New repository secret**
4. Copy the exact secret name and encoded value from `wallet-secrets-github.txt`
5. Paste and save

**GitHub Secret names:**
- `ORACLE_WALLET_CWALLET`
- `ORACLE_WALLET_EWALLET`
- `ORACLE_WALLET_KEYSTORE`
- `ORACLE_WALLET_OJDBC`
- `ORACLE_WALLET_SQLNET`
- `ORACLE_WALLET_TNSNAMES`
- `ORACLE_WALLET_TRUSTSTORE`

## Step 4: Clean Up

**IMPORTANT:** Delete the encoded output file after copying to GitHub:

```bash
rm wallet-secrets-github.txt
```

Also ensure wallet files are in `.gitignore` (they should be already).

## Step 5: Deploy

The GitHub Actions workflow will automatically:
1. Read wallet files from GitHub Secrets
2. Decode them from base64
3. Create the `oracle-wallet-secret` in Kubernetes
4. Mount it to the backend pod at `/app/wallet`

Trigger the workflow:
- Push to `main` branch, OR
- Manually trigger: **Actions** → **Deploy (on image update or manual)** → **Run workflow**

## Verification

After deployment, verify the secret was created correctly:

```bash
# Connect to cluster
aws eks update-kubeconfig --region us-east-1 --name openflow-cluster

# Check secret exists
kubectl get secret oracle-wallet-secret

# Verify tnsnames.ora is not empty
kubectl get secret oracle-wallet-secret -o jsonpath='{.data.tnsnames\.ora}' | base64 -d | head -5

# Check backend pod is using the secret
kubectl describe pod -l app=openflow-backend | grep -A 5 "oracle-wallet"
```

## Troubleshooting

### Secret is Empty in Kubernetes

If the `oracle-wallet-secret` has empty values:

1. **Verify GitHub Secrets are set:**
   - Go to repository → Settings → Secrets
   - Ensure all `ORACLE_WALLET_*` secrets exist
   - Check they're not empty

2. **Re-run the deployment workflow:**
   - The workflow decodes GitHub Secrets and creates Kubernetes secrets
   - If workflow failed, check workflow logs

3. **Manual recreation (emergency only):**
   ```bash
   ./fix-wallet-secret.sh
   ```
   ⚠️ Only use this for local testing or emergencies. The proper way is via GitHub Secrets + workflow.

### Wrong Secret Names

The workflow expects exact secret names. If you used different names:
1. Update the workflow file (`.github/workflows/deploy-on-image-update.yml`)
2. Or rename your GitHub Secrets to match

### Wallet Files Missing

If the encoding script reports missing files:
1. Re-download wallet from Oracle Cloud Console
2. Extract all files to `wallet/` directory
3. Re-run encoding script

## Security Best Practices

✅ **DO:**
- Store wallet files only in GitHub Secrets
- Delete encoded output files after use
- Keep wallet files in `.gitignore`
- Use the workflow to create Kubernetes secrets

❌ **DON'T:**
- Commit wallet files to git
- Package wallet files in Docker images
- Store wallet files in Kubernetes ConfigMaps (use Secrets)
- Share encoded wallet values in plain text

## Scripts Reference

- **`upload-wallet-to-github.sh`** - Automatically encode and upload to GitHub Secrets (recommended)
- **`encode-wallet-for-github.sh`** - Encode wallet files for manual GitHub Secrets setup
- **`fix-wallet-secret.sh`** - Manually create Kubernetes secret (emergency/local only)
- **`encode-wallet.sh`** - Deprecated, use `upload-wallet-to-github.sh` instead

## Related Documentation

- [GitHub Secrets Setup Guide](docs/github-secrets-setup.md)
- [Installation Guide](docs/installation.md)
- [Troubleshooting Guide](docs/troubleshooting.md)

