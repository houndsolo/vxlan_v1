locals {
}
resource "iosxe_restconf" "ospf_global_config" {
  path = "Cisco-IOS-XE-native:native/router/Cisco-IOS-XE-ospf:router-ospf"
  attributes = {
    "ospf/process-id/id"                = "1"
    "ospf/process-id/compatible/rfc1583"            = true
  }
}

resource "iosxe_restconf" "loopback0" {
  path = "Cisco-IOS-XE-native:native/interface/Loopback=0"

  depends_on = [iosxe_restconf.ospf_global_config]
  attributes = {
    name                = "0"
    description         = "vxlan/iBGP peering"
    "ip/address/primary/address" = "10.240.254.${var.switch_info.leaf_id}"
    "ip/address/primary/mask" = "255.255.255.255"
    "ip/Cisco-IOS-XE-ospf:router-ospf/ospf/process-id/id" = 1
    "ip/Cisco-IOS-XE-ospf:router-ospf/ospf/process-id/area/area-id" = 0
    "ip/pim/Cisco-IOS-XE-multicast:pim-mode-choice-cfg/sparse-mode" = ""
  }
}

resource "iosxe_restconf" "set_interfaces" {
  count = var.spines
  depends_on = [iosxe_restconf.ospf_global_config]
  path = "Cisco-IOS-XE-native:native/interface/TenGigabitEthernet=1%2F0%2F${tostring(count.index + 1)}"
  attributes = {
    name                = "1/0/${count.index + 1}"
    description         = "link to spine ${count.index + 1}"
    "ip/address/primary/address" = "10.240.${tostring(var.switch_info.leaf_id)}${tostring(count.index + 1)}.1"
    "ip/address/primary/mask" = "255.255.255.254"
    "ip/Cisco-IOS-XE-ospf:router-ospf/ospf/process-id/id" = 1
    "ip/Cisco-IOS-XE-ospf:router-ospf/ospf/network/point-to-point" = ""
  }
}

resource "iosxe_restconf" "set_interfaces_multicast" {
  depends_on = [iosxe_restconf.set_interfaces]
  count = var.spines
  path = "Cisco-IOS-XE-native:native/interface/TenGigabitEthernet=1%2F0%2F${tostring(count.index + 1)}"
  attributes = {
    name = "1/0/${tostring(count.index + 1)}"
    "ip/pim/Cisco-IOS-XE-multicast:pim-mode-choice-cfg/sparse-mode" = ""
  }
}
