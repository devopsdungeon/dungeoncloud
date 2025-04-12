# NFS-subdir-external-provisioner
Der NFS-subdir-external-provisioner ist ein Kubernetes CSI, welches Volumes bei einem bestehen NFS Server verwalten kann.

## Installation eines NFS Server
- Wir erstellen in Proxmox einen neuen **privilegierten** LXC, weil NFS mehr Rechte bei den Kernelparametern braucht
    - Wir geben dem NFS eine Datenpartition, die wir unter `/mnt/data` mounten
    - In dieser Datenpartition erstellen wir einen neuen Ordner `/mnt/data/nfs`
- Zum einrichten eines NFS Server verwenden wir [diese Ansible Role](https://github.com/geerlingguy/ansible-role-nfs)
- Das [Playbook](https://github.com/devopsdungeon/dungeoncloud/blob/main/ansible/nfs.yaml) bekommt folgende [Ansible-Vars](https://github.com/devopsdungeon/dungeoncloud/blob/main/ansible/group_vars/storage.yaml)
