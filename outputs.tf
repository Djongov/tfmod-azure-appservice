output "linux_web_apps_with_managed_certificates" {
  value = local.linux_web_apps_with_managed_certificates
}

output "windows_web_apps_with_managed_certificates" {
  value = local.windows_web_apps_with_managed_certificates
}

output "custom_domains" {
  value = [for app in var.web_apps : app.custom_domains]
}

output "linux_web_apps_with_key_vault_certificates" {
  value = local.linux_web_apps_with_key_vault_certificates
}

