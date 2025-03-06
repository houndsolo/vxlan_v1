module "c9300_leaf_init" {
  source = "./c9300_leaf_init"
  for_each = { for switch in var.leaf_switches: switch.hostname => switch }
  providers = { iosxe = iosxe.c9300l[each.key] }
  switch_info = each.value
  spines = var.spines
}

module "c9300_leaf_underlay" {
  depends_on = [module.c9300_leaf_init]
  source = "./c9300_leaf_underlay"
  for_each = { for switch in var.leaf_switches: switch.hostname => switch }
  providers = { iosxe = iosxe.c9300l[each.key] }
  switch_info = each.value
  spines = var.spines
}

module "c9300_leaf_bgp" {
  depends_on = [module.c9300_leaf_underlay]
  source = "./c9300_leaf_bgp"
  for_each = { for switch in var.leaf_switches: switch.hostname => switch }
  providers = { iosxe = iosxe.c9300l[each.key] }
  switch_info = each.value
  spines = var.spines
}



module "c9300_spine_init" {
  source = "./c9300_spine_init"
  for_each = { for switch in var.spine_switches: switch.hostname => switch }
  #for_each = { for switch in slice(var.spine_switches, 0, 1): switch.hostname => switch }
  providers = { iosxe = iosxe.c9300s[each.key] }
  switch_info = each.value
  leaves= var.leaves
  leaf_switches = var.leaf_switches
  spines = var.spines
}

module "c9300_spine_underlay" {
  depends_on = [module.c9300_spine_init]
  source = "./c9300_spine_underlay"
  for_each = { for switch in var.spine_switches: switch.hostname => switch }
  #for_each = { for switch in slice(var.spine_switches, 0, 1): switch.hostname => switch }
  providers = { iosxe = iosxe.c9300s[each.key] }
  switch_info = each.value
  leaf_switches = var.leaf_switches
  leaves= var.leaves
  spines = var.spines
  rp_groups = var.rp_groups
  anycast_rp_address = var.anycast_rp_address
}

module "c9300_spine_bgp" {
  depends_on = [module.c9300_spine_underlay]
  source = "./c9300_spine_bgp"
  for_each = { for switch in var.spine_switches: switch.hostname => switch }
  #for_each = { for switch in slice(var.spine_switches, 0, 1): switch.hostname => switch }
  providers = { iosxe = iosxe.c9300s[each.key] }
  switch_info = each.value
  leaves= var.leaves
  spines = var.spines
  leaf_switches = var.leaf_switches
}

module "leaves_vms" {
  for_each = { for leaf in var.leaves : leaf.node_id => leaf }
  source = "./vteps"
  host_node = each.value
  leaves= var.leaves
  spines = var.spines
}

module "vyos_init" {
  depends_on = [module.leaves_vms]
  for_each = { for leaf in var.leaves : leaf.node_id => leaf }
  source = "./vyos_init"
  providers = { vyos = vyos.leaves[each.key] }
  host_node = each.value
  leaves= var.leaves
  spines = var.spines
  rp_groups = var.rp_groups
  anycast_rp_address = var.anycast_rp_address
}

module "vyos_bgp" {
  depends_on = [module.vyos_init]
  for_each = { for leaf in var.leaves : leaf.node_id => leaf }
  source = "./vyos_bgp"
  providers = { vyos = vyos.leaves[each.key] }
  host_node = each.value
  leaves= var.leaves
  spines = var.spines
  bgp_l2vpn_her = local.bgp_l2vpn_her
  bgp_l2vpn_flooding_disable = local.bgp_l2vpn_flooding_disable
  bgp_l2vpn_advertise_svi =  local.bgp_l2vpn_advertise_svi
  bgp_l2vpn_advertise_vni =  local.bgp_l2vpn_advertise_vni
  bgp_l2vpn_vni_advertise_svi =  local.bgp_l2vpn_vni_advertise_svi

}

module "vyos_vxlan" {
  depends_on = [module.vyos_bgp]
  for_each = { for leaf in var.leaves : leaf.node_id => leaf }
  source = "./vyos_vxlan"
  providers = { vyos = vyos.leaves[each.key] }
  host_node = each.value
  leaves= var.leaves
  spines = var.spines

  vxlan_mtu = local.vxlan_mtu
  disable_arp_filter = local.disable_arp_filter
  disable_forwarding = local.disable_forwarding
  enable_arp_accept = local.enable_arp_accept
  enable_arp_announce = local.enable_arp_announce
  enable_directed_broadcast = local.enable_directed_broadcast
  enable_proxy_arp = local.enable_proxy_arp
  proxy_arp_pvlan = local.proxy_arp_pvlan
  vxlan_external = local.vxlan_external
  vxlan_neighbor_suppress = local.vxlan_neighbor_suppress
  vxlan_nolearning = local.vxlan_nolearning
  vxlan_vni_filter = local.vxlan_vni_filter
}
