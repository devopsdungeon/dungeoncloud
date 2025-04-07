# Opentofu
Opentofu ist ein Open Source Fork von Terraform. 
Mit Opentofu können wir rückwärtskompatibel alle Terraform-Funktionen durchführen.

## Vorbereitungen
Wir verwenden Opentofu in erster Linie, um die Boostrap-Applikatinen
(MetalLB, Ingress Controller, Cert-Manager, ArgoCD, etc.) zu installieren und konfigurieren.
Alle restlichen Applikationen werden via GitOps mit ArgoCD deployt.

Für die einrichten von Kubernetes Resourcen via Opentofu verwenden wir die Provider `hashicorp/helm`
und `gavinbunney/kubectl`

## Durchführung
Im folgenden werden die Boostrap Applikatinen aufgelistet, die zum initialisieren des Cluster notwendig sind.

### MetalLB
MetalLB ermöglicht es via L2 advertisment dem Bare-Metal Kubernetes Cluster externe IPs zu vergeben.
In unserem Fall verwenden wir den Pool `10.123.1.100-10.123.1.149` für externe IPs.

### Ingress Nginx
Ingress Nginx ist der L7 Reverse Proxy, der HTTP Endpoints zum Cluster bereitsstellt

### Sealed-Secrets
Mit Sealed-Secrets können wir Kubernetes Secrets verschlüsseln und sich sicher in Git hinterlegen.

### Cert-Manager
Cert-Manager verwaltet die PKI (TLS/x509/CSR) innerhalb von Kubernetes. In unsererm Fall binden wir
einen Cloudflare Token, um via Cloudflare eine DNS-Lets-Encrypt-Challange durchzuführen.
Damit haben wir valida TLS Zertifikate für unsere Ingress Endpoints.

### ArgoCD
ArgoCD ist unser GitOps Tool. Nach der Installation von ArgoCD verbinden wir ihn mit dem [CD-Repository](https://github.com/devopsdungeon/dungeoncloud-cd-system/tree/main).
In diesem Repository sind alle restlichen Applikatinen definiert. Diese Applikatinen werden von ArgoCD installiert und verwaltet.
