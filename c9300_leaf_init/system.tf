locals {
  monitoring_ip = "10.5.0.${var.switch_info.node_id}"
}
resource "iosxe_restconf" "system_config" {
  path = "Cisco-IOS-XE-native:native"
  attributes = {
    "hostname" = var.switch_info.hostname
    "system/Cisco-IOS-XE-switch:mtu/size" = 9169
  }
}

resource "iosxe_restconf" "login_banner" {
  path = "Cisco-IOS-XE-native:native/banner/login"
  attributes = {
    banner = <<EOT
    Welcome to the Catalyst
        leaf ${var.switch_info.leaf_id}
    EOT
  }
}

resource "iosxe_restconf" "vlan5_ip_config" {
  path = "Cisco-IOS-XE-native:native/interface/Vlan=5"

  attributes = {
    name              = "5"
    "ip/address/primary/address"  = "10.5.0.${var.switch_info.node_id}"                         # Interface Name
    "ip/address/primary/mask"     = "255.255.0.0"                         # Interface Name
  }
}



resource "iosxe_restconf" "snmp_contact_location" {
  path = "Cisco-IOS-XE-native:native/snmp-server"

  attributes = {
    "Cisco-IOS-XE-snmp:contact"  = "the Architect"   # SNMP Contact Information
    "Cisco-IOS-XE-snmp:location" = "home"              # SNMP Physical Location
  }
}

resource "iosxe_restconf" "snmp_community" {
  path = "Cisco-IOS-XE-native:native/snmp-server/Cisco-IOS-XE-snmp:community-config"

  attributes = {
    "name"        = "public"  # Community Name
    "Cisco-IOS-XE-snmp:name"        = "public"  # Community Name
    "Cisco-IOS-XE-snmp:permission"  = "ro"      # Read-Only Access
  }
}

