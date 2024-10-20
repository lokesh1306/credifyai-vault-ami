packer {
  required_plugins {
    azure = {
      version = ">= 2.0.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

variable "resource_group_name" {
  default = "credifyai-resources"
}

variable "SUBSCRIPTION_ID" {
  default = ""
}

variable "TENANT_ID" {
  default = ""
}

variable "CLIENT_ID" {
  default = ""
}

variable "CLIENT_SECRET" {
  default = ""
}

source "azure-arm" "vault" {
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  client_id       = var.CLIENT_ID
  client_secret   = var.CLIENT_SECRET
  os_type                           = "Linux"
  managed_image_resource_group_name = var.resource_group_name
  managed_image_name                = "vault-image"
  location                          = "Central US"
  image_publisher                   = "Canonical"
  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_sku                         = "22_04-lts-gen2"
  vm_size                           = "Standard_DS2_v2"
}

build {
  sources = ["source.azure-arm.vault"]

  provisioner "file" {
    source      = "certbot"
    destination = "/tmp/certbot"
  }

  provisioner "shell" {
    environment_vars = [
      "CHECKPOINT_DISABLE=1"
    ]
    scripts = [
      "packer_complete.sh"
    ]
  }
}
