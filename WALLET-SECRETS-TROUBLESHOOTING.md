# Wallet Secrets Troubleshooting

## Current Issue: "base64: invalid input" Error

The workflow is failing with `base64: invalid input` when trying to decode wallet secrets. This means the secrets in GitHub are either:
1. Empty
2. Not properly base64 encoded
3. Corrupted during upload

## Solution: Re-upload Wallet Secrets

The wallet secrets need to be re-uploaded correctly. Follow these steps:

### Step 1: Verify Current Secrets

```bash
./verify-wallet-secrets.sh
```

This will check if all secrets exist in GitHub.

### Step 2: Re-upload All Wallet Secrets

```bash
./upload-wallet-to-github.sh
```

This script will:
- Encode each wallet file to base64
- Upload to GitHub Secrets in the deployment repository
- Show success/failure for each upload

**Important:** Make sure you have the wallet files in the `wallet/` directory before running.

### Step 3: Verify Upload Success

After uploading, verify the secrets were created:

```bash
gh secret list --repo DiegoBarrosA/openflow-deployment | grep ORACLE_WALLET
```

You should see all 7 secrets listed.

### Step 4: Re-run Workflow

After re-uploading, trigger the deployment workflow again. It should now successfully decode the wallet files.

## Why This Happens

The `base64: invalid input` error occurs when:
- The secret value is empty (GitHub shows it exists but it's empty)
- The secret was uploaded without base64 encoding
- The secret value got corrupted (unlikely but possible)

## Prevention

Always use `./upload-wallet-to-github.sh` to upload wallet secrets. This ensures:
- Files are properly base64 encoded
- All required files are uploaded
- Secrets are stored in the correct repository (deployment repo)

## Manual Verification

If you need to manually verify a secret is valid base64:

1. You can't read secret values directly (GitHub security)
2. But you can test by creating a test secret:
   ```bash
   echo "test" | base64 | gh secret set TEST_BASE64 --repo DiegoBarrosA/openflow-deployment --body -
   ```
3. Then in a workflow, try to decode it to verify the process works

## Next Steps

1. Run `./upload-wallet-to-github.sh` to re-upload all wallet secrets
2. Wait for the script to complete successfully
3. Re-run the deployment workflow
4. The workflow should now successfully decode and create the Kubernetes secret





