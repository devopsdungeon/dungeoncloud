resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.7.13"
  namespace        = "argocd"
  create_namespace = true
  values = [
    "${file("${path.module}/argocd/values.yaml")}"
  ]
}

resource "kubectl_manifest" "argocd_project_system" {
  depends_on = [helm_release.argocd]
  yaml_body  = <<YAML
---
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: system
  namespace: argocd
  # Finalizer that ensures that project is not deleted until it is not referenced by any application
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  destinations:
  - namespace: '*'
    server: '*'
  sourceRepos:
  - '*'
YAML
}

resource "kubectl_manifest" "argocd_repository_system" {
  depends_on = [
    helm_release.argocd,
    kubectl_manifest.argocd_project_system
  ]
  yaml_body = <<YAML
---
apiVersion: v1
kind: Secret
metadata:
  name: kubernetes-repository-system
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/devopsdungeon/dungeoncloud-cd-system.git
YAML
}
