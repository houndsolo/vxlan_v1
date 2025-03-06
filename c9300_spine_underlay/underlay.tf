locals {
  interface_map = { for leaf in var.leaves : leaf.hostname => { for conn in leaf.spine_connections : conn.spine_id => conn.interface } }
  msdp_peer_id =  tonumber(var.switch_info.spine_id) == 2 ? 1 : 2
}

resource "iosxe_restconf" "ospf_global_config" {
  path = "Cisco-IOS-XE-native:native/router/Cisco-IOS-XE-ospf:router-ospf"
  attributes = {
    "ospf/process-id/id"                = "1"
    "ospf/process-id/compatible/rfc1583"            = true
  }
}



resource "iosxe_restconf" "loopback0_openconfig" {
  depends_on = [iosxe_restconf.ospf_global_config]
  path = "Cisco-IOS-XE-native:native/interface/Loopback=0"

  attributes = {
    name                = "0"
    description         = "vxlan/iBGP peering"
    "ip/address/primary/address" = "10.240.255.${var.switch_info.spine_id}"
    "ip/address/primary/mask" = "255.255.255.255"
    "ip/Cisco-IOS-XE-ospf:router-ospf/ospf/process-id/id" = 1
    "ip/Cisco-IOS-XE-ospf:router-ospf/ospf/process-id/area/area-id" = 0
    "ip/pim/Cisco-IOS-XE-multicast:pim-mode-choice-cfg/sparse-mode" = ""
  }
}

resource "iosxe_restconf" "loopback1_openconfig" {
  depends_on = [iosxe_restconf.ospf_global_config]
  path = "Cisco-IOS-XE-native:native/interface/Loopback=1"

  attributes = {
    name                = "1"
    description         = "anycast RP"
    "ip/address/primary/address" = var.anycast_rp_address
    "ip/address/primary/mask" = "255.255.255.255"
    "ip/Cisco-IOS-XE-ospf:router-ospf/ospf/process-id/id" = 1
    "ip/Cisco-IOS-XE-ospf:router-ospf/ospf/process-id/area/area-id" = 0
    "ip/pim/Cisco-IOS-XE-multicast:pim-mode-choice-cfg/sparse-mode" = ""
  }
}

resource "iosxe_restconf" "loopback2_openconfig" {
  depends_on = [iosxe_restconf.ospf_global_config]
  path = "Cisco-IOS-XE-native:native/interface/Loopback=2"

  attributes = {
    name                = "2"
    description         = "MSDP Peer [ospf]"
    "ip/address/primary/address" = "10.240.252.${var.switch_info.spine_id}"
    "ip/address/primary/mask" = "255.255.255.255"
    "ip/Cisco-IOS-XE-ospf:router-ospf/ospf/process-id/id" = 1
    "ip/Cisco-IOS-XE-ospf:router-ospf/ospf/process-id/area/area-id" = 0
    "ip/pim/Cisco-IOS-XE-multicast:pim-mode-choice-cfg/sparse-mode" = ""
  }
}

resource "iosxe_restconf" "set_interfaces" {
  for_each = { for leaf in var.leaves : leaf.node_id => leaf }
  depends_on = [iosxe_restconf.ospf_global_config]
  path = "Cisco-IOS-XE-native:native/interface/TenGigabitEthernet=${replace(local.interface_map[each.value.hostname][var.switch_info.spine_id], "/", "%2F")}"
  attributes = {
    name                = local.interface_map[each.value.hostname][var.switch_info.spine_id]
    description         = "link to ${each.value.hostname}"
    "ip/address/primary/address" = "10.240.${each.value.node_id}${var.switch_info.spine_id}.0"
    "ip/address/primary/mask" = "255.255.255.254"
    "ip/Cisco-IOS-XE-ospf:router-ospf/ospf/process-id/id" = 1
    "ip/Cisco-IOS-XE-ospf:router-ospf/ospf/process-id/area/area-id" = 0
    "ip/Cisco-IOS-XE-ospf:router-ospf/ospf/network/point-to-point" = ""
  }
}


resource "iosxe_restconf" "set_interfaces_multicast" {
  depends_on = [iosxe_restconf.ospf_global_config]
  path = "Cisco-IOS-XE-native:native/interface"
  lists = [
    {
      name = "TenGigabitEthernet"
      key = "name"
      items = [
        for leaf in var.leaves : {
          name                = tostring(replace(local.interface_map[leaf.hostname][var.switch_info.spine_id], "TenGigabitEthernet", ""))
          "ip/pim/Cisco-IOS-XE-multicast:pim-mode-choice-cfg/sparse-mode" = ""
        }
      ]
    }
  ]
}

resource "iosxe_restconf" "configure_msdp" {
  path = "Cisco-IOS-XE-native:native/ip/Cisco-IOS-XE-multicast:msdp"
  attributes = {
    "peer/addr" = "10.240.254.${tostring(local.msdp_peer_id)}"
    "peer/connect-source/Loopback" = "2"
    "peer/remote-as" = 700
  }
}

resource "iosxe_restconf" "configure_pim_rp" {
  path = "Cisco-IOS-XE-native:native/ip/pim/Cisco-IOS-XE-multicast:rp-address-conf"
  attributes = {
    address = var.anycast_rp_address
  }
}


#resource "iosxe_restconf" "link_to_leaf_ipv4_config" {
#  for_each = { for leaf in var.leaves : leaf.hostname => leaf }
#
#  path = "openconfig-interfaces:interfaces/interface=${local.interface_map[each.value.hostname][var.switch_info.spine_id]}/subinterfaces/subinterface=0/openconfig-if-ip:ipv4/addresses/address=10.240.${each.value.node_id}${var.switch_info.spine_id}.0"
#
#  attributes = {
#    "ip"                        = "10.240.${each.value.node_id}${var.switch_info.spine_id}.0"  # IPv4 Address
#    "config/ip"                 = "10.240.${each.value.node_id}${var.switch_info.spine_id}.0"  # IPv4 Address
#    "config/prefix-length"      = 31                                                           # Subnet Mask (/31)
#  }
#}
#
#resource "iosxe_restconf" "loopback0_openconfig" {
#  path = "openconfig-interfaces:interfaces/interface=Loopback0"
#
#  attributes = {
#    name                = "Loopback0"
#    "config/name"       = "Loopback0"
#    "config/type"       = "iana-if-type:softwareLoopback"
#    "config/enabled"    = true
#  }
#}
#resource "iosxe_restconf" "loopback0_ipv4_config" {
#  path = "openconfig-interfaces:interfaces/interface=Loopback0/subinterfaces/subinterface=0/openconfig-if-ip:ipv4/addresses/address=10.240.255.${var.switch_info.spine_id}"
#
#  attributes = {
#    "ip"                        = "10.240.255.${var.switch_info.spine_id}"  # IPv4 Address
#    "config/ip"                 = "10.240.255.${var.switch_info.spine_id}"  # IPv4 Address
#    "config/prefix-length"      = 32                                          # Subnet Mask (/32)
#  }
#}

#resource "iosxe_restconf" "ospf_enable" {
#
#  path = "openconfig-network-instance:network-instances/network-instance=default/protocols/protocol=OSPF"
#
#  attributes = {
#    name = "1"
#    identifier = "OSPF"
#    "config/name" = "1"
#    "config/identifier" = "OSPF"
#  }
#}
#
#resource "iosxe_restconf" "ospf_global_config" {
#  depends_on = [iosxe_restconf.ospf_enable]
#
#  path = "openconfig-network-instance:network-instances/network-instance=default/protocols/protocol=OSPF,1/ospfv2/global/config"
#
#  attributes = {
#    "router-id" = "10.240.255.${var.switch_info.spine_id}"
#    "summary-route-cost-mode"       = "RFC1583_COMPATIBLE"
#    "log-adjacency-changes"         = true
#    "hide-transit-only-networks"    = false
#  }
#}

#
##god dam it
#resource "iosxe_restconf" "ospf_area0_config" {
#  depends_on = [iosxe_restconf.ospf_global_config]
#  path = "openconfig-network-instance:network-instances/network-instance=default/protocols/protocol=OSPF,1/ospfv2/areas/area=0"
#  attributes = {
#    "identifier" = 0
#    "config/identifier" = 0
#  }
#  lists = [{
#    name = "interfaces/interface"
#    key = "id,config/id,config/network-type,config/passive,config/priority"
#    items = concat([
#      for iface in local.ospf_interfaces : {
#        id = iface
#        "config/id" = iface
#        "config/network-type" = "openconfig-ospf-types:POINT_TO_POINT_NETWORK"
#        "config/priority" = 250
#      }],
#      [{
#        id = "Loopback0"
#        "config/id" = "Loopback0"
#        "config/passive" = true
#      }
#    ])
#  }]
#}


