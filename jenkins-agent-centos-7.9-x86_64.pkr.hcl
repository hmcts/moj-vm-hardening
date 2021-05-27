variable "azure_client_id" {
  type    = string
  default = "null"
}

variable "azure_client_secret" {
  type    = string
  default = "null"
}

variable "azure_location" {
  type    = string
  default = "uksouth"
}

variable "azure_object_id" {
  type    = string
  default = "null"
}

variable "azure_resource_group_name" {
  type    = string
  default = "null"
}

variable "azure_storage_account" {
  type    = string
  default = "null"
}

variable "azure_subscription_id" {
  type    = string
  default = "null"
}

variable "azure_tenant_id" {
  type    = string
  default = "null"
}

variable "ssh_user" {
  type    = string
  default = "null"
}

variable "ssh_password" {
  type    = string
  default = "null"
}

variable "jenkins_ssh_key" {
  type    = string
  default = "null"
}

source "azure-arm" "azure-os-image" {
  azure_tags = {
    imagetype = "base79"
    timestamp = formatdate("YYYYMMDDhhmmss",timestamp())
  }
  client_id                         = "${var.azure_client_id}"
  client_secret                     = "${var.azure_client_secret}"
  image_offer                       = "CentOS"
  image_publisher                   = "openlogic"
  image_sku                         = "7_9"
  location                          = "${var.azure_location}"
  managed_image_name                = "moj-centos-base-${formatdate("YYYYMMDDhhmmss",timestamp())}"
  managed_image_resource_group_name = "${var.azure_resource_group_name}"
  os_type                           = "Linux"
  ssh_pty                           = "true"
  ssh_username                      = "${var.ssh_user}"
  subscription_id                   = "${var.azure_subscription_id}"
  tenant_id                         = "${var.azure_tenant_id}"
  vm_size                           = "Standard_A2_v2"
}

build {
  sources = ["source.azure-arm.azure-os-image"]

  provisioner "file" {
      source = "repos/"
      destination = "/tmp/"
    }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E sh '{{ .Path }}'"
    script          = "shell-provisioner.sh"
  }

  provisioner "ansible" {
    use_proxy       =  false
    extra_arguments = ["--ssh-extra-args", "-o IdentitiesOnly=yes"]
    playbook_file   = "./hardening.yml"
  }

}
