

data "azurerm_managed_disk" "vm_wus1_osdisk" { 
  ##Needed to use a data resource to retrieve the OS disk ID
  name                = azurerm_windows_virtual_machine.vm_wus1.os_disk[0].name
  resource_group_name = azurerm_windows_virtual_machine.vm_wus1.resource_group_name
}
resource "azurerm_windows_virtual_machine" "vm_wus1" {
  name                = "vm-${azurerm_resource_group.primary_wus1.location}-005"
  location             = azurerm_resource_group.primary_wus1.location
  resource_group_name  = azurerm_resource_group.primary_wus1.name
  size                = "Standard_B1ms"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [azurerm_network_interface.vm_wus1.id]
  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.this.id ]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  lifecycle {
    ignore_changes = [ identity, ]
  }
}
resource "azurerm_managed_disk" "vm_wus1" {
  name                 = "data-${azurerm_resource_group.primary_wus1.location}-disk1"
  location             = azurerm_resource_group.primary_wus1.location
  resource_group_name  = azurerm_resource_group.primary_wus1.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}
resource "azurerm_virtual_machine_data_disk_attachment" "vm_wus1" {
  managed_disk_id    = azurerm_managed_disk.vm_wus1.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm_wus1.id
  lun                = "10"
  caching            = "ReadWrite"
}
resource "azurerm_public_ip" "westus1" {
  name                = "vm-pip-${azurerm_resource_group.primary_wus1.location}-005"
  allocation_method   = "Static"
  location            = azurerm_resource_group.primary_wus1.location
  resource_group_name = azurerm_resource_group.primary_wus1.name
  sku                 = "Basic"
}
resource "azurerm_public_ip" "eastus1" {
  name                = "vm-pip-${azurerm_resource_group.secondary_eus.location}-005"
  allocation_method   = "Static"
  location            = azurerm_resource_group.secondary_eus.location
  resource_group_name = azurerm_resource_group.secondary_eus.name
  sku                 = "Basic"
}
resource "azurerm_network_interface" "vm_wus1" {
  name                = "vm-${azurerm_resource_group.primary_wus1.location}-nic"
  location            = azurerm_resource_group.primary_wus1.location
  resource_group_name = azurerm_resource_group.primary_wus1.name

  ip_configuration {
    name                          = "vm_wus1"
    subnet_id                     = azurerm_subnet.westus1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.westus1.id
  }
}