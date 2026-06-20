#!/usr/bin/env bash
# =============================================================================
# Script: 02-create-resource-groups.sh
# Purpose: Create Development and Production Resource Groups with tags.
# Pre-req: Source 01-setup-variables.sh first
# Usage:   bash ./scripts/cli/02-create-resource-groups.sh
# =============================================================================

set -euo pipefail

echo "▶ Creating Resource Groups..."

# ── Development Resource Group ─────────────────────────────────────────────
echo "  Creating: $RG_DEV"
az group create \
  --name "$RG_DEV" \
  --location "$LOCATION" \
  --tags \
    environment=dev \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT" \
  --output table

# ── Production Resource Group ──────────────────────────────────────────────
echo "  Creating: $RG_PROD"
az group create \
  --name "$RG_PROD" \
  --location "$LOCATION" \
  --tags \
    environment=prod \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT" \
  --output table

# ── Verify ────────────────────────────────────────────────────────────────
echo ""
echo "✅ Resource Groups created:"
az group list \
  --query "[?contains(name, '${COMPANY}')].{Name:name, Location:location, State:properties.provisioningState}" \
  --output table
