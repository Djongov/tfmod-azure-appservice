variable "application" {
  type        = string
  description = "Name of the application"
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
  default     = null
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace id for the web apps"
  default     = null
}

variable "mysql" {
    type = object({
        name = optional(string)
        database_name = optional(string)
        sku = optional(string)
        version = optional(string)
        username = optional(string)
        password = optional(string)
        size = optional(number)
    })
}

variable "web_apps" {
  type = map(object(
    {
      https_only              = optional(bool)
      client_affinity_enabled = optional(bool)
      app_settings            = optional(map(string))
      site_config             = optional(map(string))
      identity = optional(object({
            type         = string
            identity_ids = list(string)
        }))
      custom_domain           = optional(string)
      ssl_certificate         = optional(string)
      ssl_service_managed_certificate = optional(bool)
      tags                    = optional(map(string))
      app_command_line        = optional(string)
  }))
  description = "Details for the Azure Web Apps"
}

