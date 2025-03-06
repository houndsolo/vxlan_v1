locals {
  vxlan_mtu = 9119
  disable_forwarding = false
  disable_arp_filter = true
  enable_arp_accept = false
  enable_arp_announce = false
  enable_directed_broadcast = true
  enable_proxy_arp = false
  proxy_arp_pvlan = false

  vxlan_external = true
  vxlan_neighbor_suppress = false
  vxlan_nolearning = true
  vxlan_vni_filter = false

  bgp_l2vpn_flooding_disable = false
  bgp_l2vpn_her = true
  bgp_l2vpn_advertise_svi = true
  bgp_l2vpn_advertise_vni = true
  bgp_l2vpn_vni_advertise_svi = true
}

variable "anycast_rp_address" {
  type = string
  default = "10.240.255.250"
}

variable "rp_groups" {
  type = list(string)
  default = ["227.0.0.0/8"]
}


variable "spines" {
  type = number
  default = 2
}


variable "leaf_switches" {
  description = "ios xe leaf switches"
  type = list(object({
    hostname  = string
    node_id   = number
    url       = string
    leaf_id  = string
  }))
  default = [
    {
      hostname  = "switch9"
      node_id   = 9
      url       = "https://10.20.0.9"
      leaf_id  = 1
    },
    #{
    #  hostname  = "switch10"
    #  node_id   = 10
    #  url       = "https://10.20.0.10"
    #  leaf_id  = 2
    #},
  ]
}

variable "spine_switches" {
  description = "ios xe switches"
  type = list(object({
    hostname  = string
    node_id   = number
    url       = string
    spine_id  = string
  }))
  default = [
    {
      hostname  = "switch7"
      node_id   = 7
      url       = "https://10.20.0.7"
      spine_id  = 1
    },
    #{
    #  hostname  = "switch8"
    #  node_id   = 8
    #  url       = "https://10.20.0.8"
    #  spine_id  = 2
    #},
  ]
}

variable "leaves" {
  description = "List of network nodes with their details."
  type = list(object({
    hostname  = string
    host_node = string
    node_id   = number
    spine_connections    = list(object({
      spine_id   = number
      interface  = string
    }))
  }))
  default = [
    {
      hostname  = "vtep-fichina"
      host_node = "fichina"
      node_id   = 10
      spine_connections = [
        { spine_id = 1, interface = "1/0/14" },
        { spine_id = 2, interface = "1/0/8" }
      ]
    },
    {
      hostname  = "vtep-fortuna"
      host_node = "fortuna"
      node_id   = 11
      spine_connections = [
        { spine_id = 1, interface = "1/0/5" },
        { spine_id = 2, interface = "1/0/13" }
      ]
    },
    {
      hostname  = "vtep-macbeth"
      host_node = "macbeth"
      node_id   = 12
      spine_connections = [
        { spine_id = 1, interface = "1/0/15" },
        { spine_id = 2, interface = "1/0/6" }
      ]
    },
    {
      hostname  = "vtep-titania"
      host_node = "titania"
      node_id   = 13
      spine_connections = [
        { spine_id = 1, interface = "1/0/13" },
        { spine_id = 2, interface = "1/0/5" }
      ]
    },
    {
      hostname  = "vtep-zoness"
      host_node = "zoness"
      node_id   = 14
      spine_connections = [
        { spine_id = 1, interface = "1/0/6" },
        { spine_id = 2, interface = "1/0/15" }
      ]
    },
    {
      hostname  = "vtep-venom"
      host_node = "venom"
      node_id   = 17
      spine_connections = [
        { spine_id = 1, interface = "1/0/16" },
        { spine_id = 2, interface = "1/0/7" }
      ]
    },
    #{
    #  hostname  = "vtep-fi-border"
    #  host_node = "fichina"
    #  node_id   = 18
    #  spine_connections = [
    #    { spine_id = 1, interface = "1/0/3" },
    #    { spine_id = 2, interface = "1/0/3" }
    #  ]
    #},
    #{
    #  hostname  = "vtep-ti-border"
    #  host_node = "titania"
    #  node_id   = 19
    #  spine_connections = [
    #    { spine_id = 1, interface = "1/0/4" },
    #    { spine_id = 2, interface = "1/0/4" }
    #  ]
    #}
  ]
}

