# OpenTofu VXLAN Homelab

**Overview:**  
A project using OpenTofu 1.9 to deploy a VXLAN network in a homelab combining physical and virtual devices.

**Hardware:**  
- 2 x Cisco Catalyst 9300 Spines  
- 2 x Cisco Catalyst 9300 Leaves  
- 6 x Virtual VyOS Leaves (on Proxmox)

**Software Versions:**  
- **IOS-XE:** 17.16.01 (min 17.15 for l2vpn-evpn default profiles)  
- **VyOS:** 1.5-rolling-202402060022

**Network Configurations:**  
- **MTU:**  
  - Outer: 9169  
  - Inner: 9119  
- **Underlay:** OSPF on `10.240.[leaf][spine].0/31` (point-to-point links)  
- **Overlay:** iBGP-EVPN on `10.240.[254-255].[id]/32` - Loopback
- **VXLAN:** Head-end replication

**Deployment Steps:**  
1. Configure physical (Cisco) and virtual (VyOS) devices.  
2. Deploy OpenTofu scripts to apply IPv4, OSPF, iBGP-EVPN, and VXLAN settings.  
3. Validate connectivity and encapsulation.
