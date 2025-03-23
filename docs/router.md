# Router

## Vorraussetzung
Für die Installtion des Routers wird ein SDN mit VXLAN benötigt

## Planung
Wir erstellen einen virtualisierten OPNSense Router. Die VM wird zunächst zwei Interfaces besitzen. 
Ein Interface, das sich im Proxmox Cluster befindet (WAN) und ein Interface, welches sich im VXLAN (LAN) befindet.

## Installation und Konfiguration von OPNSense
### Allgemein
- OPNSense herunterladen
- VM erstellen (2 Kerne, 2-4 GB RAM)
- Installation durchführen und Netzwerkinterfaces konfigurieren
- Sobald Router gebootet ist, schalten wir die Firewall temporär mit `pfctl -d` aus.
- Wir rufen die WebUI von OPNSense im Router auf
- Interfaces -> WAN
- Deaktiviere `Block private networks` (Weil WAN ein privates Netzwerk ist)
- Firewall -> Rules -> WAN
- `IPv4 * 	* 	* 	WAN address 	* 	* 	* 		Allow access from WAN to router` (Optional. Wird eingerichtet, weil WAN ein sicheres, privates Netzwerk ist. Ansonsten brauchen wir einen Jumphost im LAN)

### Virtual-IP
- Ein neues VXLAN erstellen (ID=99)
- OPNsense ein neues Netzwerinterface hinzufügen im VXLAN99
- Interface bei OPNsense aktivieren und bennen (`pfsync`)
- Unter `Interfaces` -> `Virtual IPs` -> `Setting` eine neue IP anlegen
    - Address: `10.123.1.1/24`
    - VHID: `1`
    - Interface: `LAN`
    - Type: `CARP`
- Unter `Firewall` -> `NAT` -> `Outbund` eine neue Regel erstellen
    - Interface: `pfsync`
    - Source: `LAN net`
    - NAT Address: `psync address`
    - Rest bleibt default
- Unter `Firewall` -> `Rules` -> `pfsync` eine INBOUND Rule die alles erlaubt
- Grundsätzlich kann man dem Setup ein Failover-System mit einem zweiten OPNsense Router bauen.
- Wir verzichten bewusst auf ein HA-Setup und verlassen und auf das Failover von Proxmox, um CPU/RAM zu sparren.
