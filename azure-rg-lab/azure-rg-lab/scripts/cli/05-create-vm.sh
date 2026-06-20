#!/usr/bin/env bash
# =============================================================================
# Script: 04-create-vm.sh
# Purpose: Create Public IP, NIC, and Ubuntu Linux VM.
# Pre-req: Source 01-setup-variables.sh; network must exist.
# Usage:   bash ./scripts/cli/04-create-vm.sh
# =============================================================================

set -euo pipefail

echo "▶ Creating Public IP Address..."
az network public-ip create \
  --resource-group "$RG_DEV" \
  --name "$PIP_NAME" \
  --location "$LOCATION" \
  --allocation-method Static \
  --sku Standard \
  --tags \
    environment=dev \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT" \
  --output table

echo ""
echo "▶ Creating Network Interface Card..."
az network nic create \
  --resource-group "$RG_DEV" \
  --name "$NIC_NAME" \
  --location "$LOCATION" \
  --vnet-name "$VNET_NAME" \
  --subnet "$SUBNET_NAME" \
  --public-ip-address "$PIP_NAME" \
  --network-security-group "$NSG_NAME" \
  --output table

echo ""
echo "▶ Creating Ubuntu Linux VM (this takes 2–4 minutes)..."
az vm create \
  --resource-group "$RG_DEV" \
  --name "$VM_NAME" \
  --location "$LOCATION" \
  --size "$VM_SIZE" \
  --image "$VM_IMAGE" \
  --admin-username "$ADMIN_USER" \
  --generate-ssh-keys \
  --nics "$NIC_NAME" \
  --os-disk-name "osdisk-${VM_NAME}" \
  --storage-sku StandardSSD_LRS \
  --tags \
    environment=dev \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT" \
  --output table

echo ""
echo "▶ Getting VM public IP..."
VM_PUBLIC_IP=$(az vm show \
  --resource-group "$RG_DEV" \
  --name "$VM_NAME" \
  --show-details \
  --query publicIps \
  --output tsv)

echo ""
echo "✅ VM created successfully."
echo "   VM Name:   $VM_NAME"
echo "   Public IP: $VM_PUBLIC_IP"
echo ""
echo "▶ Testing SSH connection..."
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
  "${ADMIN_USER}@${VM_PUBLIC_IP}" \
  "echo '✅ SSH connection successful!' && hostname && uname -r"
