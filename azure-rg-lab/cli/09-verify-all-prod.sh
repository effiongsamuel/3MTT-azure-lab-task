#!/usr/bin/env bash
# =============================================================================
# Script: 09-verify-all-prod.sh
# Purpose: Run verification checks against the Production lab environment.
# Pre-req: Source 01-setup-variables.sh; all prior production scripts should have run.
# Usage:   bash ./scripts/cli/09-verify-all-prod.sh
# =============================================================================

set -euo pipefail

RG_PROD_ID=$(az group show --name "$RG_PROD" --query id --output tsv)

echo "============================================"
echo " AZURE LAB PRODUCTION VERIFICATION CHECKS"
echo "============================================"

echo ""
echo "✅ CHECK 1: Resource Groups"
az group list \
  --query "[?contains(name, '${COMPANY}')].{Name:name, Location:location, State:properties.provisioningState}" \
  --output table

echo ""
echo "✅ CHECK 2: VM Power State"
az vm get-instance-view \
  --resource-group "$RG_PROD" \
  --name "$VM_PROD_NAME" \
  --query "instanceView.statuses[1].{Status:displayStatus}" \
  --output table

echo ""
echo "✅ CHECK 3: Virtual Network"
az network vnet show \
  --resource-group "$RG_PROD" \
  --name "$VNET_PROD_NAME" \
  --query "{Name:name, AddressSpace:addressSpace.addressPrefixes, Location:location}" \
  --output table

echo ""
echo "✅ CHECK 4: NSG Rules"
az network nsg rule list \
  --resource-group "$RG_PROD" \
  --nsg-name "$NSG_PROD_NAME" \
  --output table

echo ""
echo "✅ CHECK 5: Storage Account"
az storage account show \
  --resource-group "$RG_PROD" \
  --name "$STORAGE_PROD_ACCOUNT" \
  --query "{Name:name, Sku:sku.name, Kind:kind, TLS:minimumTlsVersion}" \
  --output table

echo ""
echo "✅ CHECK 6: SQL Database"
# az sql db show \
#   --resource-group "$RG_PROD" \
#   --server "$SQL_PROD_SERVER" \
#   --name "$SQL_PROD_DB" \
#   --query "{Name:name, Edition:edition, ComputeModel:computeModel, Status:status}" \
#   --output table

echo ""
echo "✅ CHECK 7: VM Tags"
az vm show \
  --resource-group "$RG_PROD" \
  --name "$VM_PROD_NAME" \
  --query tags \
  --output table

echo ""
echo "✅ CHECK 8: RBAC Assignments (Prod RG)"
az role assignment list \
  --scope "$RG_PROD_ID" \
  --query "[].{Role:roleDefinitionName, Principal:principalName, Scope:scope}" \
  --output table

echo ""
echo "✅ CHECK 9: All Resources in Prod RG"
az resource list \
  --resource-group "$RG_PROD" \
  --query "[].{Name:name, Type:type}" \
  --output table

echo ""
echo "============================================"
echo " ALL PRODUCTION CHECKS COMPLETE"
echo "============================================"