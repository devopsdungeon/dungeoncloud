# Proxmox

## Installation
- Wir installieren Proxmox auf 2 VMs
- Wir verwenden auf allen Maschinen ZFS
- Alle Server konfigurieren wir mir dem [Post-Install Helper Script](https://community-scripts.github.io/ProxmoxVE/scripts?id=post-pve-install) (ACHTUNG: Wir lassen die Clusterfunktion aktiv)
- Wir erstellen ein Proxmox Cluster anhand der [Dokumentation](https://pve.proxmox.com/wiki/Cluster_Manager)

### Quorum
Da unser aktuelles Cluster nur aus zwei Nodes besteht, brauchen wir ein externes Quorum-Devices,
damit ein vollständiges HA-Cluster gewährleistet werden kann.
Dafür installieren wir auf einem externe Device (z.B. Raspberry Pi) den `QDevice daemon`.
Anschließend folgen wir den [Schritten in der Dokumentation](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#_corosync_external_vote_support).

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
usermod -aG sudo testuser
passwd testuser
```

Den neuen User bei Proxmox hinzufügen und einer Gruppe hinzufügen

```sh
pveum user add testuser
pveum user modify testuser@pve -group admin
```

## Templates
### Ubuntu Cloud Init

```sh
qm create 5000 --memory 2048 --core 2 --name ubuntu-cloud-24-04 --net0 virtio,bridge=vxlan1
cd /var/lib/vz/template/iso/
qm importdisk 5000 lunar-server-cloudimg-amd64-disk-kvm.img local-zfs
qm set 5000 --scsihw virtio-scsi-pci --scsi0 local-zfs:vm-5000-disk-0
qm set 5000 --ide2 local-zfs:cloudinit
qm set 5000 --boot c --bootdisk scsi0
qm set 5000 --serial0 socket --vga serial0
qm disk resize 5000 scsi0 10G
```

#### VM Hardware
- Memory: balloon=0
- Processors -> Type: host

#### Cloud Init
Setup der gewünschten Werte. IP Config DHCP.

#### Template erstellen
- Rechtsklick auf Maschine und `Convert to template`
- Replication für Template einrichten
