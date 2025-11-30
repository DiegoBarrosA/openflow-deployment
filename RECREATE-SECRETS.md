# How to Recreate Wallet Secret from GitHub Secrets

The wallet secret in Kubernetes is currently empty. Since your GitHub Secrets are properly configured, you need to re-run the deployment workflow to recreate the secrets.

## Option 1: Re-run GitHub Actions Workflow (Recommended)

1. Go to your GitHub repository: `openflow-deployment`
2. Click on **Actions** tab
3. Find the workflow: **Deploy (on image update or manual)**
4. Click **Run workflow** button (top right)
5. Select environment: **staging** (or production)
6. Click **Run workflow**

This will:
- Read wallet files from GitHub Secrets (`ORACLE_WALLET_*`)
- Decode them from base64
- Create the `oracle-wallet-secret` in Kubernetes
- Restart the backend pod

## Option 2: Manual Secret Recreation (If workflow fails)

If the workflow doesn't work, you can manually recreate the secret using the script:

```bash
# Make sure you have wallet files locally
cd openflow-deployment
./fix-wallet-secret.sh
```

**Note:** This requires the wallet files to be in the `wallet/` directory locally.

## Option 3: Manual Secret Creation from GitHub Secrets

If you have access to decode the GitHub Secrets, you can manually create the secret:

```bash
# Create temporary directory
mkdir -p wallet-temp

# Decode each wallet file from GitHub Secrets (you'll need to copy values from GitHub)
echo 'YOUR_ORACLE_WALLET_CWALLET_VALUE' | base64 -d > wallet-temp/cwallet.sso
echo 'YOUR_ORACLE_WALLET_EWALLET_VALUE' | base64 -d > wallet-temp/ewallet.p12
echo 'YOUR_ORACLE_WALLET_KEYSTORE_VALUE' | base64 -d > wallet-temp/keystore.jks
echo 'YOUR_ORACLE_WALLET_OJDBC_VALUE' | base64 -d > wallet-temp/ojdbc.properties
echo 'YOUR_ORACLE_WALLET_SQLNET_VALUE' | base64 -d > wallet-temp/sqlnet.ora
echo 'YOUR_ORACLE_WALLET_TNSNAMES_VALUE' | base64 -d > wallet-temp/tnsnames.ora
echo 'YOUR_ORACLE_WALLET_TRUSTSTORE_VALUE' | base64 -d > wallet-temp/truststore.jks

# Create the secret
kubectl create secret generic oracle-wallet-secret \
  --from-file=wallet-temp/cwallet.sso \
  --from-file=wallet-temp/ewallet.p12 \
  --from-file=wallet-temp/keystore.jks \
  --from-file=wallet-temp/ojdbc.properties \
  --from-file=wallet-temp/sqlnet.ora \
  --from-file=wallet-temp/tnsnames.ora \
  --from-file=wallet-temp/truststore.jks \
  --dry-run=client -o yaml | kubectl apply -f -

# Clean up
rm -rf wallet-temp

# Restart backend
kubectl delete pod -l app=openflow-backend
```

## Verify Secret After Recreation

```bash
# Check secret exists and has data
kubectl get secret oracle-wallet-secret

# Verify tnsnames.ora is not empty
kubectl get secret oracle-wallet-secret -o jsonpath='{.data.tnsnames\.ora}' | base64 -d | head -5

# Check pod status
kubectl get pods | grep openflow-backend

# Check logs
kubectl logs -l app=openflow-backend --tail=50
```

## Current Issue

The `oracle-wallet-secret` has empty values for all wallet files. This happened because:
- The workflow may not have run after setting GitHub Secrets
- Or the workflow failed to decode the base64 values
- Or the GitHub Secrets themselves are empty

**Solution:** Re-run the workflow to recreate secrets from GitHub Secrets.

