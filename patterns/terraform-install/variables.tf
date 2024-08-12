variable "kube_config_path" {
  default      = "~/.kube/config"
  description  = "The fully qualified or relative path to the desired Kubernetes configuration file"
  type         = string
}

variable "linkerd_namespace" {
  default      = "linkerd"
  description  = "The desired name of the Kuberntes Namespace resource to use for Linkerd Service Mesh"
  type         = string
}

variable "linkerd_helm_registry_url" {
  default      = "https://helm.linkerd.io/edge"
  description  = "The URL of the desired Helm registry from which to install Linkerd Service Mesh"
  type         = string
}

variable "identity_trust_anchor_file" {
  default      = "./ca.crt"
  description  = "The fully qualified or relative path to the desired Trust Anchor PEM Certificate file"
  type         = string
}

variable "identity_issuer_certificate_file" {
  default      = "./issuer.crt"
  description  = "The fully qualified or relative path to the desired Issuer TLS PEM Certificate file"
  type         = string
}

variable "identity_issuer_key_file" {
  default      = "./issuer.key"
  description  = "The fully qualified or relative path to the desired Issuer TLS PEM Key file"
  type         = string
}

