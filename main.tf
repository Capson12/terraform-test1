terraform {
  required_providers {
    azurerm = {
        source =  "hashicorp/azurerm"
        version = "~> 2.88.1"
    }
    
    azuread = {
      source = "hashicorp/azuread"
      version = "~> 2.15.0"
      }

  }

  required_version = ">= 0.15"
}

provider "azuread" {
  tenant_id = "c4e9801b-23f9-4ab7-8730-32fd9af9c27b"
  
}

provider "azurerm" {
    features {}
  
}


resource "azurerm_resource_group" "main" {
    name = "smtx-rg-2"
    location = "uksouth"
}

#Create vnet
resource "azurerm_virtual_network" "main" {
  name = "smtx-vnet-2"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space = ["10.0.0.0/16"]

}

#Create Subnet
resource "azurerm_subnet" "main" {
  name = "smtx-subnet-2"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name = azurerm_resource_group.main.name
  address_prefixes = ["10.0.0.0/24"]
}

#Create Network interface cards

resource "azurerm_network_interface" "internal"{
  name = "smtx-nic-2"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.main.id
    private_ip_address_allocation = "dynamic"
    }
  }

  #Create VM

  resource "azurerm_windows_virtual_machine" "main"{
    name = "smtx-vm-2"
    resource_group_name = azurerm_resource_group.main.name
    location =  azurerm_resource_group.main.location
    size = "Standard_B1s"
    admin_username = "user.admin"
    admin_password = "Mchoney.2021!"

    network_interface_ids = [
      azurerm_network_interface.internal.id
    ]

    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher =  "MicrosoftwindowsServer"
      offer = "windowsServer"
      sku = "2016-DataCenter"
      version = "latest"
    }

  }