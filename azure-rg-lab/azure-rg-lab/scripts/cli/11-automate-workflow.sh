#!/usr/bin/env bash
# =============================================================================
# Script: 11-automate-workflow.sh
# Purpose: Run the lab scripts in order from setup through verification.
# Pre-req: Azure CLI installed and logged in.
# Usage:   bash ./scripts/cli/11-automate-workflow.sh [--include-dev-cleanup] [--include-prod-cleanup]
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

INCLUDE_DEV_CLEANUP=false
INCLUDE_PROD_CLEANUP=false

for arg in "$@"; do
  case "$arg" in
    --include-dev-cleanup)
      INCLUDE_DEV_CLEANUP=true
      ;;
    --include-prod-cleanup)
      INCLUDE_PROD_CLEANUP=true
      ;;
  esac
done

echo "============================================================"
echo " AZURE RG LAB — AUTOMATED WORKFLOW"
echo "============================================================"

echo ""
echo "▶ Step 1/17: Load shared variables"
source "$PROJECT_ROOT/scripts/cli/01-setup-variables.sh"

echo ""
echo "▶ Step 2/17: Create resource groups"
bash "$PROJECT_ROOT/scripts/cli/02-create-resource-groups.sh"

echo ""
echo "▶ Step 3/17: Create Dev network"
bash "$PROJECT_ROOT/scripts/cli/03-create-network.sh"

echo ""
echo "▶ Step 4/17: Create Dev SSH key"
bash "$PROJECT_ROOT/scripts/cli/04-create-ssh.sh"

echo ""
echo "▶ Step 5/17: Create Dev VM"
bash "$PROJECT_ROOT/scripts/cli/05-create-vm.sh"

echo ""
echo "▶ Step 6/17: Create Dev storage"
bash "$PROJECT_ROOT/scripts/cli/06-create-storage.sh"

echo ""
# echo "▶ Step 7/17: Create Dev SQL database"
# bash "$PROJECT_ROOT/scripts/cli/07-create-sql.sh"

echo ""
echo "▶ Step 8/17: Configure Dev RBAC"
bash "$PROJECT_ROOT/scripts/cli/08-configure-rbac.sh"

echo ""
echo "▶ Step 9/17: Verify Dev resources"
bash "$PROJECT_ROOT/scripts/cli/09-verify-all.sh"

echo ""
echo "▶ Step 10/17: Create Prod network"
bash "$PROJECT_ROOT/scripts/cli/03-create-network-prod.sh"

echo ""
echo "▶ Step 11/17: Create Prod SSH key"
bash "$PROJECT_ROOT/scripts/cli/04-create-ssh-prod.sh"

echo ""
echo "▶ Step 12/17: Create Prod VM"
bash "$PROJECT_ROOT/scripts/cli/05-create-vm-prod.sh"

echo ""
echo "▶ Step 13/17: Create Prod storage"
bash "$PROJECT_ROOT/scripts/cli/06-create-storage-prod.sh"

echo ""
# echo "▶ Step 14/17: Create Prod SQL database"
# bash "$PROJECT_ROOT/scripts/cli/07-create-sql-prod.sh"

echo ""
echo "▶ Step 15/17: Configure Prod RBAC"
bash "$PROJECT_ROOT/scripts/cli/08-configure-rbac-prod.sh"

echo ""
echo "▶ Step 16/17: Verify Prod resources"
bash "$PROJECT_ROOT/scripts/cli/09-verify-all-prod.sh"

if [[ "$INCLUDE_DEV_CLEANUP" == true ]]; then
  echo ""
  echo "▶ Optional Dev cleanup requested"
  bash "$PROJECT_ROOT/scripts/cli/10-cleanup.sh"
fi

if [[ "$INCLUDE_PROD_CLEANUP" == true ]]; then
  echo ""
  echo "▶ Optional Prod cleanup requested"
  bash "$PROJECT_ROOT/scripts/cli/10-cleanup-prod.sh"
else
  echo ""
  echo "Skipping cleanup. Use --include-dev-cleanup and/or --include-prod-cleanup only when you are ready to delete resources."
fi

echo ""
echo "▶ Step 17/17: Workflow complete"
echo "✅ Workflow complete."