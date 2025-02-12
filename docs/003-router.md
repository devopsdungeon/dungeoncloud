# Router

## Vorraussetzung
Für die Installtion des Routers wird ein SDN mit VXLAN benötigt

## Planung
Wir erstellen einen virtualisierten OPNSense Router. Die VM wird zunächst zwei Interfaces besitzen. 
Ein Interface, das sich im Proxmox Cluster befindet (WAN) und ein Interface, welches sich im VXLAN (LAN) befindet.

## Installation und Konfiguration von OPNSense
- OPNSense herunterladen
- VM erstellen (2 Kerne, 2-4 GB RAM)
- Installation durchführen und Netzwerkinterfaces konfigurieren
- Sobald Router gebootet ist, schalten wir die Firewall temporär mit `pfctl -d` aus.
- Wir rufen die WebUI von OPNSense im Router auf
- Interfaces -> WAN
- Deaktiviere `Block private networks` (Weil WAN ein privates Netzwerk ist)
- Firewall -> Rules -> WAN
- `IPv4 * 	* 	* 	WAN address 	* 	* 	* 		Allow access from WAN to router` (Optional. Wird eingerichtet, weil WAN ein sicheres, privates Netzwerk ist. Ansonsten brauchen wir einen Jumphost im LAN)
