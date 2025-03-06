locals {
  dum0_network = "10.240.255.${var.host_node.node_id}/32"
  bgp_system_as = 700
}

resource "vyos_protocols_bgp" "enable_bgp" {
  system_as = local.bgp_system_as
}

resource "vyos_protocols_bgp_address_family_ipv4_unicast_maximum_paths" "bgp_multipath" {
  depends_on = [vyos_protocols_bgp.enable_bgp]
  ibgp = 2
}

#resource "vyos_protocols_bgp_address_family_ipv4_unicast_network" "bgp_advertise_dum0" {
#  # would rather do ospf on interface[, but can only for ipv6??] -> redistribute into bgp
#  depends_on = [vyos_protocols_bgp.enable_bgp]
#  identifier = {
#    network = local.dum0_network
#  }
#}



resource "vyos_protocols_bgp_address_family_l2vpn_evpn" "l2vpn_evpn_config" {
  depends_on = [vyos_protocols_bgp.enable_bgp]
  advertise_all_vni = var.bgp_l2vpn_advertise_vni
  #advertise_svi_ip = var.bgp_l2vpn_advertise_svi
  rt_auto_derive = false
}

resource "vyos_protocols_bgp_address_family_l2vpn_evpn_flooding" "l2vpn_evpn_flooding" {
  depends_on = [vyos_protocols_bgp_address_family_l2vpn_evpn.l2vpn_evpn_config]
  disable = var.bgp_l2vpn_flooding_disable
  head_end_replication = var.bgp_l2vpn_her
}


resource "vyos_protocols_bgp_peer_group" "peer_group_spine" {
  depends_on = [vyos_protocols_bgp.enable_bgp]
  identifier = {peer_group = "peer_group_spine"}
  update_source = "dum0"
  remote_as = tostring(local.bgp_system_as)
  address_family = {
    ipv4_unicast = {
      soft_reconfiguration = {inbound = true}
      nexthop_self = {}
    }
    l2vpn_evpn = {
      soft_reconfiguration = {inbound = true}
      nexthop_self = {}
    }
  }
}

#resource "vyos_protocols_bgp_address_family_l2vpn_evpn_advertise_ipv4_unicast" "l2vpn_advertise_ipv4" {
#  route_map =
#}

resource "vyos_protocols_bgp_address_family_l2vpn_evpn_vni" "vni_6" {
  depends_on = [vyos_protocols_bgp_address_family_l2vpn_evpn.l2vpn_evpn_config]
  identifier = { vni = 9006 }
  #advertise_default_gw = true
  #advertise_svi_ip     = var.bgp_l2vpn_vni_advertise_svi
}


resource "vyos_protocols_bgp_neighbor" "bgp_neighbors" {
  count      = var.spines
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_spine]
  identifier = { neighbor = "10.240.255.${count.index + 1}" } # Adjust IP pattern as needed
 # identifier = { neighbor = "10.240.255.1" } # Adjust IP pattern as needed
  peer_group = "peer_group_spine"
  #remote_as = local.bgp_system_as
}

