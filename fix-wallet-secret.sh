#!/bin/bash

# Script to manually recreate oracle-wallet-secret in Kubernetes
# 
# ⚠️  IMPORTANT: This is for LOCAL/EMERGENCY use only!
# 
# The proper way is to:
# 1. Use encode-wallet-for-github.sh to encode wallet files
# 2. Add encoded values to GitHub Secrets
# 3. Let the GitHub Actions workflow create the Kubernetes secret
#
# This script should only be used if:
# - You need to test locally
# - The workflow is not available
# - You're doing emergency troubleshooting

set -e

echo "🔐 Manually Recreating Oracle Wallet Secret in Kubernetes"
echo "=========================================================="
echo ""
echo "⚠️  WARNING: This creates secrets directly in Kubernetes"
echo "   The proper way is to use GitHub Secrets + workflow"
echo ""

# Check if kubectl is available
if ! command -v kubectl >/dev/null 2>&1; then
    echo "❌ kubectl not found! Please install kubectl first."
    exit 1
fi

# Check if connected to cluster
if ! kubectl cluster-info &>/dev/null; then
    echo "❌ Not connected to Kubernetes cluster!"
    echo ""
    echo "Connect to your EKS cluster first:"
    echo "  aws eks update-kubeconfig --region us-east-1 --name openflow-cluster"
    exit 1
fi

# Create temporary directory
mkdir -p wallet-temp
trap "rm -rf wallet-temp" EXIT

echo "Checking for local wallet files..."

if [ ! -d "wallet" ]; then
    echo "❌ Wallet directory not found!"
    echo ""
    echo "Please either:"
    echo "1. Extract wallet files to ./wallet/ directory, OR"
    echo "2. Use GitHub Secrets + workflow (recommended):"
    echo "   ./encode-wallet-for-github.sh"
    echo "   Then add values to GitHub Secrets and re-run workflow"
    exit 1
fi

# Check for required files
REQUIRED_FILES=("cwallet.sso" "ewallet.p12" "keystore.jks" "ojdbc.properties" "sqlnet.ora" "tnsnames.ora" "truststore.jks")
MISSING=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "wallet/$file" ]; then
        MISSING+=("$file")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "❌ Missing required wallet files:"
    for file in "${MISSING[@]}"; do
        echo "   - wallet/$file"
    done
    exit 1
fi

echo "✅ Wallet directory found with all required files"
echo ""
echo "Creating Kubernetes secret from local wallet files..."

kubectl create secret generic oracle-wallet-secret \
  --from-file=cwallet.sso=wallet/cwallet.sso \
  --from-file=ewallet.p12=wallet/ewallet.p12 \
  --from-file=keystore.jks=wallet/keystore.jks \
  --from-file=ojdbc.properties=wallet/ojdbc.properties \
  --from-file=sqlnet.ora=wallet/sqlnet.ora \
  --from-file=tnsnames.ora=wallet/tnsnames.ora \
  --from-file=truststore.jks=wallet/truststore.jks \
  --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "✅ Wallet secret recreated in Kubernetes!"
echo ""
echo "Verifying secret..."
kubectl get secret oracle-wallet-secret -o jsonpath='{.data}' | jq -r 'keys[]' 2>/dev/null || kubectl get secret oracle-wallet-secret

echo ""
echo "Restarting backend pod to use new secret..."
kubectl delete pod -l app=openflow-backend --wait=false

echo ""
echo "✅ Done! Check pod status:"
echo "  kubectl get pods | grep openflow-backend"
echo ""
echo "📋 Note: For production, use GitHub Secrets + workflow instead:"
echo "  ./encode-wallet-for-github.sh"

