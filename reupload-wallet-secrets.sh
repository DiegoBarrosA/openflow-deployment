#!/bin/bash

# Quick script to re-upload wallet secrets
# Use this if secrets were uploaded incorrectly

set -e

echo "🔄 Re-uploading Wallet Secrets to GitHub"
echo "========================================"
echo ""
echo "This will overwrite existing wallet secrets."
echo ""

read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Running upload script..."
echo ""

./upload-wallet-to-github.sh

echo ""
echo "✅ Re-upload complete!"
echo ""
echo "Next steps:"
echo "1. Wait a few seconds for GitHub to process"
echo "2. Re-run the deployment workflow"
echo "3. The workflow should now successfully decode the wallet files"










