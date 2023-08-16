// Define resource group
resource "azurerm_resource_group" "octopus-samples-azure-workers" {
  name      = var.octopus_azure_resourcegroup_name
  location  = var.octopus_azure_location
  tags = var.tags
}

// Define virtual network
resource "azurerm_virtual_network" "octopus-samples-workers-virtual-network" {
  name                = "octopus-samples-workers"
  address_space       = ["10.0.0.0/16"]
  location            = var.octopus_azure_location
  resource_group_name = var.octopus_azure_resourcegroup_name
  depends_on = [
     azurerm_resource_group.octopus-samples-azure-workers
  ]
  tags = var.tags
}

// Define subnet
resource "azurerm_subnet" "octopus-samples-workers-subnet" {
  name                 = "octopus-samples-workers-subnet"
  resource_group_name  = var.octopus_azure_resourcegroup_name
  virtual_network_name = azurerm_virtual_network.octopus-samples-workers-virtual-network.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [
     azurerm_resource_group.octopus-samples-azure-workers,
     azurerm_virtual_network.octopus-samples-workers-virtual-network
  ]  
}

// Define user managed identity
resource "azurerm_user_assigned_identity" "database-admin" {
  location = var.octopus_azure_location
  resource_group_name = var.octopus_azure_resourcegroup_name

  name = "samples-database-admin"

  depends_on = [ azurerm_resource_group.octopus-samples-azure-workers ]
}

// Define azure scale set
resource "azurerm_linux_virtual_machine_scale_set" "samples-azure-workers" {
  name                = var.octopus_azure_scaleset_name
  resource_group_name = var.octopus_azure_resourcegroup_name
  location            = var.octopus_azure_location
  sku                 = var.octopus_azure_vm_size
  instances           = var.octopus_azure_vm_instance_count
  admin_username      = var.octopus_azure_vm_admin_username
  admin_password =  var.octopus_azure_vm_admin_password
  disable_password_authentication = false
  user_data = "${base64encode(file("../configure-tentacle.sh"))}"
  
  identity {
    #type = "SystemAssigned"
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.database-admin.id]
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = var.octopus_azure_vm_sku
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.octopus-samples-workers-subnet.id
    }
  }
  tags = var.tags

  depends_on = [ azurerm_user_assigned_identity.database-admin ]
}

# Create Windows worker
resource "azurerm_network_interface" "windows-worker-nic" {
  name = "samples-windows-worker-nic"
  location = var.octopus_azure_location
  resource_group_name = var.octopus_azure_resourcegroup_name
  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.octopus-samples-workers-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}



resource "azurerm_windows_virtual_machine" "samples-windows-worker" {
  name = var.octopus_azure_windows_worker_name
  location = var.octopus_azure_location
  resource_group_name = var.octopus_azure_resourcegroup_name
  size = var.octopus_azure_vm_size
  admin_username      = var.octopus_azure_vm_admin_username
  admin_password =  var.octopus_azure_vm_admin_password
  allow_extension_operations = true
  network_interface_ids = [
    azurerm_network_interface.windows-worker-nic.id
    ]
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.octopus_azure_windows_vm_sku
    version   = "latest"
  }  
    
  #custom_data = "${base64encode(file("../configure-tentacle.ps1"))}"

  identity {
    #type = "SystemAssigned"
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.database-admin.id]
  }

  tags = var.tags

  depends_on = [ azurerm_user_assigned_identity.database-admin ]
}

resource "azurerm_virtual_machine_extension" "bootstrap-script" {
  name = "samples-windows-vm-boostrap"
  virtual_machine_id = azurerm_windows_virtual_machine.samples-windows-worker.id
  publisher = "Microsoft.Compute"
  type = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<SETTINGS
    {
      "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(file("../configure-tentacle.ps1"))}')) | Out-File -filepath bootstrap.ps1\" && powershell -ExecutionPolicy Unrestricted -File bootstrap.ps1"
    }
  SETTINGS
  tags = var.tags
}

/* DEBUG PURPOSES ONLY 

This section will create a "jumpbox" VM to allow you to SSH into your Scale Set VMs
since they do not have public IP addresses assigned to them.  Uncomment this secion
to enable the "jumpbox"

*/

/*
resource "azurerm_public_ip" "jumpbox" {
 name                         = "jumpbox-public-ip"
 location                     = var.octopus_azure_location
 resource_group_name          = var.octopus_azure_resourcegroup_name
 allocation_method            = "Static"
  depends_on = [
     azurerm_resource_group.octopus-samples-azure-workers,
     azurerm_virtual_network.octopus-samples-workers-virtual-network
  ]   
}

resource "azurerm_network_interface" "jumpbox" {
 name                = "jumpbox-nic"
 location            = var.octopus_azure_location
 resource_group_name = var.octopus_azure_resourcegroup_name

 ip_configuration {
   name                          = "IPConfiguration"
   subnet_id                     = azurerm_subnet.octopus-samples-workers-subnet.id
   private_ip_address_allocation = "dynamic"
   public_ip_address_id          = azurerm_public_ip.jumpbox.id
 }
  depends_on = [
     azurerm_resource_group.octopus-samples-azure-workers,
     azurerm_virtual_network.octopus-samples-workers-virtual-network,
     azurerm_public_ip.jumpbox
  ]   
}

resource "azurerm_virtual_machine" "jumpbox" {
 name                  = "jumpbox"
 location              = var.octopus_azure_location
 resource_group_name   = var.octopus_azure_resourcegroup_name
 network_interface_ids = [azurerm_network_interface.jumpbox.id]
 vm_size               = "Standard_B2s"

 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "18.04-LTS"
   version   = "latest"
 }

 storage_os_disk {
   name              = "jumpbox-osdisk"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 os_profile {
   computer_name  = "jumpbox"
   admin_username = var.octopus_azure_vm_admin_username
   admin_password = var.octopus_azure_vm_admin_password
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }
  depends_on = [
     azurerm_resource_group.octopus-samples-azure-workers,
     azurerm_virtual_network.octopus-samples-workers-virtual-network,
     azurerm_network_interface.jumpbox
  ]  
}
*/
/* END DEBUG SECTION */