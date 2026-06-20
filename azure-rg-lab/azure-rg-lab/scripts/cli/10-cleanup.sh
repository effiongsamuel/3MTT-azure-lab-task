#!/usr/bin/env bash
# =============================================================================
# Script: 09-cleanup.sh
# Purpose: Demonstrate lifecycle management — export backup, then delete
#          the Development Resource Group. Production is left untouched.
# Pre-req: Source 01-setup-variables.sh
# Usage:   bash ./scripts/cli/09-cleanup.sh
# =============================================================================

set -euo pipefail

echo "============================================"
echo " LIFECYCLE MANAGEMENT — DEV RG TEARDOWN"
echo "============================================"

# ── Impact Analysis ──────────────────────────────────────────────────────
echo ""
echo "▶ Step 1: Impact analysis — listing resources that will be deleted"
az resource list \
  --resource-group "$RG_DEV" \
  --query "[].{Name:name, Type:type, Location:location}" \
  --output table

COUNT=$(az resource list --resource-group "$RG_DEV" --query "length(@)" --output tsv)
echo ""
echo "  Total resources to be deleted: $COUNT"

# ── Backup: Export ARM Template ─────────────────────────────────────────
echo ""
echo "▶ Step 2: Exporting ARM template as configuration backup"
mkdir -p ../arm-templates
az group export \
  --name "$RG_DEV" \
  --output json > ../arm-templates/rg-3mmt-labs-dev-backup.json
echo "  Backup saved to: scripts/arm-templates/rg-3mmt-labs-dev-backup.json"

# ── Confirm and Delete ──────────────────────────────────────────────────
echo ""
echo "▶ Step 3: Deleting Resource Group: $RG_DEV"
read -r -p "  Type the resource group name to confirm deletion: " CONFIRM
if [[ "$CONFIRM" != "$RG_DEV" ]]; then
  echo "  ❌ Confirmation did not match. Aborting deletion."
  exit 1
fi

az group delete \
  --name "$RG_DEV" \
  --yes \
  --no-wait

echo ""
echo "  Deletion initiated. This will take several minutes to complete."
echo "  Monitor with: az group list --output table"

# ── Verify Prod Untouched ────────────────────────────────────────────────
# echo ""
# echo "▶ Step 4: Confirming Production RG is untouched"
# az group show --name "$RG_PROD" --query "{Name:name, State:properties.provisioningState}" --output table

# echo ""
# echo "============================================"
# echo " To recreate the Dev RG later, re-run:"
# echo "   bash ./scripts/cli/02-create-resource-groups.sh"
# echo "============================================"
