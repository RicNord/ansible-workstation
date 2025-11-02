terraform {
  required_version = ">= 1.0"
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "1.0.0"
    }
  }
}

provider "incus" {
  generate_client_certificates = false
  accept_remote_certificate    = false
}
