#!/usr/bin/env bash
# =============================================================================
# Script: 01-setup-variables.sh
# Purpose: Export all shell variables used by subsequent scripts.
#          Source this file — do NOT execute it directly.
# Usage:   source ./scripts/cli/01-setup-variables.sh
# =============================================================================

set -euo pipefail   # Exit on error, undefined var, or pipe failure

# ── Company / Project ──────────────────────────────────────────────────────
export COMPANY="3mmt-labs"
export COMPANY_ID="${COMPANY//-/}"
export PROJECT="azure-rg-lab"
export COSTCENTER="CC-1001"
export DEPARTMENT="IT-Engineering"
export OWNER="${OWNER:-samuel.m1804892@st.futminna.edu.ng}" # Override via env or change here

# ── Region ─────────────────────────────────────────────────────────────────
export LOCATION="eastus"

# ── Resource Group Names ───────────────────────────────────────────────────
export RG_DEV="rg-${COMPANY}-dev"
export RG_PROD="rg-${COMPANY}-prod"

# ── Network Resources ──────────────────────────────────────────────────────
export VNET_NAME="vnet-${COMPANY}-dev-001"
export VNET_PROD_NAME="vnet-${COMPANY}-prod-001"
export SUBNET_NAME="snet-dev-001"
export SUBNET_PROD_NAME="snet-prod-001"
export NSG_NAME="nsg-${COMPANY}-dev-001"
export NSG_PROD_NAME="nsg-${COMPANY}-prod-001"
export PIP_NAME="pip-${COMPANY}-dev-001"
export PIP_PROD_NAME="pip-${COMPANY}-prod-001"
export NIC_NAME="nic-${COMPANY}-dev-001"
export NIC_PROD_NAME="nic-${COMPANY}-prod-001"

# ── Virtual Machine ────────────────────────────────────────────────────────
export VM_NAME="vm-${COMPANY}-dev-001"
export VM_PROD_NAME="vm-${COMPANY}-prod-001"
export VM_SIZE="Standard_B1s"
export VM_IMAGE="Ubuntu2204"
export ADMIN_USER="3mmtadmin"

# ── Storage Account (no hyphens allowed!) ──────────────────────────────────
export STORAGE_ACCOUNT="st${COMPANY_ID}dev001"
export STORAGE_PROD_ACCOUNT="st${COMPANY_ID}prod001"

# ── SQL Database ───────────────────────────────────────────────────────────
# export SQL_SERVER="sql-${COMPANY}-dev-001"
# export SQL_PROD_SERVER="sql-${COMPANY}-prod-001"
export SQL_SERVER="sql-3mmt-labs-dev-002"
export SQL_DB="sqldb-${COMPANY}-dev-001"
export SQL_PROD_DB="sqldb-${COMPANY}-prod-001"
export SQL_SERVER="sql-3mmt-labs-dev-002"
export SQL_ADMIN="3mmtadmindb"
export SQL_PASSWORD="3mmt@1234"
export SQL_PROD_ADMIN="3mmtadmindbprod"
export SQL_PROD_PASSWORD="3mmt@1234"
export SQL_LOCATION="eastus2"

# ── SSH Key Pair ─────────────────────────────────────────────────────────
export SSH_KEY_NAME="mySshKey"
export SSH_PROD_KEY_NAME="mySshKey-prod"
export SSH_PRIVATE_KEY_FILE="${SSH_PRIVATE_KEY_FILE:-$HOME/.ssh/id_azure}"
export SSH_PUBLIC_KEY_FILE="${SSH_PUBLIC_KEY_FILE:-$HOME/.ssh/id_azure.pub}"

# ── Derived IDs (populated after resources are created) ────────────────────
export MY_IP
MY_IP=$(curl -s --max-time 5 https://api.ipify.org || echo "0.0.0.0")

export MY_USER_ID
MY_USER_ID=$(az ad signed-in-user show --query id --output tsv 2>/dev/null || echo "")

# ── Summary ────────────────────────────────────────────────────────────────
cat <<EOF
╔══════════════════════════════════════════════╗
║  AZURE LAB — VARIABLES LOADED               ║
╠══════════════════════════════════════════════╣
║  Dev RG:      ${RG_DEV}
║  Prod RG:     ${RG_PROD}
║  VM:          ${VM_NAME}
║  VNet:        ${VNET_NAME}
║  NSG:         ${NSG_NAME}
║  Storage:     ${STORAGE_ACCOUNT}
║  SQL Server:  ${SQL_SERVER}
║  SQL DB:      ${SQL_DB}
║  My IP:       ${MY_IP}
║  Location:    ${LOCATION}
╚══════════════════════════════════════════════╝
EOF

echo "✅ SQL Admin Password: $SQL_PASSWORD"
echo "⚠️  Save the SQL password above — you will need it to connect to the database."
