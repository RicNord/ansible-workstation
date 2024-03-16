variable "instance-list" {
  default     = []
  type        = list(any)
  description = "List of instances names to deploy"
  validation {
    condition     = alltrue([for instance in var.instance-list : contains(["arch-vm", "arch-container", "ubuntu-vm", "ubuntu-container"], instance)]) || length(var.instance-list) == 0
    error_message = "Valid instance namse are arch-vm, arch-container, ubuntu-vm, ubuntu-container"
  }
}
