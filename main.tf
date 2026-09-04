# ------------------------------------------------------------
# Resource Group
# 此資源不在原始圖片中，但所有圖片內資源都必須隸屬於 Resource Group。
# ------------------------------------------------------------

resource "azurerm_resource_group" "hub" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ------------------------------------------------------------
# 1. Hub-VNET
# ------------------------------------------------------------

resource "azurerm_virtual_network" "hub" {
  name                = "Hub-VNET"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = var.hub_vnet_address_space

  tags = var.tags
}

# ------------------------------------------------------------
# Azure Bastion 必要子網路
# 名稱必須使用 AzureBastionSubnet
# ------------------------------------------------------------

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.bastion_subnet_prefixes
}

# ------------------------------------------------------------
# VPN Gateway 必要子網路
# 名稱必須使用 GatewaySubnet
# ------------------------------------------------------------

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.gateway_subnet_prefixes
}

# ------------------------------------------------------------
# 3. hub-vnet-bastion-IPaddress
# Bastion Basic 使用 Standard、Static Public IP。
# ------------------------------------------------------------

resource "azurerm_public_ip" "bastion" {
  name                = "hub-vnet-bastion-IPaddress"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  allocation_method = "Static"
  sku               = "Standard"
  ip_version        = "IPv4"

  tags = var.tags
}

# ------------------------------------------------------------
# 2. Hub-VNET-Bastion
# ------------------------------------------------------------

resource "azurerm_bastion_host" "hub" {
  name                = "Hub-VNET-Bastion"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = var.bastion_sku

  ip_configuration {
    name                 = "bastion-ip-configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = var.tags
}

# ------------------------------------------------------------
# 7. VPNGateway-IPaddress
# ------------------------------------------------------------

resource "azurerm_public_ip" "vpn_gateway" {
  name                = "VPNGateway-IPaddress"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  allocation_method = "Static"
  sku               = "Standard"
  ip_version        = "IPv4"

  tags = var.tags
}

# ------------------------------------------------------------
# 6. VPNGateway
# 傳統 VNet-based Virtual Network Gateway
# ------------------------------------------------------------

resource "azurerm_virtual_network_gateway" "vpn" {
  name                = "VPNGateway"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  type          = "Vpn"
  vpn_type      = "RouteBased"
  active_active = false
  enable_bgp    = var.enable_bgp
  sku           = var.vpn_gateway_sku
  generation    = "Generation2"

  ip_configuration {
    name                          = "vpn-gateway-ip-configuration"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }

  tags = var.tags
}

# ------------------------------------------------------------
# 4. LocalGateway
# 代表地端 FortiGate 與地端網段
# ------------------------------------------------------------

resource "azurerm_local_network_gateway" "fortigate" {
  name                = "LocalGateway"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  gateway_address = var.onprem_vpn_public_ip
  address_space   = var.onprem_address_spaces

  tags = var.tags
}

# ------------------------------------------------------------
# 5. ToFortiVPN
# Azure VPN Gateway 至地端 FortiGate 的 S2S IPsec Connection
# ------------------------------------------------------------

resource "azurerm_virtual_network_gateway_connection" "fortigate" {
  count = var.create_vpn_connection ? 1 : 0

  name                = "ToFortiVPN"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  type = "IPsec"

  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.fortigate.id

  shared_key = var.vpn_shared_key

  enable_bgp = var.enable_bgp

  # 若 FortiGate 有指定 IKE/IPsec Proposal，可取消下面區塊註解，
  # 並依 FortiGate Phase 1 / Phase 2 設定調整。
  #
  # ipsec_policy {
  #   dh_group         = "DHGroup14"
  #   ike_encryption   = "AES256"
  #   ike_integrity    = "SHA256"
  #   ipsec_encryption = "AES256"
  #   ipsec_integrity  = "SHA256"
  #   pfs_group        = "PFS14"
  #   sa_datasize      = 102400000
  #   sa_lifetime      = 27000
  # }

  tags = var.tags
}
