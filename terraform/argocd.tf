provider "kubectl" {
      host                   = data.aws_eks_cluster.cluster.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
      token                  = data.aws_eks_cluster_auth.cluster.token
      load_config_file       = false
    
}



data "kubectl_path_documents" "ingress-nginx" {
    pattern = "../manifests/ingress/*.yaml"
}

resource "kubectl_manifest" "ingress-nginx" {
    for_each  = toset(data.kubectl_path_documents.ingress-nginx.documents)
    yaml_body = each.value
}

data "kubectl_file_documents" "namespace" {
    content = file("../manifests/argocd/namespace.yaml")
} 

resource "kubectl_manifest" "namespace" {
    count     = length(data.kubectl_file_documents.namespace.documents)
    yaml_body = element(data.kubectl_file_documents.namespace.documents, count.index)
    override_namespace = "argocd"
}

data "kubectl_file_documents" "argocd" {
    content = file("../manifests/argocd/install.yaml")
}

resource "kubectl_manifest" "argocd" {
    depends_on = [
      kubectl_manifest.namespace,
    ]
    count     = length(data.kubectl_file_documents.argocd.documents)
    yaml_body = element(data.kubectl_file_documents.argocd.documents, count.index)
    override_namespace = "argocd"
}

data "kubectl_file_documents" "argocd-ingress" {
    content = file("../manifests/argocd/argocd-ingress.yaml")
}

resource "kubectl_manifest" "argocd-ingress" {
    depends_on = [
      kubectl_manifest.argocd,
    ]
    count     = length(data.kubectl_file_documents.argocd-ingress.documents)
    yaml_body = element(data.kubectl_file_documents.argocd-ingress.documents, count.index)
    override_namespace = "argocd"
}

data "kubectl_file_documents" "app-of-apps" {
    content = file("../manifests/argocd/app-of-apps.yaml")
}

resource "kubectl_manifest" "app-of-apps" {
    depends_on = [
      kubectl_manifest.argocd,
    ]
    count     = length(data.kubectl_file_documents.app-of-apps.documents)
    yaml_body = element(data.kubectl_file_documents.app-of-apps.documents, count.index)
    override_namespace = "argocd"
}

data "kubectl_file_documents" "argocd-image-updater" {
    content = file("../manifests/argocd/argocd-image-updater.yaml")
}

resource "kubectl_manifest" "argocd-image-updater" {
    depends_on = [
      kubectl_manifest.argocd,
    ]
    count     = length(data.kubectl_file_documents.argocd-image-updater.documents)
    yaml_body = element(data.kubectl_file_documents.argocd-image-updater.documents, count.index)
    override_namespace = "argocd"
}