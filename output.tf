output "resource_group_name" {
  description = "Resource Group name"
  value       = azurerm_resource_group.hub.name
}

output "hub_vnet_id" {
  description = "Hub-VNET resource ID"
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  description = "Hub-VNET name"
  value       = azurerm_virtual_network.hub.name
}

output "bastion_host_id" {
  description = "Azure Bastion resource ID"
  value       = azurerm_bastion_host.hub.id
}

output "bastion_public_ip" {
  description = "Azure Bastion public IP address"
  value       = azurerm_public_ip.bastion.ip_address
}

output "vpn_gateway_id" {
  description = "Virtual Network Gateway resource ID"
  value       = azurerm_virtual_network_gateway.vpn.id
}

output "vpn_gateway_public_ip" {
  description = "VPN Gateway public IP address"
  value       = azurerm_public_ip.vpn_gateway.ip_address
}

output "local_network_gateway_id" {
  description = "Local Network Gateway resource ID"
  value       = azurerm_local_network_gateway.fortigate.id
}

output "vpn_connection_id" {
  description = "Site-to-Site VPN Connection resource ID"
  value = try(
    azurerm_virtual_network_gateway_connection.fortigate[0].id,
    null
  )
}

output "vpn_connection_name" {
  description = "Site-to-Site VPN Connection name"
  value = try(
    azurerm_virtual_network_gateway_connection.fortigate[0].name,
    null
  )
}

output "vpn_connection_created" {
  description = "是否已建立 Site-to-Site VPN Connection"
  value       = var.create_vpn_connection
}
