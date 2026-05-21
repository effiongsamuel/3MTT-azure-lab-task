# 3MTT Azure Lab Task

This repository contains Azure fundamentals lab work and ARM template-based VM deployment exercises for the 3MTT program.

## 📁 Project Structure

```
3MTT-azure-lab-task/
├── azure/
│   ├── Readme.md                    # Azure fundamentals lab report
│   ├── dashboard.png                # Azure Portal dashboard screenshot
│   ├── resource-group.png           # Resource group overview
│   ├── resource-group1.png          # Resource group details
│   └── cost-management.png          # Cost management dashboard
│
├── azure-arm-vm-deployment/
│   ├── README.md                    # ARM template deployment guide
│   ├── templates/
│   │   ├── azuredeploy.json         # ARM template for VM and networking
│   │   └── azuredeploy.parameters.json  # Parameter values for deployment
│   ├── screenshots/
│   │   ├── deployment-success.png
│   │   ├── resource-group.png
│   │   ├── vm-running.png
│   │   └── ssh-connection.png
│   ├── logs/
│   │   └── deployment-output.txt    # Deployment output logs
│   └── .gitignore

├── cloude pricing/
│   ├── README.md                    # Cloud cost comparison and CSVs
│   ├── aws_estimate.csv
│   ├── azure_estimate.csv
│   ├── comparison_estimates.csv
│   ├── savings_1yr.csv
│   ├── savings_3yr.csv
│   └── screenshots/
│       └── (charts and diagrams)

├── README.md                        # This file
└── LICENSE
```

## 📚 Folder Descriptions

### 1. `azure/` - Azure Fundamentals Lab

**Purpose:** Documents the foundational Azure setup and understanding of Azure services.

**Contents:**
- Subscription overview and account setup
- Resource group creation in South Africa North region
- Azure cost management and billing configuration
- Shared responsibility model documentation
- Screenshots of Azure Portal features

**Read more:** See [azure/Readme.md](azure/Readme.md)

---

### 2. `azure-arm-vm-deployment/` - ARM Template Deployment

**Purpose:** Provides a complete Infrastructure-as-Code (IaC) solution for deploying a Linux VM with networking resources using Azure Resource Manager templates.

**Includes:**
- **ARM Template** (`templates/azuredeploy.json`)
  - Virtual Network with Subnet
  - Network Security Group (SSH enabled)
  - Public IP Address
  - Network Interface
  - Ubuntu 24.04 LTS Virtual Machine
  - SSH public key authentication

- **Parameters File** (`templates/azuredeploy.parameters.json`)
  - Customizable deployment values
  - Admin username: `effiongsamuel-3mtt-dario-lab`
  - SSH public key authentication support

- **Azure CLI Deployment Commands**
  - Validate template syntax
  - Create resource group
  - Deploy resources
  - Verify deployment and connect via SSH

- **Documentation & Logs**
  - Step-by-step deployment guide
  - SSH access instructions
  - Troubleshooting tips
  - Deployment output logs

**Read more:** See [azure-arm-vm-deployment/README.md](azure-arm-vm-deployment/README.md)

---

### 3. `cloude pricing/` - Cloud Cost Comparison

**Purpose:** Cost modelling and comparison between AWS and Azure for the Phase 1 SaaS workload.

**Contents:**
- CSV exports of pricing estimates (`aws_estimate.csv`, `azure_estimate.csv`, `comparison_estimates.csv`)
- Modeled savings files (`savings_1yr.csv`, `savings_3yr.csv`)
- Generated charts and screenshots in `screenshots/`
- Phase documents: `PHASE2_AWS.md`, `PHASE3_AZURE.md`, `PHASE4_NETWORKING.md`, `PHASE5_DISCOUNTS.md`, `PHASE6_COMPARISON.md`

**Read more:** See [cloude pricing/README.md](cloude%20pricing/README.md)


## 🚀 Quick Start

### Prerequisites
- Azure CLI installed (`az` command)
- Azure account with active subscription
- SSH key pair (or use password authentication)

### Basic Deployment Steps

```bash
# Login to Azure
az login

# Create resource group
az group create \
  --name 3mtt-azure-lab \
  --location southafricanorth

# Validate template
az deployment group validate \
  --resource-group 3mtt-azure-lab \
  --template-file azure-arm-vm-deployment/templates/azuredeploy.json \
  --parameters @azure-arm-vm-deployment/templates/azuredeploy.parameters.json

# Deploy the resources
az deployment group create \
  --resource-group 3mtt-azure-lab \
  --template-file azure-arm-vm-deployment/templates/azuredeploy.json \
  --parameters @azure-arm-vm-deployment/templates/azuredeploy.parameters.json
```

For detailed deployment instructions, see [azure-arm-vm-deployment/README.md](azure-arm-vm-deployment/README.md)

---

## 🔐 Security Considerations

- **SSH Public Key:** Update the `adminPublicKey` parameter with your actual public key before deployment
- **Parameter File:** Keep sensitive parameters in a private parameters file (not committed to VCS)
- **NSG Rules:** SSH (port 22) is allowed by default; restrict source IPs for production use
- **Password Authentication:** Disabled; only SSH key authentication is supported

---

## 📝 Key Learnings

1. **Azure Fundamentals** - Subscription, resource groups, regions, cost management
2. **Infrastructure-as-Code** - ARM templates for repeatable deployments
3. **Networking** - VNets, subnets, NSGs, public IPs
4. **Secure Access** - SSH key-based authentication for Linux VMs
5. **Azure CLI** - Command-line deployment and resource management

---

## 📖 Resources

- [Azure Documentation](https://learn.microsoft.com/azure/)
- [ARM Template Reference](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/)
- [Azure CLI Reference](https://learn.microsoft.com/cli/azure/)

---

## 👤 Author

**Samuel Effiong** - 3MTT Azure Lab Task

---

## 📄 License

See [LICENSE](LICENSE) file for details.
