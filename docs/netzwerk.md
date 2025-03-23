# Netzwerk

## Proxmox SDN mit VXLAN
Bei einem Proxmox-Cluster mit mehreren Knoten ist es sinnvoll ein SDN mit VXLAN zu erstellen. Das ermöglicht uns z.B.die Verwendung von Layer 2 Protokolen (ARP, DHCP Request, etc) über ein virtuelles Netzwerk hinweg.

Um ein SDN zu erstellen befolgen wir folgende Schritte
- Klick auf `Datacenter`
- SDN -> Zones
- Erstelle eine Zone VXLAN Zone (WICHTIG: `MTU=1450`)
- SDN -> VNets
- Erstelle ein VNet mit den entsprechenden VXLAN Zone und einem Tag (z.B. `Tag=1`)
- SDN -> VNets -> Subnets
- Erstelle ein Subnet (z.B. `10.123.1.0/24`)
- Gateway und SNAT bleiben leer -> wird vom OPNSense Router übernommen
- SDN -> Apply
