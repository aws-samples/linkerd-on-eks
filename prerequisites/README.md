# Prerequisites

These are the prerequisites to working with the samples in this repository and working with the [Linkerd Service Mesh](https://linkerd.io/) running on an [AWS EKS](https://aws.amazon.com/eks/) Kubernetes cluster


## EKS Cluster
To be able to work on this module you should have an EKS cluster deployed by following the below steps.
1. Establish or use existing EKS cluster:
   ```sh
   aws eks update-kubeconfig --region $AWS_REGION --name $EXISTING_CLUSTER_NAME
   ```

   OR

   Edit the example file provided in this repository to adjust values as appropriate, then use the [eksctl](https://eksctl.io/) tool:
   ```sh
   eksctl create cluster -f example-cluster.yaml
   ```

2. Install the Linkerd Command Line Utility (CLI):
   ```sh
   curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install-edge | sh
   export PATH=$HOME/.linkerd2/bin:$PATH
   linkerd version
   ```

3. It is recommended to install these tools:
   1. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
   2. [helm](https://helm.sh/docs/intro/install/)
   3. [jq](https://jqlang.github.io/jq/download/)
   4. [siege](https://github.com/JoeDog/siege)
