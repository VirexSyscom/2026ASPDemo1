resource_name_prefix = "demo"

location       = "japaneast"
location_short = "jpe"

resource_group_name   = "hub-network-rg"
create_resource_group = true

hub_vnet_address_space = [
  "10.0.0.0/16"
]

bastion_subnet_prefixes = [
  "10.0.0.0/26"
]

gateway_subnet_prefixes = [
  "10.0.1.0/27"
]

onprem_vpn_public_ip = "203.0.113.10"

onprem_address_spaces = [
  "192.168.10.0/24",
  "192.168.20.0/24"
]

vpn_gateway_sku = "VpnGw2AZ"
bastion_sku     = "Basic"
enable_bgp      = false

vpn_gateway_public_ip_zones = [
  "1",
  "2",
  "3"
]

create_vpn_connection = false

tags = {
  Environment = "Demo"
  ManagedBy   = "Terraform"
  Workload    = "Hub-Network"
  Owner       = "Cloud-Team"
  CostCenter  = "IT"
  Project     = "Hub-Network"
}
