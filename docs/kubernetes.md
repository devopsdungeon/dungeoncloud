# Kubernetes

## Vorbereitungen der VM
- Wir verwenden das Ubuntu Cloud Image Template
    - 4 CPU Core
    - 8 GiB Memory
    - 20G Disk (System)
    - 50G Disk (k3s)
    - 150G Disk (CSI)
    - Cloud-Init konfigurieren

## Kubernetes Distro
- Wir verwenden k3s
- 3 Nodes mit embedded etcd (sowohl Controler, als auch Worker zugleich um Resourcen bei Proxmox zu sparen)
- Traefik und Flannel-CNI sollen nicht installiert werden
- Wir verwenden Cilium als CNI
- Wir verwenden NGINX Ingress Controller
- Wir aktivieren Encrytion at REST
- Data-Dir wird unter `/mnt/data` liegen (statt `/var/lib`)

### Installation
#### Vorbereitungen
Auf allen VM partitionieren wir die 50G Disk in ext4 und mounten diese Disk nach `/mnt/data`

#### Erste Node
**k3s installieren**

```sh
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.32.2+k3s1  \
K3S_TOKEN="GEHEIMERTOKEN" \
INSTALL_K3S_EXEC="server \
  --disable servicelb \
  --disable traefik \
  --flannel-backend=none \
  --disable-network-policy \
  --secrets-encryption=true \
  --kube-apiserver-arg=default-not-ready-toleration-seconds=60 \
  --kube-apiserver-arg=default-unreachable-toleration-seconds=60 \
  --tls-san=10.123.1.15 \
  --tls-san=10.123.1.16 \
  --tls-san=10.123.1.15 \
  --tls-san=10.123.1.15 \
  --tls-san=kube-test.intern.devopsdungeon.net \
  --tls-san=kube-test-1.intern.devopsdungeon.net \
  --tls-san=kube-test-2.intern.devopsdungeon.net \
  --tls-san=kube-test-3.intern.devopsdungeon.net \
  --cluster-init" \
sh -
```

**Data-Dir anpassen**

- k3s stoppen und VM neustarten

```sh
systemctl disable k3s
systemctl stop k3s
shutdown -r now
```

- k3s config einrichten (`/etc/rancher/k3s/config.yaml`)

```yaml
---
data-dir: /mnt/data/rancher/k3s
kubelet-arg:
  - 'root-dir=/mnt/data/kubelet'
```

- k3s starten und sicherheitshalber Symlinks einrichten

```sh
mv /var/lib/rancher /mnt/data/
mv /var/lib/kubelet /mnt/data/
ln -s /mnt/data/rancher /var/lib/rancher
ln -s /mnt/data/kubelet /var/lib/kubelet
systemctl enable k3s
systemctl start k3s
```

**Cilium CNI installieren**

```sh
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
cilium install --version 1.17.2 --set=ipam.operator.clusterPoolIPv4PodCIDRList="192.168.42.0/16"
cilium status
```

** kube-vip für Failover-IP konfigurieren

```sh
curl https://kube-vip.io/manifests/rbac.yaml > /mnt/data/rancher/k3s/server/manifests/kube-vip-rbac.yaml
export VIP=10.123.1.15
export INTERFACE=eth0
KVVERSION=$(curl -sL https://api.github.com/repos/kube-vip/kube-vip/releases | jq -r ".[0].name")
alias kube-vip="ctr image pull ghcr.io/kube-vip/kube-vip:$KVVERSION; ctr run --rm --net-host ghcr.io/kube-vip/kube-vip:$KVVERSION vip /kube-vip"
kube-vip manifest daemonset \
    --interface $INTERFACE \
    --address $VIP \
    --inCluster \
    --taint \
    --controlplane \
    --services \
    --arp \
    --leaderElection > /mnt/data/rancher/k3s/server/manifests/kube-vip.yaml
```

#### Restliche Nodes

**k3s installieren**

```sh
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.32.2+k3s1 \
K3S_TOKEN="8tN3mEY97jcV9eJIKIpzZ5Bi" \
INSTALL_K3S_EXEC="server \
  --disable servicelb \
  --disable traefik \
  --flannel-backend=none \
  --disable-network-policy \
  --secrets-encryption=true \
  --kube-apiserver-arg=default-not-ready-toleration-seconds=60 \
  --kube-apiserver-arg=default-unreachable-toleration-seconds=60 \
  --tls-san=10.123.1.15 \
  --tls-san=10.123.1.16 \
  --tls-san=10.123.1.15 \
  --tls-san=10.123.1.15 \
  --tls-san=kube-test.intern.devopsdungeon.net \
  --tls-san=kube-test-1.intern.devopsdungeon.net \
  --tls-san=kube-test-2.intern.devopsdungeon.net \
  --tls-san=kube-test-3.intern.devopsdungeon.net \
  --server https://10.123.1.15:6443" \
sh -
```

**Data-Dir anpassen**

- k3s stoppen und VM neustarten

```sh
systemctl disable k3s
systemctl stop k3s
shutdown -r now
```

- k3s config einrichten (`/etc/rancher/k3s/config.yaml`)

```yaml
---
data-dir: /mnt/data/rancher/k3s
kubelet-arg:
  - 'root-dir=/mnt/data/kubelet'
```

- k3s starten und sicherheitshalber Symlinks einrichten

```sh
mv /var/lib/rancher /mnt/data/
mv /var/lib/kubelet /mnt/data/
ln -s /mnt/data/rancher /var/lib/rancher
ln -s /mnt/data/kubelet /var/lib/kubelet
systemctl enable k3s
systemctl start k3s
```
