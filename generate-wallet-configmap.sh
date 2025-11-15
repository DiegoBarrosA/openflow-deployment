#!/bin/bash

# Generate Oracle Wallet ConfigMap from wallet directory
# Usage: ./generate-wallet-configmap.sh /path/to/wallet/dir

set -e

if [ $# -eq 0 ]; then
    WALLET_DIR="./wallet"
else
    WALLET_DIR="$1"
fi

if [ ! -d "$WALLET_DIR" ]; then
    echo "❌ Wallet directory not found: $WALLET_DIR"
    echo ""
    echo "Please ensure wallet files are extracted to $WALLET_DIR"
    echo "Download wallet from Oracle Cloud Console and run:"
    echo "  unzip Wallet_openflow.zip -d wallet/"
    exit 1
fi

echo "🔐 Generating Oracle Wallet ConfigMap..."
echo "📁 Wallet directory: $WALLET_DIR"
echo ""

# Generate ConfigMap YAML
cat > oracle-wallet-configmap.yaml << EOF
# Oracle Wallet ConfigMap
# Generated from $WALLET_DIR on $(date)
apiVersion: v1
kind: ConfigMap
metadata:
  name: oracle-wallet-config
  namespace: default
data:
EOF

# Add each wallet file
for file in cwallet.sso ewallet.p12 keystore.jks ojdbc.properties sqlnet.ora tnsnames.ora truststore.jks; do
    if [ -f "$WALLET_DIR/$file" ]; then
        content=$(cat "$WALLET_DIR/$file" | base64 -w 0)
        echo "  $file: $content" >> oracle-wallet-configmap.yaml
        echo "✅ Added $file"
    else
        echo "⚠️  Skipping $file (not found)"
    fi
done

echo ""
echo "✅ ConfigMap generated: oracle-wallet-configmap.yaml"
echo ""
echo "🚀 Deploy with:"
echo "  kubectl apply -f oracle-wallet-configmap.yaml"