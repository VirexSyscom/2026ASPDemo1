resource_group_name = "rg-hub-network-jpe"
location            = "Japan East"

hub_vnet_address_space = [
  "10.0.0.0/16"
]

bastion_subnet_prefixes = [
  "10.0.0.0/26"
]

gateway_subnet_prefixes = [
  "10.0.1.0/27"
]

# FortiGate WAN 介面的公用 IP
onprem_vpn_public_ip = "203.0.113.10"

# FortiGate 後方，需要透過 VPN 存取的地端網段
onprem_address_spaces = [
  "192.168.10.0/24",
  "192.168.20.0/24"
]

vpn_gateway_sku = "VpnGw2AZ"
bastion_sku     = "Basic"
enable_bgp      = false

# 暫時不建立 ToFortiVPN
create_vpn_connection = false

tags = {
  Environment = "Demo"
  ManagedBy   = "Terraform"
  Workload    = "Hub-Network"
  Region      = "Japan-East"
  Owner       = "Cloud-Team"
}
