variable "subscription_id" {
  description = "Azure subscription used for the WARDEN lab"
  type        = string
}

variable "location" {
  type    = string
  default = "australiaeast"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2as_v2"
}

variable "admin_username" {
  type    = string
  default = "wardenadmin"
}

variable "client_image_sku" {
  description = "Windows 11 SKU confirmed with Azure CLI before deployment"
  type        = string
}

variable "shutdown_time" {
  description = "HHmm local time for automatic shutdown"
  type        = string
  default     = "2100"
}