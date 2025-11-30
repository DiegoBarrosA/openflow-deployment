#!/bin/bash
# Test what value is actually in the secret
TEST_VAL="$1"
if [ ${#TEST_VAL} -eq 1 ]; then
  CHAR_HEX=$(echo -n "$TEST_VAL" | od -An -tx1 | tr -d ' \n')
  CHAR_ASCII=$(printf "%d" "'$TEST_VAL")
  echo "Character hex: 0x$CHAR_HEX"
  echo "Character ASCII: $CHAR_ASCII"
  echo "Character visible: '$(echo -n "$TEST_VAL" | cat -A)'"
fi
