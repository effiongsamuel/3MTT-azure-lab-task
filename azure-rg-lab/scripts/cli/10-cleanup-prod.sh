#!/usr/bin/env bash
# =============================================================================
# Script: 10-cleanup-prod.sh
# Purpose: Demonstrate lifecycle management — export backup, then delete
#          the Production Resource Group.
# Pre-req: Source 01-setup-variables.sh
# Usage:   bash ./scripts/cli/10-cleanup-prod.sh
# =============================================================================

set -euo pipefail

echo "============================================"
echo " LIFECYCLE MANAGEMENT — PROD RG TEARDOWN"
echo "============================================"

echo ""
echo "▶ Step 1: Impact analysis — listing resources that will be deleted"
az resource list \
  --resource-group "$RG_PROD" \
  --query "[].{Name:name, Type:type, Location:location}" \
  --output table

COUNT=$(az resource list --resource-group "$RG_PROD" --query "length(@)" --output tsv)
echo ""
echo "  Total resources to be deleted: $COUNT"

echo ""
echo "▶ Step 2: Exporting ARM template as configuration backup"
mkdir -p ../arm-templates
az group export \
  --name "$RG_PROD" \
  --output json > ../arm-templates/rg-3mmt-labs-prod-backup.json
echo "  Backup saved to: scripts/arm-templates/rg-3mmt-labs-prod-backup.json"

echo ""
echo "▶ Step 3: Deleting Resource Group: $RG_PROD"
read -r -p "  Type the resource group name to confirm deletion: " CONFIRM
if [[ "$CONFIRM" != "$RG_PROD" ]]; then
  echo "  ❌ Confirmation did not match. Aborting deletion."
  exit 1
fi

az group delete \
  --name "$RG_PROD" \
  --yes \
  --no-wait

echo ""
echo "  Deletion initiated. This will take several minutes to complete."
echo "  Monitor with: az group list --output table"

echo ""
echo "▶ Step 4: Confirming Dev RG is untouched"
az group show --name "$RG_DEV" --query "{Name:name, State:properties.provisioningState}" --output table

echo ""
echo "============================================"
echo " To recreate the Prod RG later, re-run:"
echo "   bash ./scripts/cli/02-create-resource-groups.sh"
echo "============================================"