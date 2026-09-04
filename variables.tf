variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
  default     = "rg-hub-network-jpe"
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "Japan East"
}

variable "hub_vnet_address_space" {
  description = "Address space of Hub-VNET"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "bastion_subnet_prefixes" {
  description = "CIDR for AzureBastionSubnet"
  type        = list(string)
  default     = ["10.0.0.0/26"]
}

variable "gateway_subnet_prefixes" {
  description = "CIDR for GatewaySubnet"
  type        = list(string)
  default     = ["10.0.1.0/27"]
}

variable "onprem_vpn_public_ip" {
  description = "Public IP address of the on-premises FortiGate"
  type        = string

  validation {
    condition     = can(cidrhost("${var.onprem_vpn_public_ip}/32", 0))
    error_message = "onprem_vpn_public_ip 必須是有效的 IPv4 位址。"
  }
}

variable "onprem_address_spaces" {
  description = "On-premises networks behind the FortiGate"
  type        = list(string)
  default     = ["192.168.0.0/16"]
}


variable "vpn_gateway_sku" {
  description = "Azure VPN Gateway SKU"
  type        = string
  default     = "VpnGw2AZ"

  validation {
    condition = contains([
      "Basic",
      "VpnGw1",
      "VpnGw2",
      "VpnGw3",
      "VpnGw4",
      "VpnGw5",
      "VpnGw1AZ",
      "VpnGw2AZ",
      "VpnGw3AZ",
      "VpnGw4AZ",
      "VpnGw5AZ"
    ], var.vpn_gateway_sku)

    error_message = "請指定有效的 VPN Gateway SKU。"
  }
}


variable "create_vpn_connection" {
  description = "是否建立 Site-to-Site VPN Connection"
  type        = bool
  default     = false
}

variable "vpn_shared_key" {
  description = "IPsec Pre-Shared Key。只有建立 VPN Connection 時才需要。"
  type        = string
  sensitive   = true
  default     = null

  validation {
    condition = (
      var.create_vpn_connection == false ||
      (
        var.vpn_shared_key != null &&
        length(trimspace(var.vpn_shared_key)) > 0
      )
    )

    error_message = "create_vpn_connection 為 true 時，必須提供非空白的 vpn_shared_key。"
  }
}


variable "bastion_sku" {
  description = "Azure Bastion SKU"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.bastion_sku)
    error_message = "bastion_sku 必須是 Basic、Standard 或 Premium。"
  }
}

variable "enable_bgp" {
  description = "Enable BGP on Azure VPN Gateway"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)

  default = {
    Environment = "Demo"
    ManagedBy   = "Terraform"
    Workload    = "Hub-Network"
    Region      = "Japan-East"
  }
}

