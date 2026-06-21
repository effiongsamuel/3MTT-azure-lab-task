#!/usr/bin/env bash
# =============================================================================
# Script: 07-configure-rbac.sh
# Purpose: Assign Owner, Contributor, and Reader RBAC roles.
# Pre-req: Source 01-setup-variables.sh; both RGs must exist.
# Usage:   bash ./scripts/cli/07-configure-rbac.sh
# =============================================================================

set -euo pipefail

# Get the signed-in user's Object ID
MY_USER_ID=$(az ad signed-in-user show --query id --output tsv)
RG_DEV_ID=$(az group show --name "$RG_DEV" --query id --output tsv)
RG_PROD_ID=$(az group show --name "$RG_PROD" --query id --output tsv)

echo "▶ Configuring RBAC assignments..."
echo "  User Object ID: $MY_USER_ID"
echo "  Dev RG scope:   $RG_DEV_ID"
echo "  Prod RG scope:  $RG_PROD_ID"
echo ""

# ── Assignment 1: Owner on Dev RG ──────────────────────────────────────────
echo "  Assigning Owner on $RG_DEV..."
az role assignment create \
  --role "Owner" \
  --assignee "$MY_USER_ID" \
  --scope "$RG_DEV_ID" \
  --description "Lab admin: full control including RBAC management" \
  --output table 2>/dev/null || echo "  (Owner assignment already exists or inherited)"

# ── Assignment 2: Contributor on Dev RG ────────────────────────────────────
echo "  Assigning Contributor on $RG_DEV..."
# Note: In a real scenario replace $MY_USER_ID with a developer's user ID.
az role assignment create \
  --role "Contributor" \
  --assignee "$MY_USER_ID" \
  --scope "$RG_DEV_ID" \
  --description "Developer access: deploy resources but cannot manage RBAC" \
  --output table 2>/dev/null || echo "  (Contributor assignment already exists)"

# ── Assignment 3: Reader on Prod RG ────────────────────────────────────────
echo "  Assigning Reader on $RG_PROD..."
az role assignment create \
  --role "Reader" \
  --assignee "$MY_USER_ID" \
  --scope "$RG_PROD_ID" \
  --description "Audit/read-only: can view but cannot change production" \
  --output table 2>/dev/null || echo "  (Reader assignment already exists)"

echo ""
echo "✅ RBAC assignments configured."
echo ""
echo "  ── Dev RG Role Assignments ──────────────────────────────"
az role assignment list \
  --scope "$RG_DEV_ID" \
  --query "[].{Role:roleDefinitionName, Principal:principalName}" \
  --output table

echo ""
echo "  ── Prod RG Role Assignments ─────────────────────────────"
az role assignment list \
  --scope "$RG_PROD_ID" \
  --query "[].{Role:roleDefinitionName, Principal:principalName}" \
  --output table
