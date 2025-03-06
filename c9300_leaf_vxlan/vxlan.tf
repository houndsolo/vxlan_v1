resource "iosxe" "set_nve1" {
  #write somethign here


  path = "Cisco-IOS-XE-native:native/interface/nve=1"
  attributes = {
    "Cisco-IOS-XE-native:nve":  = local.as_number

  }
}
