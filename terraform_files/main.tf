terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    
  }

  
}  




provider "azurerm" {
   
  features {}
  subscription_id = jsondecode(var.azure_credentials).subscriptionId
  client_id       = jsondecode(var.azure_credentials).clientId
  client_secret   = jsondecode(var.azure_credentials).clientSecret
  tenant_id       = jsondecode(var.azure_credentials).tenantId
  skip_provider_registration = true
}

terraform {
    backend "azurerm" {
    resource_group_name = "1-0a9b8ce0-playground-sandbox"
    storage_account_name = "terrabackendtkxelassign3"
    container_name = "tfstate"
    key = "terraform.tfstate"
  }
}


# getting current resource group as playground permissions are limited
data "azurerm_resource_group" "existing" {
  name = var.rg_name 
}

# Creating a virtual network 
resource "azurerm_virtual_network" "vn-tkxelassign3" {
  name                = "network-tkxelassign3"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet-tkxelassign3" {
  name                 = "subnet-tkxelassign3"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.vn-tkxelassign3.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "terraform_public_ip" {
  name                = "public-ip-tkxelassign3"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic-tkxelassign3" {
  name                = "tkxelassign3-nic"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  depends_on = [azurerm_network_security_group.terraform_nsg]
  ip_configuration {
    name                          = "tkxelassign3-IP-configuration1"
    subnet_id                     = azurerm_subnet.subnet-tkxelassign3.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.terraform_public_ip.id
  }
  
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "terraform_nsg" {
  name                = "terraform-nsg"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
   lifecycle {
    create_before_destroy = true
  }
}

# Connect the security group
resource "azurerm_network_interface_security_group_association" "nsg_association_terraform" {
  network_interface_id      = azurerm_network_interface.nic-tkxelassign3.id
  network_security_group_id = azurerm_network_security_group.terraform_nsg.id
}

resource "azurerm_virtual_machine" "vm-tkxelassign3" {
  name                  = "vm-tkxelassign3"
  location              = data.azurerm_resource_group.existing.location
  resource_group_name   = data.azurerm_resource_group.existing.name
  network_interface_ids = [azurerm_network_interface.nic-tkxelassign3.id]
  vm_size               = "standard_b1s"
  
  depends_on = [ azurerm_network_interface.nic-tkxelassign3, azurerm_network_interface_security_group_association.nsg_association_terraform ]
  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "vm-tkxelassign3"        # Name of the VM inside the OS
    admin_username = var.adm_user         # Admin username
    admin_password = var.adm_pass  # Password for the admin user (optional if using SSH keys)
  }
    
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
        key_data = var.keydata 
        path = "/home/${var.adm_user}/.ssh/authorized_keys"
    }
  }

  tags = {
    environment = var.environment_name
  }

  
}

# creating storage account
resource "azurerm_storage_account" "stor_acc_tkxelassign3" {
  name                     = "storacctkxelassign3"
  resource_group_name      = data.azurerm_resource_group.existing.name
  location                 = data.azurerm_resource_group.existing.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "stor_cont_tkxelassign3" {
  name                  = "storconttkxelassign3"
  storage_account_name  = azurerm_storage_account.stor_acc_tkxelassign3.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "blob_tkxelassign3" {
  name                   = "blob_tkxelassign3.txt"
  storage_account_name   = azurerm_storage_account.stor_acc_tkxelassign3.name
  storage_container_name = azurerm_storage_container.stor_cont_tkxelassign3.name
  type                   = "Block"
  # source                 = "some-local-file.zip"
}


