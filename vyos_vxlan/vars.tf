variable "spines" {
  type = number
}

variable "host_node" {
  description = "this node"
  type = object({
    hostname  = string
    host_node = string
    node_id   = number
    spine_connections    = list(object({
      spine_id   = number
      interface  = string
    }))
  })
}

variable "leaves" {
  type = list(object({
    hostname  = string
    host_node = string
    node_id   = number
    spine_connections    = list(object({
      spine_id   = number
      interface  = string
    }))
  }))
}

variable "vxlan_mtu" {
  type = number
}
variable "disable_arp_filter" {
  type = bool
}
variable "disable_forwarding" {
  type = bool
}
variable "enable_arp_accept" {
  type = bool
}
variable "enable_arp_announce" {
  type = bool
}
variable "enable_directed_broadcast" {
  type = bool
}
variable "enable_proxy_arp" {
  type = bool
}
variable "proxy_arp_pvlan" {
  type = bool
}
variable "vxlan_external" {
  type = bool
}
variable "vxlan_neighbor_suppress" {
  type = bool
}
variable "vxlan_nolearning" {
  type = bool
}
variable "vxlan_vni_filter" {
  type = bool
}

