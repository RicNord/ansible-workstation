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

resource "incus_network" "test_net" {
  name = "ansibleTestNet"
  type = "bridge"

  config = {
    "ipv4.nat" = "true"
    "ipv6.nat" = "true"
  }
}

resource "incus_storage_pool" "test_pool" {
  name    = "ansible-test-pool"
  project = incus_project.project.name
  driver  = "dir"
  config = {
    source = "/var/lib/incus/storage-pools/ansible-test-pool"
  }
}

resource "incus_profile" "test_profile" {
  name    = "test-profile"
  project = incus_project.project.name

  config = {
    "boot.autostart"      = false
    "security.secureboot" = false
  }

  device {
    name = "incus01"
    type = "nic"
    properties = {
      network = incus_network.test_net.name
    }
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = incus_storage_pool.test_pool.name
      size = "30GB"
    }
  }
}

resource "incus_instance" "arch_vm" {
  for_each  = toset(local.arch_vms)
  name      = each.key
  project   = incus_project.project.name
  image     = "images:archlinux/cloud"
  type      = "virtual-machine"
  ephemeral = true
  running   = true
  profiles  = [incus_profile.test_profile.name]

  config = {
    "cloud-init.user-data" = file("${path.module}/cloud-init-arch.yaml")
  }

  limits = {
    cpu    = 6
    memory = "8GB"
  }

  provisioner "local-exec" {
    command     = "incus exec ${each.key} --project ${incus_project.project.name} -- cloud-init status --long --wait || if [ $? -ne 1 ]; then echo \"cloud-init exit $?\"; exit 0; else echo \"cloud-init exit $?\"; exit 1; fi"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "incus_instance" "arch_container" {
  for_each  = toset(local.arch_containers)
  name      = each.key
  project   = incus_project.project.name
  image     = "images:archlinux/cloud"
  type      = "container"
  ephemeral = true
  running   = true
  profiles  = [incus_profile.test_profile.name]

  config = {
    "cloud-init.user-data" = file("${path.module}/cloud-init-arch.yaml")
  }

  provisioner "local-exec" {
    command     = "incus exec ${each.key} --project ${incus_project.project.name} -- cloud-init status --long --wait || if [ $? -ne 1 ]; then echo \"cloud-init exit $?\"; exit 0; else echo \"cloud-init exit $?\"; exit 1; fi"
    interpreter = ["/bin/bash", "-c"]
  }
}
resource "incus_instance" "ubuntu_vm" {
  for_each  = local.ubuntu_vm_map
  name      = each.value.instance_name
  project   = incus_project.project.name
  image     = "images:ubuntu/${each.value.version}/cloud"
  type      = "virtual-machine"
  ephemeral = true
  running   = true
  profiles  = [incus_profile.test_profile.name]

  config = {
    "cloud-init.user-data" = file("${path.module}/cloud-init-ubuntu.yaml")
  }

  provisioner "local-exec" {
    command     = "incus exec ${each.value.instance_name} --project ${incus_project.project.name} -- cloud-init status --long --wait || if [ $? -ne 1 ]; then echo \"cloud-init exit $?\"; exit 0; else echo \"cloud-init exit $?\"; exit 1; fi"
    interpreter = ["/bin/bash", "-c"]
  }

  limits = {
    cpu    = 6
    memory = "8GB"
  }
}

resource "incus_instance" "ubuntu_container" {
  for_each  = local.ubuntu_cont_map
  name      = each.value.instance_name
  project   = incus_project.project.name
  image     = "images:ubuntu/${each.value.version}/cloud"
  type      = "container"
  ephemeral = true
  running   = true
  profiles  = [incus_profile.test_profile.name]


  config = {
    "cloud-init.user-data" = file("${path.module}/cloud-init-ubuntu.yaml")
  }

  provisioner "local-exec" {
    command     = "incus exec ${each.value.instance_name} --project ${incus_project.project.name} -- cloud-init status --long --wait || if [ $? -ne 1 ]; then echo \"cloud-init exit $?\"; exit 0; else echo \"cloud-init exit $?\"; exit 1; fi"
    interpreter = ["/bin/bash", "-c"]
  }
}
