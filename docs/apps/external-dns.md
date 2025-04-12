# external-dns

## Vorbereitungen
### Zones

`/var/lib/bind/zones/intern.devopsdungeon.net`

```
$ORIGIN .
$TTL 60        ; 1 minutes
intern.devopsdungeon.net IN SOA nis-1.intern.devopsdungeon.net. info.nis-1.intern.devopsdungeon.net. (
                                2025041202 ; serial
                                10800      ; refresh (3 hours)
                                600        ; retry (10 minutes)
                                604800     ; expire (1 week)
                                600        ; minimum (10 minutes)
                                )
                        NS      nis-1.intern.devopsdungeon.net.
nis-1                   A       10.102.125.2
```

`/var/lib/bind/zones/1.123.10.in-addr.arpa`

```
$TTL 60
@ IN SOA nis-1.intern.devopsdungeon.net. info.nis-1.intern.devopsdungeon.net. (
    2025041201 ; serial
    3h ; refresh
    10m ; retry
    7d ; expire
    10m ; TTL
)

@    IN NS  nis-1.intern.devopsdungeon.net.

2  IN  PTR  nis-1.intern.devopsdungeon.net.
```

## Ansible

```shell
ansible-playbook -i hosts.yaml bind.yaml -K --diff --ask-vault-pass --check
ansible-playbook -i hosts.yaml bind.yaml -K --diff --ask-vault-pass
```