#!/usr/bin/env bash
# =============================================================================
# Script: 08-configure-rbac-prod.sh
# Purpose: Assign Owner, Contributor, and Reader RBAC roles on Production.
# Pre-req: Source 01-setup-variables.sh; both RGs must exist.
# Usage:   bash ./scripts/cli/08-configure-rbac-prod.sh
# =============================================================================

set -euo pipefail

MY_USER_ID=$(az ad signed-in-user show --query id --output tsv)
RG_PROD_ID=$(az group show --name "$RG_PROD" --query id --output tsv)

echo "▶ Configuring Production RBAC assignments..."
echo "  User Object ID: $MY_USER_ID"
echo "  Prod RG scope:  $RG_PROD_ID"
echo ""

echo "  Assigning Owner on $RG_PROD..."
az role assignment create \
  --role "Owner" \
  --assignee "$MY_USER_ID" \
  --scope "$RG_PROD_ID" \
  --description "Lab admin: full control including RBAC management" \
  --output table 2>/dev/null || echo "  (Owner assignment already exists or inherited)"

echo "  Assigning Contributor on $RG_PROD..."
az role assignment create \
  --role "Contributor" \
  --assignee "$MY_USER_ID" \
  --scope "$RG_PROD_ID" \
  --description "Developer access: deploy resources but cannot manage RBAC" \
  --output table 2>/dev/null || echo "  (Contributor assignment already exists)"

echo "  Assigning Reader on $RG_PROD..."
az role assignment create \
  --role "Reader" \
  --assignee "$MY_USER_ID" \
  --scope "$RG_PROD_ID" \
  --description "Audit/read-only: can view but cannot change production" \
  --output table 2>/dev/null || echo "  (Reader assignment already exists)"

echo ""
echo "✅ Production RBAC assignments configured."
echo ""
echo "  ── Prod RG Role Assignments ─────────────────────────────"
az role assignment list \
  --scope "$RG_PROD_ID" \
  --query "[].{Role:roleDefinitionName, Principal:principalName}" \
  --output table