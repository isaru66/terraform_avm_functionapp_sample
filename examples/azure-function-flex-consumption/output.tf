output "vm_name" {
  description = "The public IP address of the VM."
  value       = azurerm_linux_virtual_machine.test_vm.name
}

output "vm_public_ip" {
  description = "The public IP address of the VM."
  value       = azurerm_public_ip.vm_test_public_ip.ip_address
}

output "ssh_command" {
  description = "Command to connect to the VM via SSH"
  value       = "ssh azureuser@${azurerm_public_ip.vm_test_public_ip.ip_address}"
}

output "ssh_command_with_port_forwarding" {
  description = "Command to connect to the VM via SSH with port forwarding"
  value       = "ssh azureuser@${azurerm_public_ip.vm_test_public_ip.ip_address} -L 8443:${azurerm_private_endpoint.function_app.private_service_connection[0].private_ip_address}:443"
}

output "function_app_fqdn" {
  description = "Function App."
  value       = azurerm_function_app_flex_consumption.example.default_hostname
}