variable "instance-list" {
  default     = ["arch-vm", "arch-cont", "ubuntu-vm", "ubuntu-cont"]
  type        = list(string)
  description = "List of instances to deploy"
  validation {
    condition     = alltrue([for instance in var.instance-list : contains(["arch-vm", "arch-cont", "ubuntu-vm", "ubuntu-cont"], instance)])
    error_message = "Valid instance are arch-vm, arch-cont, ubuntu-vm, ubuntu-cont"
  }
}

variable "ubuntu-versions" {
  default     = ["22.04", "24.04"]
  type        = list(string)
  description = "List of ubuntu versions to include"
}

locals {
  ubuntu-input             = [for instance in var.instance-list : instance if strcontains(instance, "ubuntu")]
  ubuntu-full-version-list = setproduct(local.ubuntu-input, var.ubuntu-versions)
  ubuntu-map               = [for l in local.ubuntu-full-version-list : { "name" : l[0], "version" : l[1], "instance-name" : replace("${l[0]}${l[1]}", ".", "") }]
  ubuntu-vm                = [for instance in local.ubuntu-map : instance if strcontains(instance.name, "vm")]
  ubuntu-vm-map            = { for k, v in local.ubuntu-vm : v.instance-name => v }
  ubuntu-containers        = [for instance in local.ubuntu-map : instance if strcontains(instance.name, "cont")]
  ubuntu-cont-map          = { for k, v in local.ubuntu-containers : v.instance-name => v }
}


locals {
  arch-input      = [for instance in var.instance-list : instance if strcontains(instance, "arch")]
  arch-vms        = [for instance in local.arch-input : instance if strcontains(instance, "vm")]
  arch-containers = [for instance in local.arch-input : instance if strcontains(instance, "cont")]
}
