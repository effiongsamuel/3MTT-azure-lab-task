#!/usr/bin/env bash
# =============================================================================
# Script: 03-create-network.sh
# Purpose: Create VNet, Subnet, NSG, and SSH allow rule.
# Pre-req: Source 01-setup-variables.sh first; RG_DEV must exist.
# Usage:   bash ./scripts/cli/03-create-network.sh
# =============================================================================

set -euo pipefail

echo "▶ Creating Virtual Network..."
az network vnet create \
  --resource-group "$RG_DEV" \
  --name "$VNET_NAME" \
  --location "$LOCATION" \
  --address-prefix "10.0.0.0/16" \
  --subnet-name "$SUBNET_NAME" \
  --subnet-prefix "10.0.1.0/24" \
  --tags \
    environment=dev \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT" \
  --output table

echo ""
echo "▶ Creating Network Security Group..."
az network nsg create \
  --resource-group "$RG_DEV" \
  --name "$NSG_NAME" \
  --location "$LOCATION" \
  --tags \
    environment=dev \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT" \
  --output table

echo ""
echo "▶ Adding SSH inbound allow rule to NSG..."
echo "  Your IP: $MY_IP"

az network nsg rule create \
  --resource-group "$RG_DEV" \
  --nsg-name "$NSG_NAME" \
  --name "Allow-SSH-Inbound" \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefix "$MY_IP" \
  --source-port-range "*" \
  --destination-address-prefix "*" \
  --destination-port-range 22 \
  --output table

echo ""
echo "▶ Associating NSG with subnet..."
az network vnet subnet update \
  --resource-group "$RG_DEV" \
  --vnet-name "$VNET_NAME" \
  --name "$SUBNET_NAME" \
  --network-security-group "$NSG_NAME" \
  --output table

echo ""
echo "✅ Network setup complete."
az network vnet show \
  --resource-group "$RG_DEV" \
  --name "$VNET_NAME" \
  --query "{VNet:name, AddressSpace:addressSpace.addressPrefixes, Location:location}" \
  --output table
