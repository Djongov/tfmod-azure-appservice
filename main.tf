# In main.tf of tfmod-azure-appservice module
locals {
  basic_tags = {
    managed-by  = "terraform"
    application = lower(var.application)
  }
  workspace_name      = terraform.workspace
  appserviceplan_name = "${var.application}-asp"
}


resource "azurerm_resource_group" "rg" {
  name     = "${var.application}-${local.workspace_name}"
  location = var.location
  tags     = local.basic_tags
}


resource "azurerm_service_plan" "main" {
  name                = local.appserviceplan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = var.appserviceplan["os_type"]
  sku_name            = var.appserviceplan["sku"]
  tags = merge(local.basic_tags, { "environment" = local.workspace_name })
  depends_on          = [azurerm_resource_group.rg]
  worker_count        = var.appserviceplan["worker_count"]
}

resource "azurerm_linux_web_app" "linux_web_app" {
  for_each                = { for k, v in var.web_apps : k => v if var.appserviceplan["os_type"] == "Linux" }
  name                    = "${var.application}-${each.key}"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  service_plan_id         = azurerm_service_plan.main.id
  client_affinity_enabled = each.value["client_affinity_enabled"]
  https_only              = each.value["https_only"]
  app_settings            = each.value["app_settings"]
  #client_certificate_mode = each.value["client_certificate_mode"]

  site_config {
    always_on             = lookup(each.value["site_config"], "always_on", null)
    ftps_state            = lookup(each.value["site_config"], "ftps_state", null)
    managed_pipeline_mode = lookup(each.value["site_config"], "managed_pipeline_mode", null)
    health_check_path     = lookup(each.value["site_config"], "health_check_path", null)
    http2_enabled         = lookup(each.value["site_config"], "http2_enabled", null)
    minimum_tls_version   = lookup(each.value["site_config"], "minimum_tls_version", null)
    use_32_bit_worker     = lookup(each.value["site_config"], "use_32_bit_worker", null)
    app_command_line      = lookup(each.value["site_config"], "app_command_line", null)
    container_registry_use_managed_identity = lookup(each.value["site_config"], "container_registry_use_managed_identity", null)
    application_stack {
      php_version = lookup(each.value["site_config"], "php_version", null)
      java_version = lookup(each.value["site_config"], "java_version", null)
      node_version = lookup(each.value["site_config"], "node_version", null)
      docker_image_name = lookup(each.value["site_config"], "docker_image_name", null)
      docker_registry_url = lookup(each.value["site_config"], "docker_registry_url", null)
    }
  }
  logs {
    detailed_error_messages = false
    failed_request_tracing  = false

    application_logs {
      file_system_level = "Warning"
    }

    http_logs {
      file_system {
        retention_in_days = 10
        retention_in_mb   = 35
      }
    }
  }
  dynamic "identity" {
    for_each = each.value["identity"] != null ? [1] : []
    content {
      type = each.value["identity"]["type"]
    }
  }
  tags = merge(local.basic_tags, { "environment" = local.workspace_name }, each.value["tags"])
  depends_on = [azurerm_service_plan.main]
}

resource "azurerm_windows_web_app" "windows_web_app" {
  for_each                = { for k, v in var.web_apps : k => v if var.appserviceplan["os_type"] == "Windows" }
  name                    = "${var.application}-${each.key}"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  service_plan_id         = azurerm_service_plan.main.id
  client_affinity_enabled = each.value["client_affinity_enabled"]
  #client_certificate_mode = each.value["client_certificate_mode"]
  https_only   = each.value["https_only"]
  app_settings = each.value["app_settings"]

  site_config {
    always_on             = lookup(each.value["site_config"], "always_on", null)
    ftps_state            = lookup(each.value["site_config"], "ftps_state", null)
    managed_pipeline_mode = lookup(each.value["site_config"], "managed_pipeline_mode", null)
    health_check_path     = lookup(each.value["site_config"], "health_check_path", null)
    http2_enabled         = lookup(each.value["site_config"], "http2_enabled", null)
    minimum_tls_version   = lookup(each.value["site_config"], "minimum_tls_version", null)
    use_32_bit_worker     = lookup(each.value["site_config"], "use_32_bit_worker", null)
    app_command_line      = lookup(each.value["site_config"], "app_command_line", null)
    container_registry_use_managed_identity = lookup(each.value["site_config"], "container_registry_use_managed_identity", null)
    application_stack {
      php_version = lookup(each.value["site_config"], "php_version", null)
      java_version = lookup(each.value["site_config"], "java_version", null)
      node_version = lookup(each.value["site_config"], "node_version", null)
      docker_image_name = lookup(each.value["site_config"], "docker_image_name", null)
      docker_registry_url = lookup(each.value["site_config"], "docker_registry_url", null)
    }
  }

  logs {
    detailed_error_messages = false
    failed_request_tracing  = false

    application_logs {
      file_system_level = "Warning"
    }

    http_logs {
      file_system {
        retention_in_days = 10
        retention_in_mb   = 35
      }
    }
  }
  dynamic "identity" {
    for_each = each.value["identity"] != null ? [1] : []
    content {
      type = each.value["identity"]["type"]
    }
  }
  tags = merge(local.basic_tags, { "environment" = local.workspace_name }, each.value["tags"])
  depends_on = [azurerm_service_plan.main]
}

resource "azurerm_app_service_custom_hostname_binding" "linux_webapp" {
  for_each            = { for k, v in var.web_apps : k => v if v["custom_domain"] != null && var.appserviceplan["os_type"] == "Linux" }
  hostname            = each.value["custom_domain"]
  resource_group_name = azurerm_resource_group.rg.name
  app_service_name    = azurerm_linux_web_app.linux_web_app[each.key].name
}

resource "azurerm_app_service_custom_hostname_binding" "windows_webapp" {
  for_each            = { for k, v in var.web_apps : k => v if v["custom_domain"] != null && var.appserviceplan["os_type"] == "Windows" }
  hostname            = each.value["custom_domain"]
  resource_group_name = azurerm_resource_group.rg.name
  app_service_name    = azurerm_windows_web_app.windows_web_app[each.key].name
}

# ================================================================ App Service Managed SSL ================================================================

# For Linux
resource "azurerm_app_service_managed_certificate" "linux_webapp" {
  for_each = { for k, v in var.web_apps : k => v if var.appserviceplan["os_type"] == "Linux" && v.ssl_service_managed_certificate != null }

  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.linux_webapp[each.key].id
}

# For Windows
resource "azurerm_app_service_managed_certificate" "windows_webapp" {
  for_each = { for k, v in var.web_apps : k => v if var.appserviceplan["os_type"] == "Windows" && v.ssl_service_managed_certificate != null }

  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.windows_webapp[each.key].id
}

# For Linux
resource "azurerm_app_service_certificate_binding" "linux_webapp" {
  for_each = { for k, v in var.web_apps : k => v if var.appserviceplan["os_type"] == "Linux" && v.ssl_service_managed_certificate != null }

  hostname_binding_id = azurerm_app_service_custom_hostname_binding.linux_webapp[each.key].id
  certificate_id      = azurerm_app_service_managed_certificate.linux_webapp[each.key].id
  ssl_state           = "SniEnabled"
}

# For Windows
resource "azurerm_app_service_certificate_binding" "windows_webapp" {
  for_each = { for k, v in var.web_apps : k => v if var.appserviceplan["os_type"] == "Windows" && v.ssl_service_managed_certificate != null }

  hostname_binding_id = azurerm_app_service_custom_hostname_binding.windows_webapp[each.key].id
  certificate_id      = azurerm_app_service_managed_certificate.windows_webapp[each.key].id
  ssl_state           = "SniEnabled"
}

# Key Vault Certificate only if key_vault_provider and ssl_certificate is passed
# data "azurerm_key_vault_secret" "certificate" {
#   for_each     = { for k, v in var.web_apps : k => v if v["ssl_certificate"] != null }
#   name         = each.value["ssl_certificate"]
#   key_vault_id = var.key_vault
# }


# # Key Vault Access for Linux Apps
# resource "azurerm_role_assignment" "assign-access-to-key-vault-linux" {
# for_each            = { for k, v in var.web_apps : k => v if v["custom_domain"] != null && var.appserviceplan["os_type"] == "Linux" }
#   principal_id         = azurerm_linux_web_app.linux_web_app[each.key].identity[0].principal_id
#   role_definition_name    = "Key Vault Certificates Officer"
#   scope                   = var.key_vault
# }

# # Key Vault Access for Windows Apps
# resource "azurerm_role_assignment" "assign-access-to-key-vault-windows" {
# for_each            = { for k, v in var.web_apps : k => v if v["custom_domain"] != null && var.appserviceplan["os_type"] == "Windows" }
#   principal_id         = azurerm_windows_web_app.windows_web_app[each.key].identity[0].principal_id
#   role_definition_name    = "Key Vault Certificates Officer"
#   scope                   = var.key_vault
# }

# # Web app Certificate from Key Vault
# resource "azurerm_app_service_certificate" "certificate" {
#   for_each            = { for k, v in var.web_apps : k => v if v["ssl_certificate"] != null }
#   name                = "webapp-certificate"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   pfx_blob            = data.azurerm_key_vault_secret.certificate[each.key].value
# }

# # SSL binding for Linux Web Apps
# resource "azurerm_app_service_certificate_binding" "linux-binding" {
#   #for each web app that has custom domain
#   for_each            = { for k, v in var.web_apps : k => v if v["custom_domain"] != null && var.appserviceplan["os_type"] == "Linux" }
#   hostname_binding_id = azurerm_app_service_custom_hostname_binding.linux_webapp[each.key].id
#   certificate_id      = azurerm_app_service_certificate.certificate[each.key].id
#   ssl_state           = "SniEnabled"
#   depends_on = [azurerm_role_assignment.assign-access-to-key-vault-linux]
# }
# # SSL binding for Windows Web Apps
# resource "azurerm_app_service_certificate_binding" "windows-binding" {
#   #for each web app that has custom domain
#   for_each            = { for k, v in var.web_apps : k => v if v["custom_domain"] != null && var.appserviceplan["os_type"] == "Windows" }
#   hostname_binding_id = azurerm_app_service_custom_hostname_binding.windows_webapp[each.key].id
#   certificate_id      = azurerm_app_service_certificate.certificate[each.key].id
#   ssl_state           = "SniEnabled"
#     depends_on = [azurerm_role_assignment.assign-access-to-key-vault-windows]
# }

# Linux Web App Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "linux_webapp" {
  for_each            = { for k, v in var.web_apps : k => v if var.appserviceplan["os_type"] == "Linux" && var.log_analytics_workspace_id != null }
  name                = "${var.application}-${each.key}-diagnostic-settings"
  target_resource_id  = azurerm_linux_web_app.linux_web_app[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log {
    category = "AppServiceHTTPLogs"
  }
  enabled_log {
    category = "AppServiceConsoleLogs"
  }
  enabled_log {
    category = "AppServiceAppLogs"
  }
  enabled_log {
    category = "AppServiceAuditLogs"
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Windows Web App Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "windows_webapp" {
  for_each            = { for k, v in var.web_apps : k => v if var.appserviceplan["os_type"] == "Windows" && var.log_analytics_workspace_id != null }
  name                = "${var.application}-${each.key}-diagnostic-settings"
  target_resource_id  = azurerm_windows_web_app.windows_web_app[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log {
    category = "AppServiceHTTPLogs"
  }
  enabled_log {
    category = "AppServiceConsoleLogs"
  }
  enabled_log {
    category = "AppServiceAppLogs"
  }
  enabled_log {
    category = "AppServiceAuditLogs"
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}


# resource "azurerm_key_vault_access_policy" "webapp_access_policy" {
#   key_vault_id = data.azurerm_key_vault.sunwell.id

#   tenant_id = data.azurerm_client_config.current.tenant_id
#   object_id = azurerm_linux_web_app.azure-waf-manager.identity[0].principal_id

#   secret_permissions      = ["Get"]
#   certificate_permissions = ["Get"]
# }


# # MySQL Server
resource "azurerm_mysql_flexible_server" "sunwell-mysql" {
# only create the server if mysql is passed
    count               = var.mysql.name != null ? 1 : 0
  name                = var.mysql.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  administrator_login          = var.mysql.username
  administrator_password       = var.mysql.password

  sku_name   = var.mysql.sku

  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  version     = var.mysql.version
  zone = 1
  storage {
    auto_grow_enabled = false
    size_gb = var.mysql.size
  }
}

resource "azurerm_mysql_flexible_server_firewall_rule" "home" {
  name                = "Home"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.sunwell-mysql[0].name
  start_ip_address    = "92.247.57.179"
  end_ip_address      = "92.247.57.179"
}

# resource "azurerm_mysql_flexible_server_firewall_rule" "puzl" {
#   name                = "Puzl"
#   resource_group_name = azurerm_resource_group.rg.name
#   server_name         = azurerm_mysql_flexible_server.sunwell-mysql.name
#   start_ip_address    = "87.120.134.0"
#   end_ip_address      = "87.120.134.254"
# }

# resource "azurerm_mysql_flexible_server_firewall_rule" "uefa-vpn" {
#   name                = "Uefa_VPN"
#   resource_group_name = azurerm_resource_group.rg.name
#   server_name         = azurerm_mysql_flexible_server.sunwell-mysql.name
#   start_ip_address    = "46.140.144.6"
#   end_ip_address      = "46.140.144.11"
# }

# resource "azurerm_mysql_flexible_server_firewall_rule" "pancharevo" {
#   name                = "Pancharevo"
#   resource_group_name = azurerm_resource_group.rg.name
#   server_name         = azurerm_mysql_flexible_server.sunwell-mysql.name
#   start_ip_address    = "78.128.48.155"
#   end_ip_address      = "78.128.48.155"
# }

resource "azurerm_mysql_flexible_database" "azure-waf-manager" {
    #only create the database if mysql is passed
    count               = var.mysql.database_name != null ? 1 : 0
  name                = var.mysql.database_name
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.sunwell-mysql[0].name
  charset             = "utf8mb4"
  collation           = "utf8mb4_0900_ai_ci"
  # prevent the possibility of accidental data loss
#   lifecycle {
#     prevent_destroy = true
#   }
}
