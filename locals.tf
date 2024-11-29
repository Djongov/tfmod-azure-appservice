locals {
  basic_tags = {
    managed-by  = "terraform"
    application = lower(var.application)
  }
  workspace_name      = terraform.workspace
  appserviceplan_name = "${var.application}-asp"
  
  linux_web_apps_with_domains = flatten([
    for k, v in var.web_apps : [
      for domain, settings in (v["custom_domains"] != null ? v["custom_domains"] : {}) : {
        app_key                = k
        domain                 = domain
        key_vault_certificate  = lookup(settings, "key_vault_certificate", null)
      }
    ] if v["custom_domains"] != null && var.app_service_plan["os_type"] == "Linux"
  ])

  windows_web_apps_with_domains = flatten([
    for k, v in var.web_apps : [
      for domain, settings in (v["custom_domains"] != null ? v["custom_domains"] : {}) : {
        app_key                = k
        domain                 = domain
        key_vault_certificate  = lookup(settings, "key_vault_certificate", null)
      }
    ] if v["custom_domains"] != null && var.app_service_plan["os_type"] == "Windows"
  ])

# Filter for Linux web apps with managed certificates
  linux_web_apps_with_managed_certificates = flatten([
    for app_key, app_value in var.web_apps : [
      for domain, domain_settings in (app_value["custom_domains"] != null ? app_value["custom_domains"] : {}) :
      {
        app_key = app_key
        domain  = domain
        ssl_certificate = domain_settings
      }
      if (
        (domain_settings.app_service_managed_certificate == true && 
         domain_settings.key_vault_certificate == null) &&
        var.app_service_plan["os_type"] == "Linux"
      )
    ]
  ])

  # Filter for Windows web apps with managed certificates
  windows_web_apps_with_managed_certificates = flatten([
    for app_key, app_value in var.web_apps : [
      for domain, domain_settings in (app_value["custom_domains"] != null ? app_value["custom_domains"] : {}) :
      {
        app_key = app_key
        domain  = domain
        ssl_certificate = domain_settings
      }
      if (
        (domain_settings.app_service_managed_certificate == true && 
         domain_settings.key_vault_certificate == null) &&
        var.app_service_plan["os_type"] == "Windows"
      )
    ]
  ])

  # Filter for Linux web apps with key vault certificates with certificate_name not null
  linux_web_apps_with_key_vault_certificates = flatten([
    for app_key, app_value in var.web_apps : [
      for domain, domain_settings in (app_value["custom_domains"] != null ? app_value["custom_domains"] : {}) :
      {
        app_key = app_key
        domain  = domain
        ssl_certificate = domain_settings
      }
      if (
        (domain_settings.app_service_managed_certificate == null && 
         domain_settings.key_vault_certificate != null) &&
        var.app_service_plan["os_type"] == "Linux"
      )
    ]
  ])

  # Filter for Windows web apps with key vault certificates with certificate_name not null
    windows_web_apps_with_key_vault_certificates = flatten([
        for app_key, app_value in var.web_apps : [
        for domain, domain_settings in (app_value["custom_domains"] != null ? app_value["custom_domains"] : {}) :
        {
            app_key = app_key
            domain  = domain
            ssl_certificate = domain_settings
        }
        if (
            (domain_settings.app_service_managed_certificate == null && 
             domain_settings.key_vault_certificate != null) &&
            var.app_service_plan["os_type"] == "Windows"
        )
        ]
    ])
}