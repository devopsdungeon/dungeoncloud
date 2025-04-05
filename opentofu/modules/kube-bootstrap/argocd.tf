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
  depends_on = [kubectl_manifest.argocd_project_system]
  yaml_body  = <<YAML
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
  project: system
YAML
}

resource "kubectl_manifest" "argocd_app_system" {
  depends_on = [kubectl_manifest.argocd_repository_system]
  yaml_body  = <<YAML
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-system
  namespace: argocd
spec:
  project: system
  source:
    repoURL: https://github.com/devopsdungeon/dungeoncloud-cd-system.git
    path: argocd
    targetRevision: main
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
YAML
}
