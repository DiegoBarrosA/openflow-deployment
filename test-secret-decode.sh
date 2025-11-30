#!/bin/bash

# Test script to verify secret encoding/decoding works
# This simulates what the workflow does

set -e

echo "🧪 Testing Secret Encoding/Decoding"
echo "===================================="
echo ""

# Test with a known value
TEST_VALUE="Hello, this is a test for base64 encoding and decoding"
echo "Original: $TEST_VALUE"
echo ""

# Encode
ENCODED=$(echo -n "$TEST_VALUE" | base64 -w 0 2>/dev/null || echo -n "$TEST_VALUE" | base64 | tr -d '\n')
echo "Encoded (first 50 chars): ${ENCODED:0:50}..."
echo ""

# Decode
DECODED=$(echo -n "$ENCODED" | base64 -d 2>/dev/null)
echo "Decoded: $DECODED"
echo ""

if [ "$DECODED" = "$TEST_VALUE" ]; then
    echo "✅ Base64 encoding/decoding works correctly"
else
    echo "❌ Base64 encoding/decoding failed"
    exit 1
fi

echo ""
echo "Testing with actual wallet file..."
echo ""

if [ -f "wallet/cwallet.sso" ]; then
    # Encode wallet file
    WALLET_ENCODED=$(base64 -w 0 wallet/cwallet.sso 2>/dev/null || base64 wallet/cwallet.sso | tr -d '\n')
    
    if [ -z "$WALLET_ENCODED" ]; then
        echo "❌ Failed to encode wallet file"
        exit 1
    fi
    
    echo "✅ Wallet file encoded (${#WALLET_ENCODED} characters)"
    
    # Decode wallet file
    echo -n "$WALLET_ENCODED" | base64 -d > /tmp/test_wallet_decoded.sso 2>/dev/null
    
    if [ $? -eq 0 ] && [ -s /tmp/test_wallet_decoded.sso ]; then
        ORIGINAL_SIZE=$(wc -c < wallet/cwallet.sso)
        DECODED_SIZE=$(wc -c < /tmp/test_wallet_decoded.sso)
        
        if [ "$ORIGINAL_SIZE" -eq "$DECODED_SIZE" ]; then
            echo "✅ Wallet file decoded correctly ($ORIGINAL_SIZE bytes)"
            rm -f /tmp/test_wallet_decoded.sso
        else
            echo "❌ Decoded file size mismatch: original=$ORIGINAL_SIZE, decoded=$DECODED_SIZE"
            exit 1
        fi
    else
        echo "❌ Failed to decode wallet file"
        exit 1
    fi
else
    echo "⚠️  wallet/cwallet.sso not found, skipping wallet test"
fi

echo ""
echo "✅ All tests passed!"
echo ""
echo "The encoding/decoding process works correctly."
echo "If GitHub secrets are failing, they may have been uploaded incorrectly."
echo "Re-upload using: ./upload-wallet-to-github.sh"



