# Proxmox

## Installation
- Wir installieren Proxmox auf 2 VMs
- Wir verwenden auf allen Maschinen ZFS
- Alle Server konfigurieren wir mir dem [Post-Install Helper Script](https://community-scripts.github.io/ProxmoxVE/scripts?id=post-pve-install) (ACHTUNG: Wir lassen die Clusterfunktion aktiv)
- Wir erstellen ein Proxmox Cluster anhand der [Dokumentation](https://pve.proxmox.com/wiki/Cluster_Manager)

## User
### Proxmox Gruppe erstellen und berechtigen
Wir erstellen eine Proxmox Gruppe und geben ihr eine gewünschte Berechtigung/Rolle (z.B. Administrator)

```sh
pveum group add admin -comment "System Administrators"
pveum acl modify / -group admin -role Administrator
```

### Benutzer erstellen
Auf allen Proxmox Servern den Linux-User erstellen

```sh
useradd -m -k /etc/skel -s /bin/bash testuser
sermod -aG sudo testuser
```

Den neuen User bei Proxmox hinzufügen und einer Gruppe hinzufügen

```sh
pveum user add testuser
pveum user modify testuser@pve -group admin
```
