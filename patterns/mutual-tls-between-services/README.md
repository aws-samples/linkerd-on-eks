# Pattern - Automatic Mutual TLS with Linkerd

This pattern demonstrates how to configure automatic mTLS management for workloads injecting the Linkerd Service Mesh

In a default TLS handshake only the server is required to authenticate with the client. While this provides some security, it does not adhere to a Zero Trust principle. Instead, take advantage of the TLS protocol support for client authentication by the server (i.e. mutual authentication) called mutual TLS or *mTLS*

Linkerd ServiceMesh provides a convenient vehicle for implementing mTLS because Linkerd sidecar containers already receive all traffic sourced from or destined to Pods that are on-mesh.

Linkerd automatically and transparently implements mTLS for all on-mesh traffic by default with two exceptions:
1. Traffic originating or terminating on an off-mesh Pod
2. Traffic destined for a configured [skip port](https://linkerd.io/2.15/features/protocol-detection/#marking-ports-as-skip-ports) (which bypasses Linkerd entirely)

Part of the way that Linkerd accomplishes this, is to act as a Certificate Authority (CA) to issue TLS certificates that are automatically rotated every 24 hours.

## Prerequisites:

To be able to work with this pattern you should have completed these [prerequisite steps](../../prerequisites/README.md).

## Preflight
<details>
<summary>Steps</summary>

1. Validate the target EKS cluster:
   ```sh
   linkerd checkubectl --pre
   ```

If there are any checks that do not pass, make sure to follow the provided links and fix those issues before proceeding.

2. Install Linkerd
   ```sh
   linkerd install --crds | kubectl apply -f -
   linkerd install | kubectl apply -f -
   ```

3. Validate Linkerd Install
   ```sh
   linkerd check
   ```
</details>


## Working With mTLS
Begin by adding an example emojivoto workload to the cluster:
1. Install the `emojivoto` application:
   ```sh
   curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/emojivoto.yml \
   | kubectl apply -f -
   ```

2. Decide how to enable Linkerd injection:
   - by Deployment
   - by Namespace

   For simplicity, going forward we will use by Namespace but all actions have an analog for injection via Deployment

3. Use the `linkerd viz` utility to checkubectl for mTLS:
   ```sh
   linkerd viz --namespace emojivoto edges deployment
   ```

   With expected output:
   ```sh
   No edges found.
   ```

   You can also checkubectl the Pods to see how many Containers are running:
   ```sh
   kubectl --namespace emojivoto get po

   NAME                      READY   STATUS    RESTARTS   AGE
   emoji-649dfd6b7f-xzs9x    1/1     Running   0          67s
   vote-bot-bbcc988b-j76qr   1/1     Running   0          67s
   voting-77c6b77ffd-g5wvl   1/1     Running   0          67s
   web-77b75995d-vwvkn       1/1     Running   0          66s
   ```

4. Use the `linkerd inject` utility to annotate the Namespace:
   ```sh
   kubectl get ns emojivoto -o yaml | linkerd inject - | kubectl apply -f -
   ```

<details>
<summary>With expected output:</summary>

   ```sh
   namespace "emojivoto" annotated
   namespace/emojivoto configured
   ```
</details>

5. Although the Namespace is annotated, the Deployments (and by extension the Pods) haven't yet picked up the change; issue a restart:
   ```sh
   kubectl --namespace emojivoto rollout restart deployment
   ```

<details>
<summary>With expected output:</summary>

   ```sh
   deployment.apps/emoji restarted
   deployment.apps/vote-bot restarted
   deployment.apps/voting restarted
   deployment.apps/web restarted
   ```
</details>

6. Verify that Pods now run the expected Linkerd sidecar:
   ```sh
   kubectl --namespace emojivoto get pods

   NAME                        READY   STATUS    RESTARTS   AGE
   emoji-597d5d7f8f-nfbs8      2/2     Running   0          102s
   vote-bot-69f46bf946-g8wll   2/2     Running   0          102s
   voting-74d8cf54c4-mj8k5     2/2     Running   0          102s
   web-5d6579b648-5t8pc        2/2     Running   0          102s
   ```

7. Finally, use the `linkerd viz` utility again to checkubectl for mTLS:
   ```sh
   linkerd viz --namespace emojivoto edges deployment
   ```

<details>
<summary>With expected output:</summary>

   ```sh
   SRC          DST        SRC_NS        DST_NS      SECURED
   vote-bot     web        emojivoto     emojivoto   √
   web          emoji      emojivoto     emojivoto   √
   web          voting     emojivoto     emojivoto   √
   prometheus   emoji      linkerd-viz   emojivoto   √
   prometheus   vote-bot   linkerd-viz   emojivoto   √
   prometheus   voting     linkerd-viz   emojivoto   √
   prometheus   web        linkerd-viz   emojivoto   √
   ```
</details>

> Note: Although the command is filtered for the `emojivoto` Namespace, resources from other Namespaces are included because traffic originating from outside of the `emojivoto` Namespace is destined for resources within the `emojivoto` Namespace and therefore demonstrates both ingress and egress mTLS with respect to the Namespace boundary; by default the `linkerd viz edges` command uses the effective Namespace from context and accepts flags `-A, --all-namespaces`

> Note: There are many other ways to validate / inspect traffic to confirm if mTLS is in use, such as the `linkerd viz tap` [command](https://linkerd.io/2.15/reference/cli/viz/#tap)
