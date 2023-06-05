data "azurerm_subnet" "workload_subnet" {
  name = var.subnet_name
  virtual_network_name = var.vpc_name
  resource_group_name = var.resource_group_name
}

#Create network interface
resource "azurerm_network_interface" "workload_vm_nic" {
  name                = "${var.workload_name}_NIC"
  location            = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.workload_name}NIC_configuration"
    subnet_id                     = data.azurerm_subnet.workload_subnet.id 
    private_ip_address_allocation = "Dynamic"
  
  }
  
}

resource "azurerm_network_security_group" "workload_sg" {
  name                = "${var.workload_name}_sg"
  location            = var.region
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "ICMP"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [azurerm_network_interface.workload_vm_nic]

}

resource "azurerm_network_interface_security_group_association" "workload" {
  network_interface_id      = azurerm_network_interface.workload_vm_nic.id
  network_security_group_id = azurerm_network_security_group.workload_sg.id
  depends_on = [azurerm_network_interface.workload_vm_nic,azurerm_network_security_group.workload_sg]
}

# data "template_file" "init" {
#   template = "${file("pingtest_init.tpl")}"
#   vars = {
#     shared_server_ip = "10.8.8.8"
#   }
# }




# Create virtual machine
resource "azurerm_linux_virtual_machine" "workload" {
  name                  = var.workload_name
  location              = var.region
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.workload_vm_nic.id]
  size                  = "Standard_B2ms"

  os_disk {
    name                 = "${var.workload_name}-Disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

   source_image_reference {
     publisher = "Canonical"
     offer     = "0001-com-ubuntu-server-jammy"
     sku       = "22_04-lts-gen2"
     version   = "latest"
  }
  

   admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
 }

  admin_username                  = "azureuser"
  disable_password_authentication = true

  tags = var.tags
  custom_data = var.custom_data

}


output "workload_vm_nic" {
  value = azurerm_network_interface.workload_vm_nic
}
