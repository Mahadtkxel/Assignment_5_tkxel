output "public_ip_address" {
  value = azurerm_public_ip.terraform_public_ip.ip_address
  description = "Public ip of VM"
}

