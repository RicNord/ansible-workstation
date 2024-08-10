terraform {
  required_version = ">= 1.0"
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "0.1.1"
    }
  }
}

provider "incus" {
  generate_client_certificates = false
  accept_remote_certificate    = false
}
