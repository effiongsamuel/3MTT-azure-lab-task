#!/usr/bin/env bash
# =============================================================================
# Script: 03-create-network-prod.sh
# Purpose: Create Production VNet, Subnet, NSG, and SSH allow rule.
# Pre-req: Source 01-setup-variables.sh first; RG_PROD must exist.
# Usage:   bash ./scripts/cli/03-create-network-prod.sh
# =============================================================================

set -euo pipefail

echo "▶ Creating Production Virtual Network..."
az network vnet create \
  --resource-group "$RG_PROD" \
  --name "$VNET_PROD_NAME" \
  --location "$LOCATION" \
  --address-prefix "10.1.0.0/16" \
  --subnet-name "$SUBNET_PROD_NAME" \
  --subnet-prefix "10.1.1.0/24" \
  --tags \
    environment=prod \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT" \
  --output table

echo ""
echo "▶ Creating Production Network Security Group..."
az network nsg create \
  --resource-group "$RG_PROD" \
  --name "$NSG_PROD_NAME" \
  --location "$LOCATION" \
  --tags \
    environment=prod \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT" \
  --output table

echo ""
echo "▶ Adding SSH inbound allow rule to Production NSG..."
echo "  Your IP: $MY_IP"

az network nsg rule create \
  --resource-group "$RG_PROD" \
  --nsg-name "$NSG_PROD_NAME" \
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
echo "▶ Associating Production NSG with subnet..."
az network vnet subnet update \
  --resource-group "$RG_PROD" \
  --vnet-name "$VNET_PROD_NAME" \
  --name "$SUBNET_PROD_NAME" \
  --network-security-group "$NSG_PROD_NAME" \
  --output table

echo ""
echo "✅ Production network setup complete."
az network vnet show \
  --resource-group "$RG_PROD" \
  --name "$VNET_PROD_NAME" \
  --query "{VNet:name, AddressSpace:addressSpace.addressPrefixes, Location:location}" \
  --output table
