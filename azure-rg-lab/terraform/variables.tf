# =============================================================================
# variables.tf
# Input variables for the Azure Resource Organization Lab Terraform config
# =============================================================================

variable "company" {
  description = "Short company name used in resource naming (lowercase, no spaces)"
  type        = string
  default     = "3mmt-labs"
}

variable "project" {
  description = "Project name tag value"
  type        = string
  default     = "azure-rg-lab"
}

variable "owner" {
  description = "Owner tag value — email of the person responsible for these resources"
  type        = string
  default     = "samuel.m1804892@st.futminna.edu.ng"
}

variable "costcenter" {
  description = "Cost center tag value for billing allocation"
  type        = string
  default     = "CC-1001"
}

variable "department" {
  description = "Department tag value"
  type        = string
  default     = "IT-Engineering"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "admin_username" {
  description = "Admin username for the Linux VM"
  type        = string
  default     = "3mttadmin"
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key file"
  type        = string
  default     = "/home/samueleffiong/.ssh/id_azure.pub"
}

variable "admin_source_ip" {
  description = "Your public IP address, used to restrict NSG and SQL firewall rules"
  type        = string
  default     = "105.117.2.12/32"
}

# variable "sql_admin_username" {
#   description = "Admin username for the Azure SQL logical server"
#   type        = string
#   default     = "sqladmin"
# }

# variable "sql_admin_password" {
#   description = "Admin password for the Azure SQL logical server"
#   type        = string
#   sensitive   = true
# }

variable "admin_principal_object_id" {
  description = "Azure AD Object ID of the lab admin (Owner role on dev RG)"
  type        = string
  default     = "bda642a9-d065-466c-8e23-29f4b9745641"
}

variable "developer_principal_object_id" {
  description = "Azure AD Object ID of the developer (Contributor role on dev RG)"
  type        = string
  default     = "bda642a9-d065-466c-8e23-29f4b9745641"
}

variable "auditor_principal_object_id" {
  description = "Azure AD Object ID of the auditor (Reader role on prod RG)"
  type        = string
  default     = "bda642a9-d065-466c-8e23-29f4b9745641"
}
