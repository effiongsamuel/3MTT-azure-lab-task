#!/usr/bin/env bash
# =============================================================================
# Script: 06-create-storage-prod.sh
# Purpose: Create a Production Storage Account with a Blob container.
# Pre-req: Source 01-setup-variables.sh; RG_PROD must exist.
# Usage:   bash ./scripts/cli/06-create-storage-prod.sh
# =============================================================================

set -euo pipefail

echo "▶ Creating Production Storage Account: $STORAGE_PROD_ACCOUNT"
echo "  Note: Name must be globally unique. If this fails, add a random suffix."

az storage account create \
  --resource-group "$RG_PROD" \
  --name "$STORAGE_PROD_ACCOUNT" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --tags \
    environment=prod \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT" \
  --output table

echo ""
echo "▶ Creating Blob container inside the Production storage account..."
az storage container create \
  --account-name "$STORAGE_PROD_ACCOUNT" \
  --name "prod-container" \
  --public-access off \
  --auth-mode login \
  --output table

echo ""
echo "✅ Production Storage Account ready."
az storage account show \
  --resource-group "$RG_PROD" \
  --name "$STORAGE_PROD_ACCOUNT" \
  --query "{Name:name, SKU:sku.name, Kind:kind, TLS:minimumTlsVersion, Location:location}" \
  --output table