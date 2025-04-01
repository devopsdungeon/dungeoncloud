resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.17.0"
  namespace        = "cert-manager"
  create_namespace = true
  set {
    name  = "crds.enabled"
    value = "true"
  }
}

resource "kubectl_manifest" "cloudflare_api_token_secret" {
  depends_on = [
    helm_release.cert_manager,
    helm_release.sealed_secrets
  ]
  yaml_body = <<YAML
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: cloudflare-api-token-secret
  namespace: cert-manager
spec:
  encryptedData:
    api-token: AgAk8aw0owYdsUTxgcC0hRPOPJ6VErNS08MKodYb2hin/92rWg+yu/A/Zp5kaBXZOrxrLWL/LGfjRyM+WUwrlEZsMYHBPiD2wgB4lE9mzWGw/St73gKsYYs6DD9hyCNHg8Xn6u2lmLI3ObCy+i68yIKA7oKN8yGSV8Zx24ZCMa/ElY9ehL+CoYEv/X0eRiPM4zhi5z9xc7h2LirVbms9Ln62/6GLfHuIYrzSqT0r4HT+1EiyLt/1amMJeSFMem0H9UJacrcCQMTT0wg0rJHyOlqLv5MqkT7cPNBv2mEToVLMAUX9Pce8ObfZsPNnlBFkru3xZzarlpsH8iTM27LvTRbf935pEMh0KGSM30aLCuYv+JinnvI48tpc+dJpaHvlzvFx+2h6cjJras97FzThQuScDrYiavgSPIsirMQjYBU3y7kNDP6wKWbBFDqBhYLWaB6anY+LANlaKzdRFnweYsKnPxBkiacyeclF9MqurMDBqhJ/542Uv3u0x1rkk0UtrsrqAnymKcBGuUARI1poECl2uagKLiLP9cPKKyreGJKYvBSEhiUUzsSulp4F4hSUvPvIc5OxkbWWwMdQ3dVXwhTxs/HYZsriu22eXT1MvcpJKvMBmFq5kjJjBF5seZWZ/FWDgYFRLVuGeqkBNApPZH/26tSmCujb4IQzhtuBciE6eWeKKga8E2752WmPAKA3Ji+zUZ1pR7yYh6/lQ5tWIo1dkDlGJja5uhhKLnd/fqROF9hYK4XW2ZAx
  template:
    metadata:
      name: cloudflare-api-token-secret
      namespace: cert-manager
    type: Opaque
YAML
}

resource "kubectl_manifest" "cert_manager_le_staging_clusterissuer" {
  depends_on = [
    helm_release.cert_manager,
    kubectl_manifest.cloudflare_api_token_secret
  ]
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging-dns01-issuer
  namespace: cert-manager
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ${var.le_email}
    privateKeySecretRef:
      name: letsencrypt-staging-dns01-private-key
    solvers:
    - dns01:
        cloudflare:
          apiTokenSecretRef:
            name: cloudflare-api-token-secret
            key: api-token
YAML
}

resource "kubectl_manifest" "cert_manager_le_clusterissuer" {
  depends_on = [
    helm_release.cert_manager,
    kubectl_manifest.cloudflare_api_token_secret
  ]
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-dns01-issuer
  namespace: cert-manager
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${var.le_email}
    privateKeySecretRef:
      name: letsencrypt-dns01-private-key
    solvers:
    - dns01:
        cloudflare:
          apiTokenSecretRef:
            name: cloudflare-api-token-secret
            key: api-token
YAML
}
