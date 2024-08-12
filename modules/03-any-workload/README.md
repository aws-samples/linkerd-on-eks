## Linkerd Injection for Kubernetes Deployment
1. Use the Kubernetes-provided [example Deployment manifest](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#creating-a-deployment) (below)
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: nginx-deployment
     labels:
       app: nginx
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: nginx
     template:
       metadata:
         labels:
           app: nginx
       spec:
         containers:
         - name: nginx
           image: nginx:1.14.2
           ports:
           - containerPort: 80
   ```

2. Apply the manifest:
   ```sh
   kubectl --namespace default apply -f https://raw.githubusercontent.com/kubernetes/website/main/content/en/examples/controllers/nginx-deployment.yaml
   ```

3. Verify the Deployment:
   ```sh
   kubectl --namespace default get deployment,pods
   ```

   Expected output reflects a single container per Pod:
   ```sh
   pod/nginx-deployment-86dcfdf4c6-9g5rv   1/1     Running   0          16s
   pod/nginx-deployment-86dcfdf4c6-9v5l6   1/1     Running   0          16s
   pod/nginx-deployment-86dcfdf4c6-fwr2g   1/1     Running   0          16s
   ```

> Note: The provided manifest specifies a count of 3 replicas; this is arbitrary and any number of Pods will work

4. Annotate the Deployment to implement Linkerd injection:
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: nginx-deployment
     labels:
       app: nginx
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: nginx
     template:
       metadata:
         annotations:
           linkerd.io/inject: enabled
         labels:
           app: nginx
       spec:
         containers:
         - name: nginx
           image: nginx:1.14.2
           ports:
           - containerPort: 80
   ```

> Note: The addition of the `annotations` stanza and annotation label `linkerd.io/inject` are the same operation taken by the `linkerd inject` command
> 
> There are any number of reasons why a manual approach might be preferred, but one reason could be that it better takes advantage of existing CI-CD tooling (such as Helm) that may be responsible for rendering Kubernetes manifest code from metadata, however, since the results are exactly the same choose whatever best supports your unique requirements!

5. Update the applied manifest to include the new annotation:
   ```sh
   kubectl --namespace default apply -f deployment.yaml
   ```

> Note: Although not explicitly configured in the manifest, the default strategy for a Kubernetes deployment is `RollingUpdate`, so this command will automatically begin replacing Pods

6. Verify Linkerd injection:
   ```sh
   kubectl --namespace default get pods
   ```

   Expect output similar to:
   ```sh
   NAME                                READY   STATUS        RESTARTS   AGE
   nginx-deployment-5cbf7dc9-5g6r8     2/2     Running       0          8s
   nginx-deployment-5cbf7dc9-7kxfg     2/2     Running       0          12s
   nginx-deployment-5cbf7dc9-tvrkg     2/2     Running       0          5s
   nginx-deployment-86dcfdf4c6-9v5l6   0/1     Terminating   0          11m
   ```

> Note: Counting the number of containers in a Pod is a good short-hand for Linkerd injection, but another way to verify is to check each Pod spec to see if the `linkerd` sidecar container is included:
>
> `kubectl --namespace default get pods -o jsonpath='{range .items[*]}{.spec.containers[*].name}{"\n"}{end}'`
> 
> Expect output similar to:
```sh
linkerd-proxy nginx
linkerd-proxy nginx
linkerd-proxy nginx
```

Through this step-by-step process we can see how simple it is to add resources to the Linkerd Service Mesh, but far simpler is to make use of the existing tools when and where appropriate, so the entire above process could have been implemented as this one-liner:
```sh
curl https://raw.githubusercontent.com/kubernetes/website/main/content/en/examples/controllers/nginx-deployment.yaml \
| linkerd inject - \
| kubectl --namespace default apply -f -
```

## Linkerd Injection for Kubernetes Namespace

Enabling Linkerd injection on a Deployment is fine for an example, but this could become tedious for large-scale clusters with hundreds or thousands of Deployment Resources. What if, instead of targeting individual Pods or Deployments, we could enable Linkerd injection for an entire Namespace? We can!

1. Use the `linkerd` utility to add the annotation to the `default` Namspace (which could also be performed manually similar to the above process):
   ```sh
   kubectl get namespace default -o yaml | linkerd inject - | kubectl apply -f -
   ```

   With expected output similar to:
   ```sh
   namespace "default" annotated
   ```

2. Apply the upstream Deployment manifest as before:
   ```sh
   kubectl --namespace default apply -f https://raw.githubusercontent.com/kubernetes/website/main/content/en/examples/controllers/nginx-deployment.yaml
   ```

3. Verify that Pods are automatically injected:
   ```sh
   kubectl --namespace default get pods
   ```

   Expect output similar to:
   ```sh
   NAME                                READY   STATUS    RESTARTS   AGE
   nginx-deployment-86dcfdf4c6-72kpt   2/2     Running   0          4m33s
   nginx-deployment-86dcfdf4c6-7k44g   2/2     Running   0          4m33s
   nginx-deployment-86dcfdf4c6-gwznj   2/2     Running   0          4m33s
   ```

> Note: this model supports an opt-out annotation to counter the Namespace injection for workloads that must share a Namespace but must not be on-mesh:
> 
> `linkerd.io/inject: disabled`
