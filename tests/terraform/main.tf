terraform {
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "0.1.0"
    }
  }
}

provider "incus" {
  generate_client_certificates = false
  accept_remote_certificate    = false
}

resource "incus_project" "project" {
  name        = "ansible-ws"
  description = "Test ansible ws"
  config = {

    # Features
    "features.storage.volumes" = true
    "features.images"          = false
    "features.profiles"        = true
    "features.storage.buckets" = true
    "features.networks"        = false
    "features.networks.zones"  = true

    # Limits
    "limits.networks" = 1

    # Restricted
    "restricted"                      = true
    "restricted.containers.nesting"   = "allow"
    "restricted.containers.privilege" = "unprivileged"

    # Images
    "images.auto_update_cached"   = true
    "images.auto_update_interval" = 168
    "images.default_architecture" = "x86_64"
    "images.remote_cache_expiry"  = 7
  }
}

resource "incus_network" "test-net" {
  name = "ansibleTestNet"
  type = "bridge"

  config = {
    "ipv4.nat" = "true"
    "ipv6.nat" = "true"
  }
}

resource "incus_storage_pool" "test-pool" {
  name    = "ansible-test-pool"
  project = incus_project.project.name
  driver  = "dir"
  config = {
    source = "/var/lib/incus/storage-pools/ansible-test-pool"
  }
}

resource "incus_profile" "test-profile" {
  name    = "test-profile"
  project = incus_project.project.name

  config = {
    "boot.autostart"       = false
    "security.secureboot"  = false
  }

  device {
    name = "incus01"
    type = "nic"
    properties = {
      network = incus_network.test-net.name
    }
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = incus_storage_pool.test-pool.name
      size = "30GB"
    }
  }
}

resource "incus_instance" "arch-vm" {
  count     = contains(var.instance-list, "arch-vm") || length(var.instance-list) == 0 ? 1 : 0
  name      = "arch-vm"
  project   = incus_project.project.name
  image     = "images:archlinux/cloud"
  type      = "virtual-machine"
  ephemeral = true
  running   = true
  profiles  = [incus_profile.test-profile.name]

  config = {
    "cloud-init.user-data" = file("${path.module}/cloud-init-arch.yaml")
  }

  limits = {
    cpu    = 6
    memory = "8GB"
  }

  provisioner "local-exec" {
    command     = "incus exec ${incus_instance.arch-vm[0].name} --project ${incus_project.project.name} -- cloud-init status --long --wait || if [ $? -ne 1 ]; then echo \"cloud-init exit $?\"; exit 0; else echo \"cloud-init exit $?\"; exit 1; fi"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "incus_instance" "arch-container" {
  count     = contains(var.instance-list, "arch-container") || length(var.instance-list) == 0 ? 1 : 0
  name      = "arch-container"
  project   = incus_project.project.name
  image     = "images:archlinux/cloud"
  type      = "container"
  ephemeral = true
  running   = true
  profiles  = [incus_profile.test-profile.name]

  config = {
    "cloud-init.user-data" = file("${path.module}/cloud-init-arch.yaml")
  }

  provisioner "local-exec" {
    command     = "incus exec ${incus_instance.arch-container[0].name} --project ${incus_project.project.name} -- cloud-init status --long --wait || if [ $? -ne 1 ]; then echo \"cloud-init exit $?\"; exit 0; else echo \"cloud-init exit $?\"; exit 1; fi"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "incus_instance" "ubuntu-vm" {
  count     = contains(var.instance-list, "ubuntu-vm") || length(var.instance-list) == 0 ? 1 : 0
  name      = "ubuntu-vm"
  project   = incus_project.project.name
  image     = "images:ubuntu/jammy/cloud"
  type      = "virtual-machine"
  ephemeral = true
  running   = true
  profiles  = [incus_profile.test-profile.name]

  config = {
    "cloud-init.user-data" = file("${path.module}/cloud-init-ubuntu.yaml")
  }

  provisioner "local-exec" {
    command     = "incus exec ${incus_instance.ubuntu-vm[0].name} --project ${incus_project.project.name} -- cloud-init status --long --wait || if [ $? -ne 1 ]; then echo \"cloud-init exit $?\"; exit 0; else echo \"cloud-init exit $?\"; exit 1; fi"
    interpreter = ["/bin/bash", "-c"]
  }

  limits = {
    cpu    = 6
    memory = "8GB"
  }
}

resource "incus_instance" "ubuntu-container" {
  count     = contains(var.instance-list, "ubuntu-container") || length(var.instance-list) == 0 ? 1 : 0
  name      = "ubuntu-container"
  project   = incus_project.project.name
  image     = "images:ubuntu/jammy/cloud"
  type      = "container"
  ephemeral = true
  running   = true
  profiles  = [incus_profile.test-profile.name]


  config = {
    "cloud-init.user-data" = file("${path.module}/cloud-init-ubuntu.yaml")
  }

  provisioner "local-exec" {
    command     = "incus exec ${incus_instance.ubuntu-container[0].name} --project ${incus_project.project.name} -- cloud-init status --long --wait || if [ $? -ne 1 ]; then echo \"cloud-init exit $?\"; exit 0; else echo \"cloud-init exit $?\"; exit 1; fi"
    interpreter = ["/bin/bash", "-c"]
  }
}
