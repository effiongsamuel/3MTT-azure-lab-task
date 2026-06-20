#!/usr/bin/env bash
# =============================================================================
# Script: 04-create-ssh-prod.sh
# Purpose: Create or register the SSH key pair used by the Production VM.
# Pre-req: Source 01-setup-variables.sh first; RG_PROD must exist.
# Usage:   bash ./scripts/cli/04-create-ssh-prod.sh
# =============================================================================

set -euo pipefail

if [[ -f "$SSH_PRIVATE_KEY_FILE" && -f "$SSH_PUBLIC_KEY_FILE" ]]; then
  echo "▶ Reusing existing SSH key pair: $SSH_PUBLIC_KEY_FILE"
elif [[ ! -f "$SSH_PRIVATE_KEY_FILE" && ! -f "$SSH_PUBLIC_KEY_FILE" ]]; then
  echo "▶ No SSH key pair found. Creating one locally..."
  ssh-keygen -t ed25519 -f "$SSH_PRIVATE_KEY_FILE" -N "" -C "$OWNER"
else
  echo "❌ SSH key files are incomplete. Expected both:"
  echo "   Private: $SSH_PRIVATE_KEY_FILE"
  echo "   Public:  $SSH_PUBLIC_KEY_FILE"
  echo "   Fix the pair first, then run this script again."
  exit 1
fi

echo ""
echo "▶ Registering the public key in Azure..."
az sshkey create \
  --name "$SSH_PROD_KEY_NAME" \
  --resource-group "$RG_PROD" \
  --location "$LOCATION" \
  --public-key @"$SSH_PUBLIC_KEY_FILE" \
  --tags \
    environment=prod \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT" \
  --output table

echo ""
echo "✅ Production SSH key ready."
echo "   Azure SSH key name: $SSH_PROD_KEY_NAME"
echo "   Private key file:   $SSH_PRIVATE_KEY_FILE"
echo "   Public key file:    $SSH_PUBLIC_KEY_FILE"