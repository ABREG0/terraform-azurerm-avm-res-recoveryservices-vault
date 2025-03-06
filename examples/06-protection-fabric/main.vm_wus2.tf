

data "azurerm_managed_disk" "vm_wus2_osdisk" {
  ##Needed to use a data resource to retrieve the OS disk ID
  name                = azurerm_windows_virtual_machine.vm_wus2.os_disk[0].name
  resource_group_name = azurerm_windows_virtual_machine.vm_wus2.resource_group_name
}
resource "azurerm_windows_virtual_machine" "vm_wus2" {
  name                  = "vm-${azurerm_resource_group.primary_wus2.location}-001"
  location              = azurerm_resource_group.primary_wus2.location
  resource_group_name   = azurerm_resource_group.primary_wus2.name
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  admin_password        = "P@$$w0rd1234!"
  network_interface_ids = [azurerm_network_interface.vm_wus2.id]
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
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
    ignore_changes = [identity, ]
  }
}
resource "azurerm_managed_disk" "vm_wus2" {
  name                 = "data-${azurerm_resource_group.primary_wus2.location}-disk1"
  location             = azurerm_resource_group.primary_wus2.location
  resource_group_name  = azurerm_resource_group.primary_wus2.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}
resource "azurerm_virtual_machine_data_disk_attachment" "vm_wus2" {
  managed_disk_id    = azurerm_managed_disk.vm_wus2.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm_wus2.id
  lun                = "10"
  caching            = "ReadWrite"
}
resource "azurerm_public_ip" "westus2" {
  name                = "vm-pip-${azurerm_resource_group.primary_wus2.location}-001"
  allocation_method   = "Static"
  location            = azurerm_resource_group.primary_wus2.location
  resource_group_name = azurerm_resource_group.primary_wus2.name
  sku                 = "Basic"
}
resource "azurerm_public_ip" "centralus" {
  name                = "vm-pip-${azurerm_resource_group.primary_wus2.location}-001"
  allocation_method   = "Static"
  location            = azurerm_resource_group.secondary_cus.location
  resource_group_name = azurerm_resource_group.secondary_cus.name
  sku                 = "Basic"
}
resource "azurerm_network_interface" "vm_wus2" {
  name                = "vm-${azurerm_resource_group.primary_wus2.location}-nic"
  location            = azurerm_resource_group.primary_wus2.location
  resource_group_name = azurerm_resource_group.primary_wus2.name

  ip_configuration {
    name                          = "vm_wus2"
    subnet_id                     = azurerm_subnet.westus2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.westus2.id
  }
}