output "vm_public_ip" {
  description = "The public IP address of the VM."
  value       = azurerm_public_ip.vm_test_public_ip.ip_address
}

output "ssh_command" {
  description = "Command to connect to the VM via SSH"
  value       = "ssh azureuser@${azurerm_public_ip.vm_test_public_ip.ip_address}"
}

output "function_app_fqdn" {
  description = "Function App."
  value       = azurerm_linux_function_app.example.default_hostname
}