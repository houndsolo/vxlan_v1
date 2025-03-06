locals {
}

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

variable "anycast_rp_address" {
  type = string
}

variable "rp_groups" {
  type = list(string)
}

