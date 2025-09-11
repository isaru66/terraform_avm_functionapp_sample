variable "resource_suffix" {
  type = string
}

variable "enable_telemetry" {
  type    = bool
  default = true  
}

variable "admin_password" {
  description = "The admin password for the VM."
  type        = string
  sensitive   = true
}