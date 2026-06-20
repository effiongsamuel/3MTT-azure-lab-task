#!/usr/bin/env bash
# =============================================================================
# Script: 08-verify-all.sh
# Purpose: Run all verification checks against the deployed lab environment.
# Pre-req: Source 01-setup-variables.sh; all prior scripts should have run.
# Usage:   bash ./scripts/cli/08-verify-all.sh
# =============================================================================

set -euo pipefail

RG_DEV_ID=$(az group show --name "$RG_DEV" --query id --output tsv)

echo "============================================"
echo " AZURE LAB VERIFICATION CHECKS"
echo "============================================"

# ── CHECK 1: Resource Groups exist ─────────────────────────────────────────
echo ""
echo "✅ CHECK 1: Resource Groups"
az group list \
  --query "[?contains(name, '${COMPANY}')].{Name:name, Location:location, State:properties.provisioningState}" \
  --output table

# ── CHECK 2: VM is Running ──────────────────────────────────────────────────
echo ""
echo "✅ CHECK 2: VM Power State"
az vm get-instance-view \
  --resource-group "$RG_DEV" \
  --name "$VM_NAME" \
  --query "instanceView.statuses[1].{Status:displayStatus}" \
  --output table

# ── CHECK 3: VNet and Subnet exist ─────────────────────────────────────────
echo ""
echo "✅ CHECK 3: Virtual Network"
az network vnet show \
  --resource-group "$RG_DEV" \
  --name "$VNET_NAME" \
  --query "{Name:name, AddressSpace:addressSpace.addressPrefixes, Location:location}" \
  --output table

# ── CHECK 4: NSG Rules ──────────────────────────────────────────────────────
echo ""
echo "✅ CHECK 4: NSG Rules"
az network nsg rule list \
  --resource-group "$RG_DEV" \
  --nsg-name "$NSG_NAME" \
  --output table

# ── CHECK 5: Storage Account exists ─────────────────────────────────────────
echo ""
echo "✅ CHECK 5: Storage Account"
az storage account show \
  --resource-group "$RG_DEV" \
  --name "$STORAGE_ACCOUNT" \
  --query "{Name:name, Sku:sku.name, Kind:kind, TLS:minimumTlsVersion}" \
  --output table

# ── CHECK 6: SQL Database exists and tier is Serverless ─────────────────────
# echo ""
# echo "✅ CHECK 6: SQL Database"
# az sql db show \
#   --resource-group "$RG_DEV" \
#   --server "$SQL_SERVER" \
#   --name "$SQL_DB" \
#   --query "{Name:name, Edition:edition, ComputeModel:computeModel, Status:status}" \
#   --output table

# ── CHECK 7: Tags on VM ─────────────────────────────────────────────────────
echo ""
echo "✅ CHECK 7: VM Tags"
az vm show \
  --resource-group "$RG_DEV" \
  --name "$VM_NAME" \
  --query tags \
  --output table

# ── CHECK 8: RBAC Assignments on Dev RG ────────────────────────────────────
echo ""
echo "✅ CHECK 8: RBAC Assignments (Dev RG)"
az role assignment list \
  --scope "$RG_DEV_ID" \
  --query "[].{Role:roleDefinitionName, Principal:principalName, Scope:scope}" \
  --output table

# ── CHECK 9: All resources in Dev RG ────────────────────────────────────────
echo ""
echo "✅ CHECK 9: All Resources in Dev RG"
az resource list \
  --resource-group "$RG_DEV" \
  --query "[].{Name:name, Type:type}" \
  --output table

echo ""
echo "============================================"
echo " ALL CHECKS COMPLETE"
echo "============================================"
