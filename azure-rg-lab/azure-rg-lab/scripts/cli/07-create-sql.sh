#!/usr/bin/env bash
# =============================================================================
# Script: 06-create-sql.sh
# Purpose: Create Azure SQL Server and a Serverless SQL Database.
# Pre-req: Source 01-setup-variables.sh; RG_DEV must exist.
# Usage:   bash ./scripts/cli/06-create-sql.sh
# =============================================================================

set -euo pipefail

echo "▶ Creating Azure SQL Logical Server: $SQL_SERVER"
echo "  Admin: $SQL_ADMIN"
echo "  ⚠️  Password: $SQL_PASSWORD  ← SAVE THIS!"

az sql server create \
  --resource-group "$RG_DEV" \
  --name "$SQL_SERVER" \
  --location "$SQL_LOCATION" \
  --admin-user "$SQL_ADMIN" \
  --admin-password "$SQL_PASSWORD" \
  --output table

echo ""
echo "▶ Adding firewall rule: Allow Azure services..."
az sql server firewall-rule create \
  --resource-group "$RG_DEV" \
  --server "$SQL_SERVER" \
  --name "AllowAzureServices" \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0 \
  --output table

echo ""
echo "▶ Adding firewall rule: Allow my IP ($MY_IP)..."
az sql server firewall-rule create \
  --resource-group "$RG_DEV" \
  --server "$SQL_SERVER" \
  --name "AllowMyIP" \
  --start-ip-address "$MY_IP" \
  --end-ip-address "$MY_IP" \
  --output table

echo ""
echo "▶ Creating Serverless SQL Database: $SQL_DB"
echo "  Edition: GeneralPurpose | Tier: Serverless | Auto-pause: 60 min"

az sql db create \
  --resource-group "$RG_DEV" \
  --server "$SQL_SERVER" \
  --name "$SQL_DB" \
  --edition GeneralPurpose \
  --family Gen5 \
  --capacity 1 \
  --compute-model Serverless \
  --auto-pause-delay 60 \
  --min-capacity 0.5 \
  --tags \
    environment=dev \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT" \
  --output table

echo ""
echo "✅ SQL Database ready."
az sql db show \
  --resource-group "$RG_DEV" \
  --server "$SQL_SERVER" \
  --name "$SQL_DB" \
  --query "{Name:name, Edition:edition, ComputeModel:computeModel, AutoPause:autoPauseDelay, Status:status}" \
  --output table
