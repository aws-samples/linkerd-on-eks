variable "aws_region" {
  default      = "us-west-2"
  description  = "The desired AWS Region in which to launch resources"
  type         = string
}

variable "vpc_cidr" {
  default      = "10.0.0.0/16"
  description  = "The desired CIDR range of the VPC"
  type         = string
}

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

variable "cluster_min_size" {
  default      = 4
  description  = "The desired minimum number of data plane nodes"
  type         = number
}

variable "cluster_max_size" {
  default      = 6
  description  = "The desired maximum number of data plane nodes"
  type         = number
}

variable "cluster_desired_size" {
  default      = 4
  description  = "The desired number of data plane nodes"
  type         = number
}
