# =============================================================================
# main.tf
# Azure Resource Organization Lab — Terraform equivalent of the CLI scripts
# Optional: use this instead of, or alongside, the Azure CLI scripts
# =============================================================================

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# ── Common tags applied to every resource ──────────────────────────────────
locals {
  common_tags = {
    environment = "dev"
    owner       = var.owner
    project     = var.project
    costcenter  = var.costcenter
    department  = var.department
  }
}

# ── Resource Groups ──────────────────────────────────────────────────────
resource "azurerm_resource_group" "dev" {
  name     = "rg-${var.company}-dev"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "prod" {
  name     = "rg-${var.company}-prod"
  location = var.location
  tags     = merge(local.common_tags, { environment = "prod" })
}

# ── Virtual Network and Subnet ──────────────────────────────────────────
resource "azurerm_virtual_network" "dev" {
  name                = "vnet-${var.company}-dev-001"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "dev" {
  name                 = "snet-dev-001"
  resource_group_name  = azurerm_resource_group.dev.name
  virtual_network_name = azurerm_virtual_network.dev.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ── Network Security Group ──────────────────────────────────────────────
resource "azurerm_network_security_group" "dev" {
  name                = "nsg-${var.company}-dev-001"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  tags                = local.common_tags

  security_rule {
    name                       = "Allow-SSH-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_source_ip
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "dev" {
  subnet_id                 = azurerm_subnet.dev.id
  network_security_group_id = azurerm_network_security_group.dev.id
}

# ── Public IP and NIC ───────────────────────────────────────────────────
resource "azurerm_public_ip" "dev" {
  name                = "pip-${var.company}-dev-001"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "dev" {
  name                = "nic-${var.company}-dev-001"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dev.id
  }

  tags = local.common_tags
}

# ------------SSH KEYS-----------------
resource "azurerm_ssh_public_key" "dev" {
  name                = "mySshKey"
  resource_group_name = azurerm_resource_group.dev.name
  location            = azurerm_resource_group.dev.location

  public_key = file(var.ssh_public_key_path)

  tags = local.common_tags
}

resource "azurerm_ssh_public_key" "prod" {
  name                = "mySshKey-prod"
  resource_group_name = azurerm_resource_group.prod.name
  location            = azurerm_resource_group.prod.location

  public_key = file(var.ssh_public_key_path)

  tags = merge(
    local.common_tags,
    {
      environment = "prod"
    }
  )
}

# ── Linux Virtual Machine ───────────────────────────────────────────────
resource "azurerm_linux_virtual_machine" "dev" {
  name                = "vm-${var.company}-dev-001"
  resource_group_name = azurerm_resource_group.dev.name
  location            = azurerm_resource_group.dev.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.dev.id,
  ]

  # default:
  # admin_ssh_key {
  #   username   = var.admin_username
  #   public_key = file(var.ssh_public_key_path)
  # }

  admin_ssh_key {
    username   = var.admin_username
    public_key = azurerm_ssh_public_key.dev.public_key
  }

  depends_on = [
    azurerm_ssh_public_key.dev
  ]
  # FOR PROUD LATER

  # admin_ssh_key {
  # username   = var.admin_username
  # public_key = azurerm_ssh_public_key.prod.public_key
  # }

  os_disk {
    name                 = "osdisk-vm-${var.company}-dev-001"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = local.common_tags
}

# resource "azurerm_linux_virtual_machine" "dev" {
#   ...

#   depends_on = [
#     azurerm_ssh_public_key.dev
#   ]
# }

# ── Storage Account ─────────────────────────────────────────────────────
resource "azurerm_storage_account" "dev" {
  name                            = "st3mmtlabsdev001"
  resource_group_name             = azurerm_resource_group.dev.name
  location                        = azurerm_resource_group.dev.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_storage_container" "dev" {
  name = "dev-container"
  # storage_account_name  = azurerm_storage_account.dev.name
  storage_account_id    = azurerm_storage_account.dev.id
  container_access_type = "private"
}

# ── Azure SQL Server and Database (Serverless) ─────────────────────────
# resource "azurerm_mssql_server" "dev" {
#   name                         = "sql-${var.company}-dev-001"
#   resource_group_name          = azurerm_resource_group.dev.name
#   location                     = azurerm_resource_group.dev.location
#   version                      = "12.0"
#   administrator_login          = var.sql_admin_username
#   administrator_login_password = var.sql_admin_password
#   tags                          = local.common_tags
# }

# resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
#   name             = "AllowAzureServices"
#   server_id        = azurerm_mssql_server.dev.id
#   start_ip_address = "0.0.0.0"
#   end_ip_address   = "0.0.0.0"
# }

# resource "azurerm_mssql_firewall_rule" "allow_my_ip" {
#   name             = "AllowMyIP"
#   server_id        = azurerm_mssql_server.dev.id
#   start_ip_address = var.admin_source_ip
#   end_ip_address   = var.admin_source_ip
# }

# resource "azurerm_mssql_database" "dev" {
#   name           = "sqldb-${var.company}-dev-001"
#   server_id      = azurerm_mssql_server.dev.id
#   sku_name       = "GP_S_Gen5_1"
#   min_capacity   = 0.5
#   auto_pause_delay_in_minutes = 60
#   tags           = local.common_tags
# }

# ── RBAC Role Assignments ───────────────────────────────────────────────
resource "azurerm_role_assignment" "owner_dev" {
  scope                = azurerm_resource_group.dev.id
  role_definition_name = "Owner"
  principal_id         = var.admin_principal_object_id
}

resource "azurerm_role_assignment" "contributor_dev" {
  scope                = azurerm_resource_group.dev.id
  role_definition_name = "Contributor"
  principal_id         = var.developer_principal_object_id
}

resource "azurerm_role_assignment" "reader_prod" {
  scope                = azurerm_resource_group.prod.id
  role_definition_name = "Reader"
  principal_id         = var.auditor_principal_object_id
}
