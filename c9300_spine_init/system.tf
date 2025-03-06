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
        spine ${var.switch_info.spine_id}
    EOT
  }
}



resource "iosxe_restconf" "vlan5_ip_config" {
  path = "openconfig-interfaces:interfaces/interface=Vlan5"

  attributes = {
    # Interface Configuration
    name = "Vlan5"
    "config/name"                                     = "Vlan5"                         # Interface Name
    "config/type"                                     = "iana-if-type:l3ipvlan"         # Layer 3 VLAN Type
    "config/enabled"                                  = true                            # Enable Interface
  }
}

resource "iosxe_restconf" "vlan5_ipv4_config" {
  path = "openconfig-interfaces:interfaces/interface=Vlan5/openconfig-vlan:routed-vlan/openconfig-if-ip:ipv4/addresses/address=10.5.0.${var.switch_info.node_id}"

  attributes = {
    "ip"            = "10.5.0.${var.switch_info.node_id}"  # IPv4 Address
    "config/ip"            = "10.5.0.${var.switch_info.node_id}"  # IPv4 Address
    "config/prefix-length" = 16                                   # Subnet Mask (/16)
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

