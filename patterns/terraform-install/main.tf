provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

################################################################################
# Linkerd Namespace
################################################################################
resource "kubernetes_namespace" "linkerd" {
  metadata {
    annotations = {
      name = var.linkerd_namespace
    }
    name        = var.linkerd_namespace
  }
}

################################################################################
# Linkerd Custom Resource Definitions
################################################################################
resource "helm_release" "linkerd_crds" {
  depends_on = [ kubernetes_namespace.linkerd ]

  name       = "linkerd-crds"
  namespace  = var.linkerd_namespace
  repository = var.linkerd_helm_registry_url
  chart      = "linkerd-crds"
}

################################################################################
# Linkerd Control Plane
################################################################################
resource "helm_release" "linkerd_ctl_plane_mtls" {
  depends_on = [ kubernetes_namespace.linkerd, helm_release.linkerd_crds ]

  name       = "linkerd-control-plane"
  namespace  = var.linkerd_namespace
  repository = var.linkerd_helm_registry_url
  chart      = "linkerd-control-plane"


  set {
    name  = "identityTrustAnchorsPEM"
    value = file( var.identity_trust_anchor_file )
  }

  set {
    name  = "identity.issuer.tls.crtPEM"
    value = file( var.identity_issuer_certificate_file )
  }

  set {
    name  = "identity.issuer.tls.keyPEM"
    value = file( var.identity_issuer_key_file )
  }

  values = [
    file( "linkerd-values.yaml" )
  ]

}
