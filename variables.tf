variable "application" {
  type        = string
  description = "Name of the application"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group"
}

variable "location" {
  type        = string
  description = "Location of the Azure Resource Group"
}

variable "appserviceplan" {
  type = object({
    #sku will be string and possible values are F1
    sku          = string
    os_type      = string
    worker_count = number
  })
  description = "Details for the Azure App Service Plan"
}

variable "key_vault" {
  type        = string
  description = "Key Vault name for the web apps"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace id for the web apps"
}

variable "web_apps" {
  type = map(object(
    {
      https_only              = optional(bool)
      client_affinity_enabled = optional(bool)
      app_settings            = optional(map(string))
      site_config             = optional(map(string))
      identity                = optional(map(string))
      custom_domain           = optional(string)
      ssl_certificate         = optional(string)
  }))
  description = "Details for the Azure Web Apps"
}

