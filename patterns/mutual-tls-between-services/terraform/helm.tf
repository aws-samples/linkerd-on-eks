resource "helm_release" "linkerd" {
  name       = "linkerd"
  namespace  = "linkerd"
  chart      = "linkerd2"
  repository = "https://helm.linkerd.io/stable"
  #version    = var.linkerd_version
  version    = "2.15"
  atomic = true
  values = [
    file("values-ha.yaml")
  ]
  set {
    name  = "linkerdVersion"
    value = "stable-2.10.2"
  }
  set_sensitive {
    name  = "identityTrustAnchorsPEM"
    value = data.terraform_remote_state.cm_crds.outputs.cert
  }
  set {
    name  = "identity.issuer.scheme"
    value = "kubernetes.io/tls"
  }
  set {
    name  = "installNamespace"
    value = "false"
  }
}

resource "helm_release" "linkerd_viz" {
  name       = "linkerd-viz"
  chart      = "linkerd-viz"
  namespace  = "linkerd"
  repository = "https://helm.linkerd.io/stable"
  version    = "2.15"
  set {
    name  = "linkerdVersion"
    value = "stable-2.10.2"
  }
}
