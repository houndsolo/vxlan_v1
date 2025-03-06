variable "switch_info" {
  type = object({
    hostname = string
    node_id  = number
    url      = string
    leaf_id  = string
  })
  description = "Single switch object from the top-level switches list"
}

variable "spines" {
  type = number
}

