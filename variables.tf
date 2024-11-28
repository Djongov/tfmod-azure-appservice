variable "application" {
  type        = string
  description = "Name of the application"
}

variable "location" {
  type        = string
  description = "Location of the Azure Resource Group"
}

variable "app_service_plan" {
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
variable "environment" {
  type        = string
  description = "Environment for the web apps"
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
  type = map(
    object(
      {
        app_settings = map(string)
        key_vault_secret_access = optional(object({
          provider = string
          key_vault_id = string
        }))
        custom_domains = optional(map(object({
          key_vault_certificate = optional(object({
            certificate_name = optional(string)
            key_vault_id      = optional(string)
            secret_name = optional(string)
          }))
          app_service_managed_certificate = optional(bool)
        })))
        enabled = optional(bool)
        https_only = optional(bool)
        site_config = object({
          worker_count = optional(number)
          always_on = optional(bool)
          ftps_state = optional(string)
          http2_enabled = optional(bool)
          health_check_path = optional(string)
          use_32_bit_worker_process = optional(bool)
          websockets_enabled = optional(bool)
          container_registry_use_managed_identity = optional(bool)
          cors = optional(object({
            allowed_origins = list(string)
            support_credentials = optional(bool)
          }))
        })
        identity = optional(object({
            type         = string
            identity_ids = optional(list(string))
        }))
        application_stack = object({
          php_version        = optional(string)
          java_version       = optional(string)
          node_version       = optional(string)
          python_version     = optional(string)
          dotnet_version     = optional(string)
          ruby_version       = optional(string)
          # Now some images
          docker_image_name  = optional(string)
          docker_registry_url = optional(string)
          docker_image       = optional(string)
          docker_image_tag   = optional(string)
          # java server
          
        })
        logs = optional(object(
          {
            detailed_error_messages = optional(bool)
            failed_request_tracing = optional(bool)
            file_system_retention_days = optional(number)
            file_system_retention_mb = optional(number)
          }
        ))
        diagnostic_settings = optional(object({
            name         = string
            workspace_id = string
        }))
        default_ip_restrictions = optional(object({
            front_door = optional(bool)
            allow_uefa_ips = optional(bool)
            allow_uefa_azure_devops = optional(bool)
        }))
        custom_ip_restrictions = optional(list(object({
            name        = string
            action      = string
            priority    = number
            ip_address  = optional(string)
            service_tag = optional(string)
            description = optional(string)
            headers     = optional(list(object({
              x_azure_fdid  = list(string)
              x_fd_health_probe = list(string)
              x_forwarded_for = list(string)
              x_forwarded_host = list(string)
            })))
        })))
        tags = optional(map(string))
      }
    )
  )
  default = {}
}

