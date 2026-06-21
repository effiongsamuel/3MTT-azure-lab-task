# Azure Resource Organization and Resource Groups — Complete Lab Manual

> **Skill Level:** Absolute Beginner  
> **Estimated Time:** 4–6 hours  
> **Azure Cost:** ~$0–$5 (use free-tier resources; delete everything after the lab)  
> **Last Updated:** June 2026 | Azure CLI 2.x | Ubuntu 24.04

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture Design](#2-architecture-design)
3. [Naming Convention Table](#3-naming-convention-table)
4. [Resource Inventory Table](#4-resource-inventory-table)
5. [Pre-requisites and Environment Setup](#5-pre-requisites-and-environment-setup)
6. [Phase 1 — Create Resource Groups](#6-phase-1--create-resource-groups)
7. [Phase 2 — Deploy Virtual Network and NSG](#7-phase-2--deploy-virtual-network-and-nsg)
8. [Phase 3 — Deploy a Linux Virtual Machine](#8-phase-3--deploy-a-linux-virtual-machine)
9. [Phase 4 — Deploy a Storage Account](#9-phase-4--deploy-a-storage-account)
10. [Phase 5 — Deploy an Azure SQL Database](#10-phase-5--deploy-an-azure-sql-database)
11. [Phase 6 — Implement Tagging Strategy](#11-phase-6--implement-tagging-strategy)
12. [Phase 7 — Configure RBAC](#12-phase-7--configure-rbac)
13. [Phase 8 — Verification Commands](#13-phase-8--verification-commands)
14. [Phase 9 — Lifecycle Management](#14-phase-9--lifecycle-management)
15. [Tagging Strategy Table](#15-tagging-strategy-table)
16. [RBAC Summary Table](#16-rbac-summary-table)
17. [Screenshots Required for Submission](#17-screenshots-required-for-submission)
18. [Troubleshooting Common Errors](#18-troubleshooting-common-errors)
19. [Lessons Learned](#19-lessons-learned)
20. [Project Folder Structure](#20-project-folder-structure)

---

## 1. Project Overview

This lab teaches you how to professionally organize Azure resources using **Resource Groups**, **Subscriptions**, **RBAC**, **Azure Policy**, and **Tagging**. You will simulate a real-world scenario with separate Development and Production environments for a fictional company called **3mmt labs Technologies**.

### What You Will Build

| Component | Count | Purpose |
|---|---|---|
| Resource Groups | 2 | Logical containers for Dev and Prod |
| Virtual Network | 1 | Private network for VM communication |
| Network Security Group | 1 | Firewall rules for the VNet |
| Ubuntu Linux VM | 1 | Compute workload |
| Storage Account | 1 | Blob/file storage |
| Azure SQL Database | 1 | Relational database (serverless, free-tier) |
| RBAC Assignments | 3 | Owner, Contributor, Reader roles |
| Tags | 5 per resource | Environment, Owner, Project, CostCenter, Dept |

### Azure Services Explained (Beginner Guide)

**Azure Subscription** — Think of this as your Azure "account". It is the billing boundary. All resources you create sit inside a subscription. Your Azure free account gives you one subscription.

**Resource Group** — A logical folder inside your subscription. Every Azure resource (VM, database, storage) MUST belong to exactly one resource group. When you delete a resource group, ALL resources inside it are deleted together. This makes cleanup easy.

**Virtual Network (VNet)** — A private, isolated network inside Azure. Your VMs communicate with each other through this network. It works like a private office LAN.

**Network Security Group (NSG)** — A firewall attached to a VNet or a VM's network card. You write rules saying "allow SSH from my IP" or "block port 3389". Think of it as a bouncer at the door.

**Virtual Machine (VM)** — A server running in Azure's data centre. You choose the OS (Ubuntu Linux), the size (CPU/RAM), and the region. Azure bills you per hour the VM is running.

**Storage Account** — A general-purpose cloud storage service. Inside it you can create Blob containers (like S3 buckets), File Shares, Queues, and Tables.

**Azure SQL Database** — A fully managed relational database service (Microsoft SQL Server engine). The Serverless tier scales to zero when idle, keeping costs near zero during this lab.

**RBAC (Role-Based Access Control)** — Controls WHO can do WHAT to WHICH resources. You assign roles (Owner, Contributor, Reader) to users or groups at a specific scope (subscription, resource group, or resource).

**Azure Tags** — Key-value pairs you attach to any Azure resource. They do NOT affect behaviour — they are metadata for billing, automation, and governance. Example: `environment=dev`.

---

## 2. Architecture Design

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    AZURE SUBSCRIPTION: sub-3mmt labs-prod-001                 ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  ┌─────────────────────────────────────┐  ┌──────────────────────────────┐  ║
║  │   RESOURCE GROUP: rg-3mmt labs-dev   │  │  RESOURCE GROUP: rg-3mmt labs  ║  ║
║  │   Region: East US                  │  │  -prod                       ║  ║
║  │   Environment: Development         │  │  Region: East US             ║  ║
║  │                                     │  │  Environment: Production     ║  ║
║  │  ┌──────────────────────────────┐  │  │                              ║  ║
║  │  │  VNet: vnet-3mmt labs-dev-001  │  │  │  (Reserved for future        ║  ║
║  │  │  Address: 10.0.0.0/16        │  │  │   production workloads)      ║  ║
║  │  │                              │  │  │                              ║  ║
║  │  │  ┌────────────────────────┐  │  │  └──────────────────────────────┘  ║
║  │  │  │ Subnet: snet-dev-001   │  │  │                                    ║
║  │  │  │ Range: 10.0.1.0/24    │  │  │                                    ║
║  │  │  │                        │  │  │                                    ║
║  │  │  │  ┌──────────────────┐  │  │  │                                    ║
║  │  │  │  │  VM:             │  │  │  │                                    ║
║  │  │  │  │  vm-3mmt labs-dev  │  │  │  │                                    ║
║  │  │  │  │  -001            │  │  │  │                                    ║
║  │  │  │  │  Ubuntu 22.04    │  │  │  │                                    ║
║  │  │  │  │  B1s (1vCPU,1GB) │  │  │  │                                    ║
║  │  │  │  └──────────────────┘  │  │  │                                    ║
║  │  │  └────────────────────────┘  │  │                                    ║
║  │  │                              │  │                                    ║
║  │  │  NSG: nsg-3mmt labs-dev-001    │  │                                    ║
║  │  │  Rules: Allow SSH(22) Inbound│  │                                    ║
║  │  └──────────────────────────────┘  │                                    ║
║  │                                     │                                    ║
║  │  Storage: st3mmt labsdev001           │                                    ║
║  │  SQL Server: sql-3mmt labs-dev-001    │                                    ║
║  │  SQL DB: sqldb-3mmt labs-dev-001      │                                    ║
║  └─────────────────────────────────────┘                                    ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  RBAC ASSIGNMENTS                                                            ║
║  ┌────────────────────────────────────────────────────────────────────────┐  ║
║  │  Scope: rg-3mmt labs-dev      │  Role: Owner       │  Principal: You    │  ║
║  │  Scope: rg-3mmt labs-dev      │  Role: Contributor │  Principal: DevUser│  ║
║  │  Scope: rg-3mmt labs-prod     │  Role: Reader      │  Principal: AudUser│  ║
║  └────────────────────────────────────────────────────────────────────────┘  ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Data Flow:**
```
Internet
   │
   ▼
 NSG (Allow SSH port 22 inbound)
   │
   ▼
VNet (10.0.0.0/16)  ──►  Subnet (10.0.1.0/24)  ──►  VM (Ubuntu)
                                                         │
                                              Azure SQL Database
                                                         │
                                              Storage Account (Blob)
```

---

## 3. Naming Convention Table

> **Why naming conventions matter:** When you have hundreds of resources across teams, a consistent name instantly tells you: What is it? Which environment? Which region? Which number?

### Formula

```
{resource-type}-{company}-{environment}-{region}-{number}
```

### Resource Type Prefix Reference

| Resource | Prefix | Example |
|---|---|---|
| Subscription | `sub` | `sub-3mmt labs-prod-001` |
| Resource Group | `rg` | `rg-3mmt labs-dev` |
| Virtual Machine | `vm` | `vm-3mmt labs-dev-001` |
| Storage Account | `st` | `st3mmt labsdev001` ⚠️ |
| Virtual Network | `vnet` | `vnet-3mmt labs-dev-001` |
| Subnet | `snet` | `snet-dev-001` |
| Network Security Group | `nsg` | `nsg-3mmt labs-dev-001` |
| SQL Server (logical) | `sql` | `sql-3mmt labs-dev-001` |
| SQL Database | `sqldb` | `sqldb-3mmt labs-dev-001` |
| Public IP Address | `pip` | `pip-3mmt labs-dev-001` |
| Network Interface | `nic` | `nic-3mmt labs-dev-001` |
| OS Disk | `osdisk` | `osdisk-vm-dev-001` |

> ⚠️ **Storage Account Exception:** Azure Storage Account names must be 3–24 characters, **lowercase letters and numbers only** — no hyphens. Prefix is `st`, company name, environment, number with NO separators: `st3mmt labsdev001`

### Environment Abbreviations

| Environment | Abbreviation |
|---|---|
| Development | `dev` |
| Staging | `stg` |
| Production | `prod` |
| Testing | `test` |
| Disaster Recovery | `dr` |

### Region Abbreviations (common)

| Region | Abbreviation |
|---|---|
| East US | `eus` |
| West US 2 | `wus2` |
| West Europe | `weu` |
| North Europe | `neu` |
| UK South | `uks` |

---

## 4. Resource Inventory Table

| Resource Name | Type | Resource Group | Region | Notes |
|---|---|---|---|---|
| `rg-3mmt labs-dev` | Resource Group | N/A | East US | Dev container |
| `rg-3mmt labs-prod` | Resource Group | N/A | East US | Prod container |
| `vnet-3mmt labs-dev-001` | Virtual Network | rg-3mmt labs-dev | East US | 10.0.0.0/16 |
| `snet-dev-001` | Subnet | rg-3mmt labs-dev | East US | 10.0.1.0/24 |
| `nsg-3mmt labs-dev-001` | Network Security Group | rg-3mmt labs-dev | East US | Allow SSH |
| `vm-3mmt labs-dev-001` | Virtual Machine | rg-3mmt labs-dev | East US | Ubuntu 22.04, B1s |
| `pip-3mmt labs-dev-001` | Public IP | rg-3mmt labs-dev | East US | Dynamic, for VM |
| `nic-3mmt labs-dev-001` | Network Interface | rg-3mmt labs-dev | East US | Attached to VM |
| `st3mmt labsdev001` | Storage Account | rg-3mmt labs-dev | East US | LRS, Standard |
| `sql-3mmt labs-dev-001` | SQL Server | rg-3mmt labs-dev | East US | Logical server |
| `sqldb-3mmt labs-dev-001` | SQL Database | rg-3mmt labs-dev | East US | GP_S_Gen5_1, free |

---

## 5. Pre-requisites and Environment Setup

### What You Need Before Starting

- An **Azure account** — Sign up free at [azure.microsoft.com/free](https://azure.microsoft.com/free). You get $200 credit for 30 days plus always-free services.
- A computer running **Ubuntu 24.04** (or WSL2 on Windows with Ubuntu 24.04)
- An internet connection

### Step 5.1 — Install Azure CLI on Ubuntu 24.04

The Azure CLI lets you manage Azure from your terminal. Run these commands one at a time.

```bash
# Step 1: Update your package list
sudo apt-get update

# Step 2: Install prerequisite packages
sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg

# Step 3: Download and add Microsoft's signing key
curl -sLS https://packages.microsoft.com/keys/microsoft.asc | \
  gpg --dearmor | \
  sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/microsoft.gpg

# Step 4: Add the Azure CLI repository
AZ_DIST=$(lsb_release -cs)
echo "Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: ${AZ_DIST}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/microsoft.gpg" | \
  sudo tee /etc/apt/sources.list.d/azure-cli.sources

# Step 5: Update packages and install Azure CLI
sudo apt-get update
sudo apt-get install -y azure-cli

# Step 6: Verify the installation
az version
```

**Expected output** (version numbers may differ):
```json
{
  "azure-cli": "2.70.0",
  "azure-cli-core": "2.70.0",
  ...
}
```

### Step 5.2 — Log In to Azure

```bash
# This opens a browser window for you to log in with your Azure account
az login
```

After logging in, your terminal shows your subscription details:
```json
[
  {
    "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "name": "Azure subscription 1",
    "state": "Enabled",
    ...
  }
]
```

### Step 5.3 — Set Your Default Subscription

```bash
# List all subscriptions linked to your account
az account list --output table

# Set your subscription as default (replace with your actual subscription ID)
az account set --subscription "Azure subscription 1"

# Confirm which subscription is active
az account show --output table
```

### Step 5.4 — Set Shell Variables (Time-Saver)

Set these once at the start of your terminal session. All CLI commands in this guide use these variables, so you only type your values once.

```bash
# ── Company / Project ──────────────────────────────────────────────────────
export COMPANY="3mmt labs"
export PROJECT="azure-rg-lab"
export COSTCENTER="CC-1001"
export DEPARTMENT="IT-Engineering"
export OWNER="yourname@youremail.com"   # ← Change this to your email

# ── Region ─────────────────────────────────────────────────────────────────
export LOCATION="eastus"

# ── Resource Group Names ───────────────────────────────────────────────────
export RG_DEV="rg-${COMPANY}-dev"
export RG_PROD="rg-${COMPANY}-prod"

# ── Network Resources ──────────────────────────────────────────────────────
export VNET_NAME="vnet-${COMPANY}-dev-001"
export SUBNET_NAME="snet-dev-001"
export NSG_NAME="nsg-${COMPANY}-dev-001"
export PIP_NAME="pip-${COMPANY}-dev-001"
export NIC_NAME="nic-${COMPANY}-dev-001"

# ── Virtual Machine ────────────────────────────────────────────────────────
export VM_NAME="vm-${COMPANY}-dev-001"
export VM_SIZE="Standard_B1s"
export VM_IMAGE="Ubuntu2204"
export ADMIN_USER="azureuser"

# ── Storage Account ────────────────────────────────────────────────────────
export STORAGE_ACCOUNT="st${COMPANY}dev001"   # no hyphens!

# ── SQL Database ───────────────────────────────────────────────────────────
export SQL_SERVER="sql-${COMPANY}-dev-001"
export SQL_DB="sqldb-${COMPANY}-dev-001"
export SQL_ADMIN="sqladmin"
export SQL_PASSWORD="P@ssw0rd$(date +%s)!"    # Auto-generates unique password

# Print all variables to confirm they look correct
echo "=== Variables Set ==="
echo "Dev RG:     $RG_DEV"
echo "Prod RG:    $RG_PROD"
echo "VM Name:    $VM_NAME"
echo "Storage:    $STORAGE_ACCOUNT"
echo "SQL Server: $SQL_SERVER"
echo "SQL Pass:   $SQL_PASSWORD"
echo "===================="
```

> 💡 **Save the SQL password** printed in your terminal. You will need it later to connect to the database.

---

## 6. Phase 1 — Create Resource Groups

Resource Groups are the foundation. Create these first — everything else goes inside them.

### Via Azure Portal

**Path:** `portal.azure.com` → Search "Resource groups" → **+ Create**

**Development Resource Group:**

| Field | Value | Why |
|---|---|---|
| Subscription | Your subscription | The billing account it belongs to |
| Resource group name | `rg-3mmt labs-dev` | Follows naming convention |
| Region | `(US) East US` | Where metadata is stored |

Click **Next: Tags**

| Name | Value |
|---|---|
| environment | dev |
| owner | your-email@domain.com |
| project | azure-rg-lab |
| costcenter | CC-1001 |
| department | IT-Engineering |

Click **Review + create** → **Create**

Repeat the same steps for the **Production Resource Group** with:
- Resource group name: `rg-3mmt labs-prod`
- Tag `environment` = `prod`

📸 **SCREENSHOT:** After both resource groups appear in the list view, capture the screen showing both `rg-3mmt labs-dev` and `rg-3mmt labs-prod`.

---

### Via Azure CLI

```bash
# ── Create Development Resource Group ──────────────────────────────────────
# az group create : creates a new resource group
# --name         : the name of the resource group
# --location     : the Azure region
# --tags         : key=value pairs (space-separated for multiple tags)

az group create \
  --name "$RG_DEV" \
  --location "$LOCATION" \
  --tags \
    environment=dev \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT"

# ── Create Production Resource Group ───────────────────────────────────────
az group create \
  --name "$RG_PROD" \
  --location "$LOCATION" \
  --tags \
    environment=prod \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT"
```

**Verify both were created:**
```bash
az group list --output table
```

Expected output:
```
Name               Location    Status
-----------------  ----------  ---------
rg-3mmt labs-dev     eastus      Succeeded
rg-3mmt labs-prod    eastus      Succeeded
```

---

## 7. Phase 2 — Deploy Virtual Network and NSG

A VM needs a network to live on. Create the VNet, Subnet, NSG, and wire them together before creating the VM.

### Step 7.1 — Create the Virtual Network

#### Via Azure Portal

**Path:** Search "Virtual networks" → **+ Create**

| Field | Value |
|---|---|
| Subscription | Your subscription |
| Resource group | `rg-3mmt labs-dev` |
| Virtual network name | `vnet-3mmt labs-dev-001` |
| Region | East US |

Click **Next: IP Addresses**

| Field | Value |
|---|---|
| IPv4 address space | `10.0.0.0/16` |
| Subnet name | `snet-dev-001` |
| Subnet address range | `10.0.1.0/24` |

Click **Review + create** → **Create**

📸 **SCREENSHOT:** The VNet overview page after creation showing the address space.

#### Via Azure CLI

```bash
# ── Create Virtual Network ──────────────────────────────────────────────────
# --address-prefix : the overall IP address space for this VNet (CIDR notation)
# /16 means addresses 10.0.0.0 through 10.0.255.255 (65,536 addresses)

az network vnet create \
  --resource-group "$RG_DEV" \
  --name "$VNET_NAME" \
  --location "$LOCATION" \
  --address-prefix "10.0.0.0/16" \
  --subnet-name "$SUBNET_NAME" \
  --subnet-prefix "10.0.1.0/24" \
  --tags \
    environment=dev \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT"
```

### Step 7.2 — Create the Network Security Group

#### Via Azure Portal

**Path:** Search "Network security groups" → **+ Create**

| Field | Value |
|---|---|
| Resource group | `rg-3mmt labs-dev` |
| Name | `nsg-3mmt labs-dev-001` |
| Region | East US |

After creation, open the NSG → **Inbound security rules** → **+ Add**

| Field | Value | Explanation |
|---|---|---|
| Source | IP Addresses | Restrict to specific IP |
| Source IP | Your public IP (google "what is my ip") | Only YOUR machine can SSH |
| Source port ranges | `*` | Any source port |
| Destination | Any | The VM's IP |
| Service | SSH | Auto-fills port 22, TCP |
| Action | Allow | Permit the connection |
| Priority | `100` | Lower = checked first |
| Name | `Allow-SSH-Inbound` | Descriptive |

📸 **SCREENSHOT:** NSG rules tab showing the SSH allow rule.

#### Via Azure CLI

```bash
# ── Create NSG ─────────────────────────────────────────────────────────────
az network nsg create \
  --resource-group "$RG_DEV" \
  --name "$NSG_NAME" \
  --location "$LOCATION" \
  --tags \
    environment=dev \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT"

# ── Get your current public IP for SSH rule ────────────────────────────────
MY_IP=$(curl -s https://api.ipify.org)
echo "Your public IP is: $MY_IP"

# ── Add SSH Allow Inbound Rule ─────────────────────────────────────────────
# --priority   : 100-4096, lower = evaluated first
# --direction  : Inbound or Outbound
# --access     : Allow or Deny
# --protocol   : Tcp, Udp, Icmp, or *
# --destination-port-range : Port 22 = SSH

az network nsg rule create \
  --resource-group "$RG_DEV" \
  --nsg-name "$NSG_NAME" \
  --name "Allow-SSH-Inbound" \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefix "$MY_IP" \
  --source-port-range "*" \
  --destination-address-prefix "*" \
  --destination-port-range 22

# ── Associate NSG with Subnet ──────────────────────────────────────────────
az network vnet subnet update \
  --resource-group "$RG_DEV" \
  --vnet-name "$VNET_NAME" \
  --name "$SUBNET_NAME" \
  --network-security-group "$NSG_NAME"
```

---

## 8. Phase 3 — Deploy a Linux Virtual Machine

### Via Azure Portal

**Path:** Search "Virtual machines" → **+ Create** → **Azure virtual machine**

**Basics Tab:**

| Field | Value | Explanation |
|---|---|---|
| Subscription | Your subscription | |
| Resource group | `rg-3mmt labs-dev` | Our dev container |
| Virtual machine name | `vm-3mmt labs-dev-001` | Follows naming convention |
| Region | East US | Same as other resources |
| Availability options | No infrastructure redundancy | Lab only — not HA |
| Security type | Standard | Trusted launch costs more |
| Image | `Ubuntu Server 22.04 LTS - x64 Gen2` | Free-tier eligible |
| Size | `Standard_B1s` (1vCPU, 1GB RAM) | Cheapest size |
| Authentication type | SSH public key | More secure than password |
| Username | `azureuser` | Default admin user |
| SSH public key source | Generate new key pair | Portal generates for you |
| Key pair name | `vm-3mmt labs-dev-001_key` | |
| Public inbound ports | None | We use the NSG instead |

Click **Download private key and create resource** when prompted — SAVE this .pem file!

**Disks Tab:**
- OS disk type: `Standard SSD` (cheapest)

**Networking Tab:**

| Field | Value |
|---|---|
| Virtual network | `vnet-3mmt labs-dev-001` |
| Subnet | `snet-dev-001 (10.0.1.0/24)` |
| Public IP | Create new → name: `pip-3mmt labs-dev-001` |
| NIC network security group | None (already on subnet) |
| Delete NIC when VM is deleted | ✅ Check this |

**Tags Tab:** Add all 5 tags (environment, owner, project, costcenter, department)

Click **Review + create** → **Create**

> Wait 2–5 minutes for deployment to complete.

📸 **SCREENSHOT:** VM overview page showing Status = "Running", Public IP address, and Operating system.

---

### Via Azure CLI

```bash
# ── Create Public IP Address ────────────────────────────────────────────────
# --allocation-method : Static keeps the same IP; Dynamic may change on restart

az network public-ip create \
  --resource-group "$RG_DEV" \
  --name "$PIP_NAME" \
  --location "$LOCATION" \
  --allocation-method Static \
  --sku Standard \
  --tags \
    environment=dev \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT"

# ── Create Network Interface Card ──────────────────────────────────────────
az network nic create \
  --resource-group "$RG_DEV" \
  --name "$NIC_NAME" \
  --location "$LOCATION" \
  --vnet-name "$VNET_NAME" \
  --subnet "$SUBNET_NAME" \
  --public-ip-address "$PIP_NAME" \
  --network-security-group "$NSG_NAME"

# ── Create Ubuntu Linux VM ──────────────────────────────────────────────────
# --generate-ssh-keys : Creates ~/.ssh/id_rsa and id_rsa.pub if they don't exist
#                       The public key is installed on the VM automatically
# --size             : Standard_B1s = 1 vCPU, 1GB RAM (cheapest, free-tier eligible)
# --image            : Ubuntu2204 = Ubuntu Server 22.04 LTS

az vm create \
  --resource-group "$RG_DEV" \
  --name "$VM_NAME" \
  --location "$LOCATION" \
  --size "$VM_SIZE" \
  --image "$VM_IMAGE" \
  --admin-username "$ADMIN_USER" \
  --generate-ssh-keys \
  --nics "$NIC_NAME" \
  --os-disk-name "osdisk-${VM_NAME}" \
  --storage-sku StandardSSD_LRS \
  --tags \
    environment=dev \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT"
```

**Wait for the VM to be created** (typically 2–4 minutes). Output will include the public IP.

```bash
# ── Get the VM's public IP ──────────────────────────────────────────────────
VM_PUBLIC_IP=$(az vm show \
  --resource-group "$RG_DEV" \
  --name "$VM_NAME" \
  --show-details \
  --query publicIps \
  --output tsv)

echo "VM Public IP: $VM_PUBLIC_IP"

# ── Test SSH connection to the VM ──────────────────────────────────────────
# -o StrictHostKeyChecking=no : Skip the "are you sure" prompt for new hosts
ssh -o StrictHostKeyChecking=no "${ADMIN_USER}@${VM_PUBLIC_IP}" "hostname && uname -a"
```

Expected output:
```
vm-3mmt labs-dev-001
Linux vm-3mmt labs-dev-001 5.15.0-... #... SMP ... x86_64 x86_64 x86_64 GNU/Linux
```

📸 **SCREENSHOT:** Terminal showing successful SSH connection and hostname output.

---

## 9. Phase 4 — Deploy a Storage Account

### Via Azure Portal

**Path:** Search "Storage accounts" → **+ Create**

**Basics Tab:**

| Field | Value | Explanation |
|---|---|---|
| Resource group | `rg-3mmt labs-dev` | |
| Storage account name | `st3mmt labsdev001` | Lowercase + numbers ONLY |
| Region | East US | |
| Performance | Standard | Adequate for most workloads |
| Redundancy | LRS (Locally-redundant storage) | Cheapest; 3 copies in 1 datacenter |

**Advanced Tab:**
- Minimum TLS version: TLS 1.2 (security best practice)
- Allow blob anonymous access: Disabled (security best practice)

**Tags Tab:** Add all 5 tags.

Click **Review + create** → **Create**

📸 **SCREENSHOT:** Storage Account overview showing the name, redundancy type, and location.

---

### Via Azure CLI

```bash
# ── Create Storage Account ──────────────────────────────────────────────────
# --sku           : LRS = Locally Redundant Storage (3 copies in 1 region, cheapest)
# --kind          : StorageV2 = general-purpose v2 (recommended for most cases)
# --min-tls-version : Enforce TLS 1.2 minimum for security
# --allow-blob-public-access : Disabled prevents anonymous internet access

az storage account create \
  --resource-group "$RG_DEV" \
  --name "$STORAGE_ACCOUNT" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --tags \
    environment=dev \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT"

# ── Create a Blob Container inside the Storage Account ─────────────────────
# --account-name    : the storage account
# --name            : container name (like an S3 bucket)
# --public-access   : off = private, no anonymous access

az storage container create \
  --account-name "$STORAGE_ACCOUNT" \
  --name "dev-container" \
  --public-access off \
  --auth-mode login
```

---

## 10. Phase 5 — Deploy an Azure SQL Database

Azure SQL Database's **Serverless** tier scales CPU to zero when idle. This means it costs almost nothing during this lab (you pay only for storage, roughly $0.10/month for 1GB).

### Via Azure Portal

**Path:** Search "SQL databases" → **+ Create**

**Basics Tab:**

| Field | Value |
|---|---|
| Resource group | `rg-3mmt labs-dev` |
| Database name | `sqldb-3mmt labs-dev-001` |
| Server | Create new (see below) |
| Want to use SQL elastic pool? | No |
| Workload environment | Development |
| Compute + storage | Configure database → see below |

**Create new server:**
| Field | Value |
|---|---|
| Server name | `sql-3mmt labs-dev-001` |
| Location | East US |
| Authentication method | Use SQL authentication |
| Server admin login | `sqladmin` |
| Password | A strong password (save this!) |

**Configure database (click "Configure database"):**
- Service tier: General Purpose
- Compute tier: **Serverless** ← Important! This scales to zero
- vCores: Min 0.5, Max 1
- Auto-pause delay: 1 hour

**Networking Tab:**
- Connectivity method: Public endpoint
- Allow Azure services and resources to access this server: Yes
- Add current client IP address: Yes (so you can query it)

**Tags Tab:** Add all 5 tags.

Click **Review + create** → **Create**

> First-time SQL server creation takes 3–5 minutes.

📸 **SCREENSHOT:** SQL Database overview page showing the server name, pricing tier "General Purpose: Serverless", and status.

---

### Via Azure CLI

```bash
# ── Create Azure SQL Logical Server ────────────────────────────────────────
# The logical server is a management container — the actual database goes inside it.
# --admin-user and --admin-password : SQL authentication credentials

az sql server create \
  --resource-group "$RG_DEV" \
  --name "$SQL_SERVER" \
  --location "$LOCATION" \
  --admin-user "$SQL_ADMIN" \
  --admin-password "$SQL_PASSWORD"

# ── Allow Azure services to reach the SQL server ───────────────────────────
az sql server firewall-rule create \
  --resource-group "$RG_DEV" \
  --server "$SQL_SERVER" \
  --name "AllowAzureServices" \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# ── Allow your own IP to reach the SQL server ──────────────────────────────
az sql server firewall-rule create \
  --resource-group "$RG_DEV" \
  --server "$SQL_SERVER" \
  --name "AllowMyIP" \
  --start-ip-address "$MY_IP" \
  --end-ip-address "$MY_IP"

# ── Create the SQL Database (Serverless tier) ──────────────────────────────
# --edition          : GeneralPurpose (required for serverless)
# --family           : Gen5 hardware generation
# --capacity         : vCores (1 = minimum for serverless)
# --compute-model    : Serverless (scales to zero when idle!)
# --auto-pause-delay : Minutes before auto-pause (-1 = disabled; 60 = 1 hour)
# --min-capacity     : Minimum vCores when running (0.5 = cheapest)

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
    department="$DEPARTMENT"
```

---

## 11. Phase 6 — Implement Tagging Strategy

Tags were added during resource creation. This phase shows how to view and update tags on existing resources.

### Via Azure Portal

**To view tags:** Open any resource → Left menu → **Tags**

**To add/update tags on an existing resource:**
1. Open the resource group `rg-3mmt labs-dev`
2. Click on any resource (e.g., the VM)
3. In the left sidebar, click **Tags**
4. Add or modify tag key-value pairs
5. Click **Save**

📸 **SCREENSHOT:** Tags page for `vm-3mmt labs-dev-001` showing all 5 tags applied.

---

### Via Azure CLI — View and Update Tags

```bash
# ── View tags on the Resource Group ─────────────────────────────────────────
az group show \
  --name "$RG_DEV" \
  --query tags \
  --output table

# ── View tags on the VM ─────────────────────────────────────────────────────
az vm show \
  --resource-group "$RG_DEV" \
  --name "$VM_NAME" \
  --query tags \
  --output table

# ── Update a single tag on a resource (without removing others) ─────────────
# IMPORTANT: az tag update --operation Merge adds/updates without deleting existing tags
# --operation Replace would OVERWRITE ALL existing tags (destructive!)

az tag update \
  --resource-id $(az vm show --resource-group "$RG_DEV" --name "$VM_NAME" --query id --output tsv) \
  --operation Merge \
  --tags costcenter="CC-1001-UPDATED"

# ── List ALL resources and their tags in the dev RG ─────────────────────────
az resource list \
  --resource-group "$RG_DEV" \
  --query "[].{Name:name, Type:type, Tags:tags}" \
  --output table

# ── Find all resources with a specific tag value (across all RGs) ───────────
az resource list \
  --tag environment=dev \
  --query "[].{Name:name, ResourceGroup:resourceGroup}" \
  --output table
```

---

## 12. Phase 7 — Configure RBAC

RBAC controls access to Azure resources. You assign a **role** to a **security principal** (user, group, or service) at a specific **scope** (subscription, resource group, or resource).

### Understanding the Three Core Roles

**Owner**
- Can do everything: create, read, update, delete resources.
- Can assign roles to others.
- **Use for:** The project lead, yourself on your own subscription.
- **Risk:** If an Owner account is compromised, the attacker can delete everything and assign themselves permanent access. Use MFA.

**Contributor**
- Can create, read, update, delete resources.
- **Cannot** assign roles to others.
- **Use for:** Developers who need to deploy and manage resources but should NOT control who has access.
- **Security:** A compromised Contributor cannot escalate privileges by adding themselves as Owner.

**Reader**
- Can only view resources — cannot create, change, or delete anything.
- **Use for:** Auditors, finance teams reviewing costs, stakeholders who need visibility but not control.
- **Least-privilege principle:** Give people only the access they need, and no more.

### The Least-Privilege Principle

> **"Give the minimum permission needed to do the job."**

Instead of making everyone an Owner, think:
- Does this person need to DELETE resources? → Contributor may be enough
- Do they just need to VIEW resources? → Reader is sufficient
- Do they need to control access? → Owner is required, but scope it narrowly

### Via Azure Portal

**Path:** Open `rg-3mmt labs-dev` → **Access control (IAM)** → **+ Add** → **Add role assignment**

**Assignment 1 — Contributor on Dev RG (for a developer):**

| Field | Value |
|---|---|
| Role | Contributor |
| Assign access to | User, group, or service principal |
| Members | Search for a user's email (or use your own for this lab) |

Click **Review + assign**

**Assignment 2 — Reader on Prod RG (for an auditor):**

Open `rg-3mmt labs-prod` → **Access control (IAM)** → **+ Add** → **Add role assignment**

| Field | Value |
|---|---|
| Role | Reader |
| Members | Search for a different user (or use your own for the lab) |

📸 **SCREENSHOT:** IAM page for `rg-3mmt labs-dev` showing the Role assignments tab with the Contributor assignment visible.

---

### Via Azure CLI

```bash
# ── Get your own user Object ID (needed for role assignments) ───────────────
MY_USER_ID=$(az ad signed-in-user show --query id --output tsv)
echo "Your Object ID: $MY_USER_ID"

# ── Get the Resource Group IDs ──────────────────────────────────────────────
RG_DEV_ID=$(az group show --name "$RG_DEV" --query id --output tsv)
RG_PROD_ID=$(az group show --name "$RG_PROD" --query id --output tsv)

echo "Dev RG ID:  $RG_DEV_ID"
echo "Prod RG ID: $RG_PROD_ID"

# ── Assignment 1: Assign yourself as Owner of the Dev RG ───────────────────
# --role        : Role name or Role Definition ID
# --assignee    : Object ID of the user/group/service principal
# --scope       : The Azure resource ID this assignment applies to

az role assignment create \
  --role "Owner" \
  --assignee "$MY_USER_ID" \
  --scope "$RG_DEV_ID"

# ── Assignment 2: Contributor on Dev RG ────────────────────────────────────
# For this lab, we assign Contributor to ourselves at the dev RG scope.
# In a real scenario, replace $MY_USER_ID with another user's Object ID.

az role assignment create \
  --role "Contributor" \
  --assignee "$MY_USER_ID" \
  --scope "$RG_DEV_ID" \
  --description "Developer access to development environment"

# ── Assignment 3: Reader on Prod RG ────────────────────────────────────────
az role assignment create \
  --role "Reader" \
  --assignee "$MY_USER_ID" \
  --scope "$RG_PROD_ID" \
  --description "Audit/read-only access to production environment"

# ── List all role assignments on the Dev RG ─────────────────────────────────
az role assignment list \
  --scope "$RG_DEV_ID" \
  --output table

# ── List all role assignments on the Prod RG ───────────────────────────────
az role assignment list \
  --scope "$RG_PROD_ID" \
  --output table
```

---

## 13. Phase 8 — Verification Commands

Run these commands to confirm everything was deployed correctly.

```bash
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
echo ""
echo "✅ CHECK 6: SQL Database"
az sql db show \
  --resource-group "$RG_DEV" \
  --server "$SQL_SERVER" \
  --name "$SQL_DB" \
  --query "{Name:name, Edition:edition, ComputeModel:computeModel, Status:status}" \
  --output table

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
```

📸 **SCREENSHOT:** Terminal output showing all 9 checks passing.

---

## 14. Phase 9 — Lifecycle Management

### The Power of Resource Groups

Deleting a Resource Group deletes ALL resources inside it in a single operation. This is why correct organization matters — you don't accidentally delete production resources when cleaning up dev.

### Impact Analysis Before Deletion

```bash
# ── List everything that will be deleted ────────────────────────────────────
echo "The following resources will be permanently deleted:"
az resource list \
  --resource-group "$RG_DEV" \
  --query "[].{Name:name, Type:type, Location:location}" \
  --output table

echo ""
echo "Count of resources to be deleted:"
az resource list \
  --resource-group "$RG_DEV" \
  --query "length(@)" \
  --output tsv
```

### Recovery Considerations

⚠️ **Before deleting, consider:**

| Resource | Recovery After Deletion | Action Before Delete |
|---|---|---|
| Virtual Machine | NOT recoverable unless backed up | Take a snapshot of the OS disk |
| Storage Account | Soft delete: 7–365 day recovery window (if enabled) | Enable soft delete first |
| SQL Database | Point-in-time restore available for 7–35 days after deletion | May recover from backups |
| VNet / NSG | Configuration is gone; no data to recover | Export ARM template as backup |

### Export ARM Template (Backup Configuration)

```bash
# ── Export the entire Resource Group as an ARM template ─────────────────────
# This saves the configuration (NOT the data) so you could recreate the infrastructure

az group export \
  --name "$RG_DEV" \
  --output json > ./scripts/arm-templates/rg-3mmt labs-dev-backup.json

echo "ARM template saved to ./scripts/arm-templates/rg-3mmt labs-dev-backup.json"
```

### Delete the Development Resource Group

#### Via Azure Portal

1. Open `rg-3mmt labs-dev` resource group
2. Click **Delete resource group** at the top
3. Type the resource group name `rg-3mmt labs-dev` in the confirmation box
4. Click **Delete**
5. Wait 3–10 minutes for all resources to be removed

📸 **SCREENSHOT:** The confirmation dialog with the resource group name typed in.

#### Via Azure CLI

```bash
# ── CAUTION: This permanently deletes ALL resources in the group ────────────

# First, do a dry run — list what will be deleted
echo "About to delete these resources:"
az resource list --resource-group "$RG_DEV" --query "[].name" --output tsv

# Confirm deletion (remove the --no-wait flag to wait for completion)
az group delete \
  --name "$RG_DEV" \
  --yes \
  --no-wait

echo "Deletion initiated for $RG_DEV. This will take several minutes."

# ── Monitor until deletion completes ────────────────────────────────────────
# The group will disappear from the list when deletion is done
az group list --output table
```

📸 **SCREENSHOT:** `az group list` output showing only `rg-3mmt labs-prod` remains.

### Re-create Dev Resource Group (for learning continuity)

```bash
# ── Recreate rg-3mmt labs-dev to demonstrate lifecycle ───────────────────────
az group create \
  --name "$RG_DEV" \
  --location "$LOCATION" \
  --tags \
    environment=dev \
    owner="$OWNER" \
    project="$PROJECT" \
    costcenter="$COSTCENTER" \
    department="$DEPARTMENT"

echo "Resource group $RG_DEV recreated successfully."
```

---

## 15. Tagging Strategy Table

| Tag Key | Dev Value | Prod Value | Purpose |
|---|---|---|---|
| `environment` | `dev` | `prod` | Identify the environment; used in Policy rules |
| `owner` | `dev-lead@3mmt labs.com` | `ops-team@3mmt labs.com` | Who is responsible for this resource |
| `project` | `azure-rg-lab` | `azure-rg-lab` | Which project/initiative created this |
| `costcenter` | `CC-1001` | `CC-2001` | Billing allocation — which team/dept pays |
| `department` | `IT-Engineering` | `IT-Operations` | Organizational unit |

**Why Tagging Matters:**
- **Cost Management:** Filter Azure Cost Analysis by `costcenter` tag to see how much each team is spending
- **Automation:** Run scripts that target all resources with `environment=dev` for automated shutdown at night
- **Compliance:** Azure Policy can enforce that all resources MUST have certain tags (reject resources without them)
- **Incident Response:** `owner` tag instantly tells you who to call when something breaks at 2am

---

## 16. RBAC Summary Table

| Assignment | Role | Scope | Principal | Justification |
|---|---|---|---|---|
| 1 | Owner | `rg-3mmt labs-dev` | Lab Admin (you) | Full control needed to manage the lab |
| 2 | Contributor | `rg-3mmt labs-dev` | Developer User | Developers need to deploy code/resources but should NOT manage access |
| 3 | Reader | `rg-3mmt labs-prod` | Auditor User | Auditors and finance need visibility without risk of changes |

**Security Implications:**
- **Owner** has the `Microsoft.Authorization/*/write` permission — they can add/remove role assignments. Never assign Owner broadly.
- **Contributor** cannot escalate their own privileges. A Contributor who goes rogue can delete resources but cannot grant themselves Owner access.
- **Reader** is safe for external parties. A Reader cannot make any changes whatsoever.
- **Scope matters:** An Owner at the Resource Group scope has no power outside that Resource Group. Always scope roles as narrowly as possible.

---

## 17. Screenshots Required for Submission

Capture these 12 screenshots during the lab. Name them exactly as shown for easy reference.

| # | Screenshot Name | What to Capture | When to Take It |
|---|---|---|---|
| 1 | `01-resource-groups-list.png` | Both RGs in the Azure Portal resource group list | After Phase 1 |
| 2 | `02-vnet-overview.png` | VNet overview showing address space 10.0.0.0/16 | After Phase 2 |
| 3 | `03-nsg-rules.png` | NSG inbound rules tab showing Allow-SSH-Inbound rule | After Phase 2 |
| 4 | `04-vm-overview.png` | VM overview showing Status=Running, Public IP, OS | After Phase 3 |
| 5 | `05-vm-ssh-connection.png` | Terminal showing successful SSH login to the VM | After Phase 3 |
| 6 | `06-storage-account-overview.png` | Storage account overview with name, LRS, region | After Phase 4 |
| 7 | `07-sql-database-overview.png` | SQL Database overview showing Serverless tier | After Phase 5 |
| 8 | `08-vm-tags.png` | Tags page on VM showing all 5 tags | After Phase 6 |
| 9 | `09-rbac-iam-page.png` | IAM Role assignments tab for rg-3mmt labs-dev | After Phase 7 |
| 10 | `10-verification-output.png` | Terminal with all 9 verification checks passing | After Phase 8 |
| 11 | `11-rg-deletion-confirm.png` | Portal deletion confirmation dialog | During Phase 9 |
| 12 | `12-rg-deleted-list.png` | Resource group list showing only rg-3mmt labs-prod | After Phase 9 |

---

## 18. Troubleshooting Common Errors

### Error 1: "az: command not found"
**Cause:** Azure CLI is not installed or not in PATH.  
**Fix:**
```bash
which az                      # Check if az is found
source ~/.bashrc              # Reload shell config
az --version                  # Test again
# If still missing, re-run the install steps in Phase 5.1
```

### Error 2: "Conflict: The storage account name 'st3mmt labsdev001' is already taken"
**Cause:** Storage account names are globally unique across all Azure customers.  
**Fix:** Add a random suffix to make the name unique:
```bash
SUFFIX=$(tr -dc a-z0-9 < /dev/urandom | head -c 4)
export STORAGE_ACCOUNT="st${COMPANY}dev${SUFFIX}"
echo "New storage name: $STORAGE_ACCOUNT"
```

### Error 3: "The subscription is not registered to use namespace 'Microsoft.Sql'"
**Cause:** Some resource providers are not enabled on new Azure accounts.  
**Fix:**
```bash
# Register the SQL resource provider
az provider register --namespace Microsoft.Sql
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Network

# Wait 1–2 minutes, then check status
az provider show --namespace Microsoft.Sql --query registrationState --output tsv
# Should return: Registered
```

### Error 4: "AuthorizationFailed — does not have authorization to perform action"
**Cause:** Your account does not have the required RBAC role.  
**Fix:**
```bash
# Check your current roles on the subscription
az role assignment list --assignee "$(az ad signed-in-user show --query userPrincipalName --output tsv)" --output table

# If you need to be Owner on the subscription:
# Go to portal.azure.com → Subscriptions → Your subscription → Access Control (IAM) → Add Owner
```

### Error 5: VM creation fails with "SkuNotAvailable"
**Cause:** Standard_B1s is not available in the selected region.  
**Fix:**
```bash
# List available VM sizes in your region
az vm list-sizes --location "$LOCATION" --query "[?name=='Standard_B1s']" --output table

# Try an alternate size
export VM_SIZE="Standard_B1ms"   # 1 vCPU, 2GB RAM — slightly more expensive
```

### Error 6: SSH connection times out
**Cause:** NSG rule has wrong source IP, or your IP changed.  
**Fix:**
```bash
# Get your current IP
MY_IP=$(curl -s https://api.ipify.org)
echo "Current IP: $MY_IP"

# Update the NSG rule
az network nsg rule update \
  --resource-group "$RG_DEV" \
  --nsg-name "$NSG_NAME" \
  --name "Allow-SSH-Inbound" \
  --source-address-prefix "$MY_IP"
```

### Error 7: "az group delete" hangs / takes too long
**Cause:** A resource has a delete lock or is still being provisioned.  
**Fix:**
```bash
# Check for delete locks
az lock list --resource-group "$RG_DEV" --output table

# Remove any locks
az lock delete --name <lock-name> --resource-group "$RG_DEV"

# Then retry deletion
az group delete --name "$RG_DEV" --yes
```

### Error 8: SQL database creation fails — "Server name already exists"
**Cause:** SQL Server names are globally unique across all Azure.  
**Fix:**
```bash
SUFFIX=$(tr -dc a-z0-9 < /dev/urandom | head -c 4)
export SQL_SERVER="sql-${COMPANY}-dev-${SUFFIX}"
echo "New SQL server name: $SQL_SERVER"
```

---

## 19. Lessons Learned

After completing this lab, you should be able to explain the following concepts:

**1. Resource Groups are lifecycle boundaries, not just folders.**
Everything inside a resource group shares its lifecycle. Delete the group = delete everything. This is a feature, not a bug — it makes teardown of development environments trivially easy and avoids "orphaned resource" bills.

**2. Naming conventions are worth the initial investment.**
A name like `vm-3mmt labs-dev-001` tells you: it is a VM, it belongs to 3mmt labs, it is in Development, and it is the first one. When you are troubleshooting at midnight, these instant clues save time and reduce mistakes.

**3. Tags are the backbone of cost governance.**
Without tags, you cannot tell which team's workload is driving up the Azure bill. With tags (especially `costcenter` and `environment`), Azure Cost Management can produce a breakdown by team, by environment, and by project automatically.

**4. RBAC is always scoped — think narrowly.**
The same person can be Owner on the dev resource group and Reader on production. Never give someone broader access than they need. Contributor protects you from accidental role escalation — a developer who goes rogue cannot promote themselves to Owner.

**5. NSG rules are the first line of VM defence.**
Leaving port 22 (SSH) open to `0.0.0.0/0` (any IP) invites brute-force attacks within minutes. Always restrict SSH to your specific IP. In production, use Azure Bastion or a VPN instead.

**6. The Serverless SQL tier is ideal for non-production databases.**
Auto-pausing to zero when idle means you pay cents per day instead of dollars. Always choose Serverless for dev/test databases.

**7. ARM template export is your infrastructure backup.**
Before deleting resources, export the ARM template. It captures the configuration (not the data) so you can recreate the infrastructure in minutes.

---

## 20. Project Folder Structure

```
azure-rg-lab/
├── README.md                          ← This lab manual
├── docs/
│   └── architecture-notes.md          ← Extended notes on design decisions
├── scripts/
│   ├── cli/
│   │   ├── 01-setup-variables.sh      ← All shell variable exports
│   │   ├── 02-create-resource-groups.sh
│   │   ├── 03-create-network.sh
│   │   ├── 04-create-vm.sh
│   │   ├── 05-create-storage.sh
│   │   ├── 06-create-sql.sh
│   │   ├── 07-configure-rbac.sh
│   │   ├── 08-verify-all.sh
│   │   └── 09-cleanup.sh
│   ├── arm-templates/
│   │   └── rg-3mmt labs-dev-backup.json ← Exported after Phase 9
│   └── terraform/                     ← Optional: Terraform equivalents
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── rbac/
│   └── role-assignments.md            ← RBAC documentation
├── policies/
│   └── require-tags-policy.json       ← Optional: Azure Policy definition
└── screenshots/
    ├── 01-resource-groups-list.png
    ├── 02-vnet-overview.png
    ├── 03-nsg-rules.png
    ├── 04-vm-overview.png
    ├── 05-vm-ssh-connection.png
    ├── 06-storage-account-overview.png
    ├── 07-sql-database-overview.png
    ├── 08-vm-tags.png
    ├── 09-rbac-iam-page.png
    ├── 10-verification-output.png
    ├── 11-rg-deletion-confirm.png
    └── 12-rg-deleted-list.png
```

---

## Quick Reference Card

```
┌──────────────────────────────────────────────────────────────────┐
│                    AZURE LAB QUICK REFERENCE                      │
├────────────────────────┬─────────────────────────────────────────┤
│ Login                  │ az login                                │
│ List subscriptions     │ az account list --output table          │
│ List resource groups   │ az group list --output table            │
│ List resources in RG   │ az resource list -g <RG> --output table │
│ Show VM status         │ az vm get-instance-view -g <RG> -n <VM> │
│ Start VM               │ az vm start -g <RG> -n <VM>             │
│ Stop VM (deallocate)   │ az vm deallocate -g <RG> -n <VM>        │
│ Delete resource group  │ az group delete -n <RG> --yes           │
│ List role assignments  │ az role assignment list --scope <ID>    │
│ Show tags on resource  │ az vm show -g <RG> -n <VM> --query tags │
└────────────────────────┴─────────────────────────────────────────┘
```

---

*End of Lab Manual — Azure Resource Organization and Resource Groups*  
*Author: Azure Lab Guide | Version: 1.0 | June 2026*
