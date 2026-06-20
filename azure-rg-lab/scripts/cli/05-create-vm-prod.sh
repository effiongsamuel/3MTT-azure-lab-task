#!/usr/bin/env bash
# =============================================================================
# Script: 05-create-vm-prod.sh
# Purpose: Create Production Public IP, NIC, and Ubuntu Linux VM.
# Pre-req: Source 01-setup-variables.sh; run 03-create-network-prod.sh; network must exist.
# Usage:   bash ./scripts/cli/05-create-vm-prod.sh
# =============================================================================

set -euo pipefail

if [[ ! -f "$SSH_PUBLIC_KEY_FILE" ]]; then
  echo "❌ SSH public key not found: $SSH_PUBLIC_KEY_FILE"
  echo "   Run ./scripts/cli/04-create-ssh-prod.sh first."
  exit 1
fi

echo "▶ Creating Production Public IP Address..."
az network public-ip create \
  --resource-group "$RG_PROD" \
  --name "$PIP_PROD_NAME" \
  --location "$LOCATION" \
  --allocation-method Static \
  --sku Standard \
  --tags \
    environment=prod \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT" \
  --output table

echo ""
echo "▶ Creating Production Network Interface Card..."
az network nic create \
  --resource-group "$RG_PROD" \
  --name "$NIC_PROD_NAME" \
  --location "$LOCATION" \
  --vnet-name "$VNET_PROD_NAME" \
  --subnet "$SUBNET_PROD_NAME" \
  --public-ip-address "$PIP_PROD_NAME" \
  --network-security-group "$NSG_PROD_NAME" \
  --output table

echo ""
echo "▶ Creating Production Ubuntu Linux VM (this takes 2–4 minutes)..."
az vm create \
  --resource-group "$RG_PROD" \
  --name "$VM_PROD_NAME" \
  --location "$LOCATION" \
  --size "$VM_SIZE" \
  --image "$VM_IMAGE" \
  --admin-username "$ADMIN_USER" \
  --ssh-key-name "$SSH_PROD_KEY_NAME" \
  --nics "$NIC_PROD_NAME" \
  --os-disk-size-gb 30 \
  --os-disk-name "osdisk-${VM_PROD_NAME}" \
  --storage-sku StandardSSD_LRS \
  --tags \
    environment=prod \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT" \
  --output table

echo ""
echo "▶ Getting Production VM public IP..."
VM_PUBLIC_IP=$(az vm show \
  --resource-group "$RG_PROD" \
  --name "$VM_PROD_NAME" \
  --show-details \
  --query publicIps \
  --output tsv)

echo ""
echo "✅ Production VM created successfully."
echo "   VM Name:   $VM_PROD_NAME"
echo "   Public IP: $VM_PUBLIC_IP"
echo ""
# echo "▶ Testing SSH connection..."
# ssh -i "$SSH_PRIVATE_KEY_FILE" -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 \
#   "${ADMIN_USER}@${VM_PUBLIC_IP}" \
#   "echo '✅ SSH connection successful!' && hostname && uname -r"