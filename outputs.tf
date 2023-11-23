output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

# output "outbound_ip_addresses" {
#   value = {
#     for app_key, value in var.web_apps : app_key => value["appserviceplan"]["os_type"] == "Linux" ? azurerm_linux_web_app.linux_web_app[app_key].outbound_ip_addresses : azurerm_windows_web_app.windows_web_app[app_key].outbound_ip_addresses
#   }
# }

# output "possible_outbound_ip_addresses" {
#   value = {
#     for app_key, value in var.web_apps : app_key => value["appserviceplan"]["os_type"] == "Linux" ? azurerm_linux_web_app.linux_web_app[app_key].possible_outbound_ip_addresses : azurerm_windows_web_app.windows_web_app[app_key].possible_outbound_ip_addresses
#   }
# }
