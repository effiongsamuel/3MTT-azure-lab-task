#!/usr/bin/env bash
# =============================================================================
# Script: 05-create-storage.sh
# Purpose: Create a Storage Account with a Blob container.
# Pre-req: Source 01-setup-variables.sh; RG_DEV must exist.
# Usage:   bash ./scripts/cli/05-create-storage.sh
# =============================================================================

set -euo pipefail

echo "▶ Creating Storage Account: $STORAGE_ACCOUNT"
echo "  Note: Name must be globally unique. If this fails, add a random suffix."

az storage account create \
  --resource-group "$RG_DEV" \
  --name "$STORAGE_ACCOUNT" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --tags \
    environment=dev \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT" \
  --output table

echo ""
echo "▶ Creating Blob container inside the storage account..."
az storage container create \
  --account-name "$STORAGE_ACCOUNT" \
  --name "dev-container" \
  --public-access off \
  --auth-mode login \
  --output table

echo ""
echo "✅ Storage Account ready."
az storage account show \
  --resource-group "$RG_DEV" \
  --name "$STORAGE_ACCOUNT" \
  --query "{Name:name, SKU:sku.name, Kind:kind, TLS:minimumTlsVersion, Location:location}" \
  --output table
