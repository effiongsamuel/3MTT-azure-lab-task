#!/usr/bin/env bash
# =============================================================================
# Script: 11-workflow-prod.sh
# Purpose: Run the production-only lab workflow in order.
# Pre-req: Azure CLI installed and logged in.
# Usage:   bash ./scripts/cli/11-workflow-prod.sh [--include-cleanup]
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

INCLUDE_CLEANUP=false
for arg in "$@"; do
  case "$arg" in
    --include-cleanup)
      INCLUDE_CLEANUP=true
      ;;
  esac
done

echo "============================================================"
echo " AZURE RG LAB — PRODUCTION WORKFLOW"
echo "============================================================"

echo ""
echo "▶ Step 1/8: Load shared variables"
source "$PROJECT_ROOT/scripts/cli/01-setup-variables.sh"

echo ""
echo "▶ Step 2/8: Create Production network"
bash "$PROJECT_ROOT/scripts/cli/03-create-network-prod.sh"

echo ""
echo "▶ Step 3/8: Create Production SSH key"
bash "$PROJECT_ROOT/scripts/cli/04-create-ssh-prod.sh"

echo ""
echo "▶ Step 4/8: Create Production VM"
bash "$PROJECT_ROOT/scripts/cli/05-create-vm-prod.sh"

echo ""
echo "▶ Step 5/8: Create Production storage"
bash "$PROJECT_ROOT/scripts/cli/06-create-storage-prod.sh"

echo ""
echo "▶ Step 6/8: Create Production SQL database"
bash "$PROJECT_ROOT/scripts/cli/07-create-sql-prod.sh"

echo ""
echo "▶ Step 7/8: Configure Production RBAC"
bash "$PROJECT_ROOT/scripts/cli/08-configure-rbac-prod.sh"

echo ""
echo "▶ Step 8/8: Verify Production resources"
bash "$PROJECT_ROOT/scripts/cli/09-verify-all-prod.sh"

if [[ "$INCLUDE_CLEANUP" == true ]]; then
  echo ""
  echo "▶ Optional Production cleanup requested"
  bash "$PROJECT_ROOT/scripts/cli/10-cleanup-prod.sh"
else
  echo ""
  echo "Skipping cleanup. Use --include-cleanup only when you are ready to delete production resources."
fi

echo ""
echo "✅ Production workflow complete."