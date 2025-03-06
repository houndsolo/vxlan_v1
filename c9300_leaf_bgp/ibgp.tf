locals {
  as_number = "700"
}


resource "iosxe_restconf" "bgp_enable" {
  path = "Cisco-IOS-XE-native:native/router"

  attributes = {
    "Cisco-IOS-XE-bgp:bgp/id"  = local.as_number
    "Cisco-IOS-XE-bgp:bgp/bgp/log-neighbor-changes" = true
    "Cisco-IOS-XE-bgp:bgp/bgp/default/ipv4-unicast" = false
    "Cisco-IOS-XE-bgp:bgp/bgp/default/route-target/filter" = false
  }

  lists = [
    {
      name = "Cisco-IOS-XE-bgp:bgp/neighbor"
      key  = "id,remote-as"
      items = [
      for leaf in [1,2]: {
        "id"                                  = "10.240.255.${leaf}"
        "remote-as"                           = "700"
        "update-source/interface/Loopback"    = 0
        "ebgp-multihop-v2/max-hop"    = "4"
        "ebgp-multihop-v2/enable"    = ""
      }]
    },
    {
      name = "Cisco-IOS-XE-bgp:bgp/address-family/no-vrf/l2vpn"
      key  = "af-name"
      items = [
      for leaf in [1,2]: {
        "af-name"                                = "evpn"
        "l2vpn-evpn/neighbor/id"              = "10.240.255.${leaf}"
        "l2vpn-evpn/neighbor/soft-reconfiguration"     = "inbound"
        "l2vpn-evpn/neighbor/send-community/send-community-where"     = "both"
        "l2vpn-evpn/neighbor/activate"     = ""
      }]
    }
  ]
}
