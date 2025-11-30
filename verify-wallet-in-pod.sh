#!/bin/bash

# Script to verify Oracle wallet files are accessible in the Kubernetes pod

set -e

echo "🔍 Verifying Oracle wallet in Kubernetes pod..."
echo ""

# Get the pod name
POD_NAME=$(kubectl get pods -l app=openflow-backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POD_NAME" ]; then
    echo "❌ No backend pod found"
    exit 1
fi

echo "📦 Pod: $POD_NAME"
echo ""

echo "1️⃣ Checking if wallet directory exists..."
kubectl exec "$POD_NAME" -- ls -la /app/wallet/ 2>&1 || echo "❌ Wallet directory not found or not accessible"
echo ""

echo "2️⃣ Checking wallet files..."
kubectl exec "$POD_NAME" -- sh -c 'for file in /app/wallet/*; do echo "  $(basename $file): $(wc -c < "$file" 2>/dev/null || echo "ERROR") bytes"; done'
echo ""

echo "3️⃣ Checking TNS_ADMIN environment variable..."
kubectl exec "$POD_NAME" -- sh -c 'echo "TNS_ADMIN=$TNS_ADMIN"'
echo ""

echo "4️⃣ Checking if cwallet.sso is readable..."
kubectl exec "$POD_NAME" -- test -r /app/wallet/cwallet.sso && echo "✅ cwallet.sso is readable" || echo "❌ cwallet.sso is NOT readable"
echo ""

echo "5️⃣ Checking file permissions..."
kubectl exec "$POD_NAME" -- ls -la /app/wallet/cwallet.sso 2>&1 || echo "❌ Cannot check permissions"
echo ""

echo "6️⃣ Checking sqlnet.ora content..."
kubectl exec "$POD_NAME" -- cat /app/wallet/sqlnet.ora 2>&1 | head -10 || echo "❌ Cannot read sqlnet.ora"
echo ""

echo "7️⃣ Checking tnsnames.ora content (first 5 lines)..."
kubectl exec "$POD_NAME" -- cat /app/wallet/tnsnames.ora 2>&1 | head -5 || echo "❌ Cannot read tnsnames.ora"
echo ""

echo "✅ Verification complete"

