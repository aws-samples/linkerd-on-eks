# Pattern - Linkerd Terraform Install

This pattern installs the [Linkerd Service Mesh](https://linkerd.io/) to an [AWS EKS](https://aws.amazon.com/eks/) Kubernetes cluster via Helm Chart and using Terraform

> Note: This pattern installs the *edge* release of Linkerd; stable versions are available but have differing requirements and use different Helm repositories.

## Prerequisites:

To be able to work with this pattern you should have completed these [prerequisite steps](../../prerequisites/README.md).

## Install Linkerd

In order to support automatic Mutual TLS (mTLS) between Pods, Linkerd requires a Trust Anchor TLS Certificate; and an Issuer TLS Certificate; and Issuer TLS Key
One path to generate these is [provided by Linkerd](https://linkerd.io/2.15/tasks/generate-certificates/#trust-anchor-certificate) and uses the [step](https://smallstep.com/cli/) utility:
1. Generate the Trust Anchor Certificate:
   ```sh
   step certificate create root.linkerd.cluster.local ca.crt ca.key \
   --profile root-ca --no-password --insecure
   ```

2. Generate the Issuer Certificate & Key:
   ```sh
   step certificate create identity.linkerd.cluster.local issuer.crt issuer.key \
   --profile intermediate-ca --not-after 8760h --no-password --insecure \
   --ca ca.crt --ca-key ca.key
   ```

Where these files are stored is not significant, however, paths will need to be provided to Terraform so don't lose them!

Now install with Terraform -
1. Initialize:
   ```sh
   terraform init
   ```

2. Plan:
   ```sh
   terraform plan
   ```

3. Apply:
   ```sh
   terraform apply -auto-approve
   ```

> Note: If you wish to override any of the included variable values you may do so by editing the `values.tf` file or via the CLI such as `terraform apply -auto-approve -var="linkerd_namespace=sample"`

> If you do make any changes, please note that this may impact future commands; in the case of overriding the Namespace value the `linkerd check` command would require an additional `--linkerd-namespace` flag


> Note: The Namespace Resource is created independently but the Terraform module `helm_release` does support creating the Namespace automatially; here the independent creation supports possible future labels and other native Namespace functionality

4. Check:
   ```sh
   linkerd check
   ```

<details>
<summary>With expected output:</summary>

   ```sh
   =======

   kubernetes-api
   --------------
   √ can initialize the client
   √ can query the Kubernetes API
   
   kubernetes-version
   ------------------
   √ is running the minimum Kubernetes API version

   linkerd-existence
   -----------------
   √ 'linkerd-config' config map exists
   √ heartbeat ServiceAccount exist
   √ control plane replica sets are ready
   √ no unschedulable pods
   √ control plane pods are ready
   √ cluster networks contains all pods
   √ cluster networks contains all services

   linkerd-config
   --------------
   √ control plane Namespace exists
   √ control plane ClusterRoles exist
   √ control plane ClusterRoleBindings exist
   √ control plane ServiceAccounts exist
   √ control plane CustomResourceDefinitions exist
   √ control plane MutatingWebhookConfigurations exist
   √ control plane ValidatingWebhookConfigurations exist
   √ proxy-init container runs as root user if docker container runtime is used

   linkerd-identity
   ----------------
   √ certificate config is valid
   √ trust anchors are using supported crypto algorithm
   √ trust anchors are within their validity period
   √ trust anchors are valid for at least 60 days
   √ issuer cert is using supported crypto algorithm
   √ issuer cert is within its validity period
   √ issuer cert is valid for at least 60 days
   √ issuer cert is issued by the trust anchor

   linkerd-webhooks-and-apisvc-tls
   -------------------------------
   √ proxy-injector webhook has valid cert
   √ proxy-injector cert is valid for at least 60 days
   √ sp-validator webhook has valid cert
   √ sp-validator cert is valid for at least 60 days
   √ policy-validator webhook has valid cert
   √ policy-validator cert is valid for at least 60 days

   linkerd-version
   ---------------
   √ can determine the latest version
   √ cli is up-to-date
   
   control-plane-version
   ---------------------
   √ can retrieve the control plane version
   √ control plane is up-to-date
   √ control plane and cli versions match

   linkerd-control-plane-proxy
   ---------------------------
   √ control plane proxies are healthy
   √ control plane proxies are up-to-date
   √ control plane proxies and cli versions match
   
   linkerd-ha-checks
   -----------------
   √ multiple replicas of control plane pods

   linkerd-extension-checks
   ------------------------
   √ namespace configuration for extensions

   Status check results are √
   ```
</details>
