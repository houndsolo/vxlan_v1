provider "iosxe" {
  alias = "c9300l"
  for_each = { for switch in var.leaf_switches: switch.hostname => switch }
  username = "admin"
  password = "admin"
  url =  each.value.url
}

provider "iosxe" {
  alias = "c9300s"
  for_each = { for switch in var.spine_switches: switch.hostname => switch }
  username = "admin"
  password = "admin"
  url =  each.value.url
}

provider "proxmox" {
  alias = "greatfox"
  endpoint = "https://10.2.0.20:8006"
  api_token = var.greatfox_api_key
  insecure = true
}

provider "proxmox" {
  endpoint = "https://10.2.0.11:8006"
  api_token = var.cluster_api_key
  insecure = true
}

provider "vyos" {
  alias = "leaves"
  for_each = { for leaf in var.leaves : leaf.node_id => leaf }
  endpoint ="https://10.20.1.${tostring(each.value.node_id)}"
  api_key  = var.vyos_key
  certificate = {
    disable_verify = true
  }
  default_timeouts = 2
  overwrite_existing_resources_on_create = true
}

provider "vyos" {
  alias = "greatfox"
  endpoint ="https://10.20.1.20"
  api_key  = var.vyos_key
  certificate = {
    disable_verify = true
  }
  default_timeouts = 2
  overwrite_existing_resources_on_create = true
}

provider "vyos" {
  alias = "border"
  endpoint ="https://10.20.1.80"
  api_key  = var.vyos_key
  certificate = {
    disable_verify = true
  }
  default_timeouts = 2
  overwrite_existing_resources_on_create = true
}

provider "vyos" {
  alias = "remote"
  endpoint ="https://10.20.1.80"
  api_key  = var.vyos_key
  certificate = {
    disable_verify = true
  }
  default_timeouts = 2
  overwrite_existing_resources_on_create = true
}

