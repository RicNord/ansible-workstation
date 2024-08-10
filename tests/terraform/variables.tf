variable "instance_list" {
  default     = ["arch-vm", "arch-cont", "ubuntu-vm", "ubuntu-cont"]
  type        = list(string)
  description = "List of instances to deploy"
  validation {
    condition     = alltrue([for instance in var.instance_list : contains(["arch-vm", "arch-cont", "ubuntu-vm", "ubuntu-cont"], instance)])
    error_message = "Valid instance are arch-vm, arch-cont, ubuntu-vm, ubuntu-cont"
  }
}

variable "ubuntu_versions" {
  default     = ["22.04", "24.04"]
  type        = list(string)
  description = "List of ubuntu versions to include"
}

locals {
  ubuntu_input             = [for instance in var.instance_list : instance if strcontains(instance, "ubuntu")]
  ubuntu_full_version_list = setproduct(local.ubuntu_input, var.ubuntu_versions)
  ubuntu_map               = [for l in local.ubuntu_full_version_list : { "name" : l[0], "version" : l[1], "instance_name" : replace("${l[0]}${l[1]}", ".", "") }]
  ubuntu_vm                = [for instance in local.ubuntu_map : instance if strcontains(instance.name, "vm")]
  ubuntu_vm_map            = { for k, v in local.ubuntu_vm : v.instance_name => v }
  ubuntu_containers        = [for instance in local.ubuntu_map : instance if strcontains(instance.name, "cont")]
  ubuntu_cont_map          = { for k, v in local.ubuntu_containers : v.instance_name => v }
}


locals {
  arch_input      = [for instance in var.instance_list : instance if strcontains(instance, "arch")]
  arch_vms        = [for instance in local.arch_input : instance if strcontains(instance, "vm")]
  arch_containers = [for instance in local.arch_input : instance if strcontains(instance, "cont")]
}
