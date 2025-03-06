terraform {
  required_providers {
    iosxe = {
      source = "CiscoDevNet/iosxe"
      version = "0.5.6"
    }
    proxmox = {
      source = "bpg/proxmox"
      version = "0.69.1"
    }
    vyos = {
      source = "registry.terraform.io/thomasfinstad/vyos-rolling"
      version = "15.2.202501050"
    }
  }
}
