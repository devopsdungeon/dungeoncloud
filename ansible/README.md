# Ansible Playbooks

## Struktur des Repositories

```sh
ansible-playbooks
├── group_vars/                 # Terraform-Umgebungen für verschiedene Deployments
│   ├── all.yaml                 # Variablen für alle Gruppen
│   └── <group1>/               # Beispiel für eine spezifische Umgebung (z. B. rancher, staging, production)
│       └── main.yaml            # Variablendatei in der Gruppe group1
├── roles/                      # Ansible Rollen
│   └── common/                 # Common-Rolle für Basis-Setup
├── ansible.cfg                 # Generelle Konfigurationsdatei für Ansible
├── common.yaml                  # Playbook für die Common-Rolle
├── hosts.yaml                   # Inventory im YAML-Format
├── README.md                   # Dokumentation des Repos
```

## Anforderungen
- Ansible >= 2.9.10

# Dry-Run
ansible-playbook -i hosts.yaml common.yaml -K --diff --check

# Run
ansible-playbook -i hosts.yaml common.yaml -K --diff
```