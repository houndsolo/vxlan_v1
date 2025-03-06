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

variable "bgp_l2vpn_her" {
  type = bool
}
variable "bgp_l2vpn_flooding_disable" {
  type = bool
}
variable  "bgp_l2vpn_advertise_svi" {
  type = bool
}
variable  "bgp_l2vpn_advertise_vni" {
  type = bool
}
variable  "bgp_l2vpn_vni_advertise_svi" {
  type = bool
}
