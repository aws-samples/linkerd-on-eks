################################################################################
# EKS Blueprints Addons
################################################################################

resource "kubernetes_namespace" "linkerd" {
  metadata {
    name = "linkerd"
  }
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_load_balancer_controller = true

  helm_releases = {

    linkerd-crds = {
      depends_on = [ kubernetes_namespace.linkerd ]

      name       = "linkerd-crds"
      namespace  = var.linkerd_namespace
      repository = var.linkerd_helm_registry_url
      chart      = "linkerd-crds"
    }

    linkerd-control-plane = {
      depends_on = [ kubernetes_namespace.linkerd ]

      name       = "linkerd-control-plane"
      namespace  = var.linkerd_namespace
      repository = var.linkerd_helm_registry_url
      chart      = "linkerd-control-plane"

      set = [{
        name  = "identityTrustAnchorsPEM"
        value = file( var.identity_trust_anchor_file )
      },{
        name  = "identity.issuer.tls.crtPEM"
        value = file( var.identity_issuer_certificate_file )
      },{
        name  = "identity.issuer.tls.keyPEM"
        value = file( var.identity_issuer_key_file )
      }]

      values = [
        file( "linkerd-values.yaml" )
      ]
    }

  }
  tags = local.tags
}
