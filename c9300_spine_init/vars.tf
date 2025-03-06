variable "switch_info" {
  type = object({
    hostname = string
    node_id  = number
    url      = string
    spine_id  = string
  })
  description = "Single switch object from the top-level switches list"
}

variable "spines" {
  type = number
}

variable "leaves" {
  description = "full mesh peering info"
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
variable "leaf_switches" {
  description = "ios xe leaf switches"
  type = list(object({
    hostname  = string
    node_id   = number
    url       = string
    leaf_id  = string
  }))
}
