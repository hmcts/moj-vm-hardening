variable "client_id" {
  type    = string
  default = ""
}

variable "client_secret" {
  type    = string
  default = ""
}

variable "azure_image_version" {
  type    = string
  default = "1.0.1"
}

variable "azure_location" {
  type    = string
  default = "uksouth"
}

variable "azure_object_id" {
  type    = string
  default = ""
}

variable "resource_group_name" {
  type    = string
  default = "hmcts-image-gallery-rg"
}

variable "azure_storage_account" {
  type    = string
  default = ""
}

variable "subscription_id" {
  type    = string
  default = ""
}

variable "tenant_id" {
  type    = string
  default = ""
}

variable "ssh_user" {
  type    = string
  default = ""
}

variable "ssh_password" {
  type    = string
  default = ""
}

variable "jenkins_ssh_key" {
  type    = string
  default = ""
}

source "azure-arm" "azure-os-image" {
  azure_tags = {
    imagetype = "jenkins-ubuntu"
    timestamp = formatdate("YYYYMMDDhhmmss",timestamp())
  }
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  image_offer                       = "0001-com-ubuntu-server-focal"
  image_publisher                   = "Canonical"
  image_sku                         = "20_04-lts"
  location                          = var.azure_location
  managed_image_name                = "jenkins-ubuntu-${formatdate("YYYYMMDDhhmmss",timestamp())}"
  managed_image_resource_group_name = var.resource_group_name
  os_type                           = "Linux"
  ssh_pty                           = "true"
  ssh_username                      = var.ssh_user
  subscription_id                   = var.subscription_id
  tenant_id                         = var.tenant_id
  vm_size                           = "Standard_A2_v2"

  shared_image_gallery_destination {
    subscription        = var.subscription_id
    resource_group      = var.resource_group_name
    gallery_name        = "hmcts"
    image_name          = "jenkins-agent"
    image_version       = var.azure_image_version
    replication_regions = ["UK South"]
  }
}

build {
  sources = ["source.azure-arm.azure-os-image"]

  provisioner "file" {
      source = "repos/"
      destination = "/tmp/"
    }
  
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E sh '{{ .Path }}'"
    script          = "provision-jenkins-ubuntu-agent.sh"
    environment_vars = ["JENKINS_SSH_KEY=${var.jenkins_ssh_key}"]
  }

}