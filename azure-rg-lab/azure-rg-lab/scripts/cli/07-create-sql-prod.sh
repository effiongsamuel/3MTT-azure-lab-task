#!/usr/bin/env bash
# =============================================================================
# Script: 07-create-sql-prod.sh
# Purpose: Create Production Azure SQL Server and a Serverless SQL Database.
# Pre-req: Source 01-setup-variables.sh; RG_PROD must exist.
# Usage:   bash ./scripts/cli/07-create-sql-prod.sh
# =============================================================================

set -euo pipefail

echo "▶ Creating Production Azure SQL Logical Server: $SQL_PROD_SERVER"
echo "  Admin: $SQL_PROD_ADMIN"
echo "  ⚠️  Password: $SQL_PROD_PASSWORD  ← SAVE THIS!"

az sql server create \
  --resource-group "$RG_PROD" \
  --name "$SQL_PROD_SERVER" \
  --location "$SQL_LOCATION" \
  --admin-user "$SQL_PROD_ADMIN" \
  --admin-password "$SQL_PROD_PASSWORD" \
  --output table

echo ""
echo "▶ Adding firewall rule: Allow Azure services..."
az sql server firewall-rule create \
  --resource-group "$RG_PROD" \
  --server "$SQL_PROD_SERVER" \
  --name "AllowAzureServices" \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0 \
  --output table

echo ""
echo "▶ Adding firewall rule: Allow my IP ($MY_IP)..."
az sql server firewall-rule create \
  --resource-group "$RG_PROD" \
  --server "$SQL_PROD_SERVER" \
  --name "AllowMyIP" \
  --start-ip-address "$MY_IP" \
  --end-ip-address "$MY_IP" \
  --output table

echo ""
echo "▶ Creating Production Serverless SQL Database: $SQL_PROD_DB"
echo "  Edition: GeneralPurpose | Tier: Serverless | Auto-pause: 60 min"

az sql db create \
  --resource-group "$RG_PROD" \
  --server "$SQL_PROD_SERVER" \
  --name "$SQL_PROD_DB" \
  --edition GeneralPurpose \
  --family Gen5 \
  --capacity 1 \
  --compute-model Serverless \
  --auto-pause-delay 60 \
  --min-capacity 0.5 \
  --tags \
    environment=prod \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT" \
  --output table

echo ""
echo "✅ Production SQL Database ready."
az sql db show \
  --resource-group "$RG_PROD" \
  --server "$SQL_PROD_SERVER" \
  --name "$SQL_PROD_DB" \
  --query "{Name:name, Edition:edition, ComputeModel:computeModel, AutoPause:autoPauseDelay, Status:status}" \
  --output table