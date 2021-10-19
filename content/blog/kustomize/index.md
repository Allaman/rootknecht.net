---
title: Kustomize
type: posts
draft: true
date: 2021-10-12
tags:
  - cloud
  - Kubernetes
  - devops
resources:
  - name: folder-structure
    src: folder-structure.png
    title: Top level folder layout
  - name: basic-base-folder
    src: basic/base-folder.png
    title: The content of the base folder
  - name: basic-overlay-folder
    src: basic/overlay-folder.png
    title: The content of the overlay folder
  - name: basic-diff
    src: basic/diff.png
    title: Diff of dev, test, and prod envs (left to right)
  - name: layering-folder
    src: layering/folder-structure.png
    title: Structure of a more complex deployment
  - name: backend-structure
    src: layering/backend-structure.png
    title: Deployments from the same base
---

An introduction to [Kustomize](https://kustomize.io/) and why I it could change the way you deploy your workloads to Kubernetes.

<!--more-->

{{< toc >}}

## What is Kustomize

> Kubernetes native configuration management

With Kustomize you can define your Kubernetes deployments for various environments with different parameters without learning a new templating language nor a DSL. Kustomize works with standard Kubernetes resources and applies different parameters for different environments via a so called overlay. More on this when we have a closer look at Kustomize.

Kustomize is included in `kubectl` and also [available](https://kubectl.docs.kubernetes.io/installation/kustomize/) as standalone application for all major platforms.

## What does Kustomize solve?

An common scenario for teams deploying to Kubernetes is a multi cluster setup for different environments. For instance, you could have develop, test, and production environments and for each of it a dedicated Kubernetes cluster is running. You need to deploy your applications to each Kubernetes cluster in order to perform the required tasks like testing or QA and of course running production load. Of course, the deployments are not the same on each cluster because the requirements can be different. On the production cluster you probably require more resources in order to sustain availability under heavy load in contrast to develop where only a few developers check there work.

A **naive** approach might look like this:
{{< mermaid class="text-center">}}
graph TD
A[Manifests for dev] -->|deploy| D(Develop Kubernetes)
B[Manifests for test] -->|deploy| E(Test Kubernetes)
C[Manifests for prod] -->|deploy| F(Production Kubernetes)
{{< /mermaid >}}
You define your Kubernetes manifests for each environment with their specific parameters and apply them to the cluster. This leads to a lot of **redundant** code and decreases the **maintainability** because you have to touch each environment in case of a non environment specific change.

In order to reduce code redundancy and increase maintainability we want to achieve an approach like this:
{{< mermaid class="text-center" >}}
graph TD
A[Manifests] -->|custom deploy| D(Develop Kubernetes)
A -->|custom deploy| E(Test Kubernetes)
A -->|custom deploy| F(Production Kubernetes)
{{< /mermaid >}}

We want to define "common" Kubernetes manifests for all environments that are **k**ustomized for each environment. Let Kustomize enter the stage!

## Kustomize in action

Kustomize introduces the `base` and `overlay` concept. The base includes all Kubernetes manifests that are common for all environments and tend to be very static meaning they do not change often if any. The overlay includes manifests for a specific environment and alter some values of the base.

A common practice for writing Kustomize deployments is a clear folder structure that separates base and overlay manifests that contains the actual environments:

{{< img name=folder-structure lazy=true size=tiny >}}

{{< hint info >}}
You can omit the overlay folder if you prefer a more flat layout
{{< /hint >}}

### Basic example

This example illustrates the simple overlay mechanism of Kustomize to write Kubernetes manifests for different environments. Kustomize generates/build the manifests to be applied before they are transmitted to the Kubernetes controller.

The Syntax is as follows:

```sh
kustomize build /path/to/folder [> manifests.yaml]
```

The generated manifests are printed out and can be redirected to a file.

{{< hint warning >}}
The following snippet will apply resources! Use the former command for just generating the resources
{{< /hint >}}

```sh
kubectl apply -k /path/to/folder
```

{{< hint info >}}
Most of my Kustomize code ships with a [Makefile](https://github.com/Allaman/toolbox/tree/main/makefile/kustomize) with common commands included - have a look 🤓
{{< /hint >}}

Now lets think about the following scenario:

- three environments (dev, test, prod)
- two applications named foo and bar

We should write deployment manifests that satisfies the following requirements:

- both applications should be deployed to each environment
- resource labeling must match the environment
- scale the applications per environment
- allocate resources to the applications per environment

{{< hint info >}}
You can find the code at my [Github](https://github.com/Allaman/kustomize-demo/tree/main/basic)
{{< /hint >}}

In the **base** folder we define our usual Kubernetes manifests. For this demo, we write resources for a deployment, a service account and a service for both, `bar` and `foo` services.

{{< img name=basic-base-folder lazy=true size=small >}}

Additionally, Kustomize requires a `kustomization.yaml` in each folder that contains at least a list of resource files to be processed by Kustomize. Additionally, we define common labels for this application.

`base/bar/kustomization.yaml`:

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
commonLabels:
  app.kubernetes.io/name: bar
resources:
  - deployment.yaml
  - sa.yaml
  - service.yaml
```

The **overlay** folder contains the modifications we want for each environment. Again, each folder requires a `kustomization.ymal`.

{{< img name=basic-overlay-folder lazy=true size=small >}}

{{< hint info >}}
At the beginning this is a bit awkward and you probably will often forget to add a `kustomization.yaml` but you will get used to it.
{{< /hint >}}

The first kustomization.yaml defines the list of resources to be applied to the according environment. Note that you can define folders as well. Furthermore we define an additional common label specific to the environment (`env`) that will be merged to the labels from definend in the base resources.

`overlay/dev/kustomization.yaml`:

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: app
commonLabels:
  env: dev
resources:
  - bar/
  - foo/
```

The second kustomization.yaml finally defines the resources to modify the application's values.

`overlay/dev/bar/kustomization.yaml`:

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../../base/bar/
patchesStrategicMerge:
  - deployment.yaml
```

In this example we use a [pachtesStrategicMerge](https://kubectl.docs.kubernetes.io/references/kustomize/glossary/#patchstrategicmerge) which will use the provided `deployment.yaml` and patch the provided values to the deployment resource defined in `base`.

{{< hint info >}}
You must provide the names of resources (here `metadata.name` and `containers.name`) so that can identify the resources from base that needs to be patched.
{{< /hint >}}

`overlay/dev/bar/deployment.yaml`:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bar
spec:
  replicas: 1
  template:
    spec:
      containers:
        - name: bar
          resources:
            requests:
              memory: "100Mi"
              cpu: "100m"
            limits:
              memory: "100Mi"
              cpu: "100m"
```

This patch will add `spec.replicas` and `spec.template.spec.containers[0].resources` to the deployment resource from the base. As we provide such a patch for each environment we can adjust our deployment for each of them.

Here you can see a diff for the deployment manifests generated by Kustomize for each environment. As intended each environment is **k**ustomized with its own values.

{{< img name=basic-diff lazy=true >}}

### Selectors

If you have a closer look at the code of the basic example you can see that the deployment manifests are lacking the `spec.selectors` part and how this should work for a real deployment in a cluster.

The answer is a convenient feature of Kustomize for the handling of `spec.selectors`. Kustomize automatically handles them for you!

Let's have a look at the generated deployment manifest for the foo service.

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: foo
    env: prod
  name: foo
  namespace: app
spec:
  replicas: 3
  selector: # automatically generated by Kustomize
    matchLabels:
      app.kubernetes.io/name: foo
      env: prod
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
    type: RollingUpdate
  template:
    metadata:
      labels:
        app.kubernetes.io/name: foo
        env: prod
```

{{< hint warning >}}
As Kustomize always uses all values of `commonLabels` for selectors you cannot modify your labels for certain resources (e.g. deployments) because `matchLabel` is immutable by the Kubernetes API! Think about your labeling before deploying resources.
{{< /hint >}}

Since Kustomize [4.1.0](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv4.1.0) there is a new option to distinguish between labels that should be included in selectors as the following example shows.

`basic/base/bar/kustomization.yaml`:

```yaml
labels:
  - pairs:
      # both labels are not included in selectors
      version: 0.9.0
      msg: not in selector
      # this label is included as selector
  - pairs:
      criticality: high
    includeSelectors: true
```

This simple demo illustrated a very common use case in today's deployments and how to solve it with Kustomize. By providing a set of base resources we can reduce the amount of redundant manifests. By applying patches via Kustomize we can modify only the resources' values we need. By following a clean folder structure (see [layering](/blog/kustomize#layering) for more details) it is intuitive and straight forward to understand and maintain the Kubernetes manifests.

### Layering

{{< hint info >}}
[Source code](https://github.com/Allaman/kustomize-demo/tree/main/layering) for the demo

Only dummy Kubernetes manifests for demonstration
{{< /hint >}}

Kustomize works on different layers (I call it that way) allowing you to organize your deployments and create a logical structure. Let us think about a more complex deployment scenario.

**Basic conditions**

- two dedicated clusters for a stg and a prod environment
- a frontend consisting of an UI component and a BFF (backend for frontend) component
- a backend consisting of an engine component, an administration component and **several** scraper components
- a debugging service that is only required to deploy on stg

**Implementation**

With Kustomize you can organize your deployments in folders and sub folders in a nested structure.

{{< img name=layering-folder lazy=true size=small >}}

You can see that we organized our applications in `backend` and `frontend` folders. Of course, each folder requires a `kustomization.yaml`. Furthermore you can see that the `debug` application only exists in stg and not in base because we did not require it for the production environment. If you think that there might be a chance that the debug component needs to be deployed to prod as well you can define it in the base as well but only refer to it from staging.

#### Labels

Labels are merged the path that Kustomize traverses and you can include new labels in each `kustomization.yaml` (if necessary).

{{< mermaid class="text-center" >}}
graph TD
A[overlay/prod/kustomization.yaml] --> B[overlay/prod/backend/kustomization.yaml]
B --> C[overlay/prod/backend/editor/kustomization.yaml]
C --> D[base/backend/editor/kustomization.yaml]
{{< /mermaid >}}

The labels after Kustomize has built the manifest:

```yaml
labels:
  app.kubernetes.io/name: editor # from /base/backend/editor/kustomization.yaml
  app.kubernetes.io/part-of: backend # from base/backend/kustomization.yaml
  env: prod # from prod/kustomization.yaml
```

#### Multiple Deployments from one base

In Production we want to deploy multiple scraper applications that might run just in a slightly different configuration (for instance a different environment variable). With Kustomize we can still define the common resources for the scraper in our base folder but create multiple deployments in the overlay.

{{< img name=backend-structure lazy=true size=tiny >}}

How does this work and how does this not lead to naming collisions of resources?

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
nameSuffix: -bar
commonLabels:
  app.kubernetes.io/name: scraper-bar
resources:
  - ../../../../base/backend/scraper
```

Kustomize has a feature `nameSuffix` (and `namePrefix`) that modifies all resources' names accordingly.

Although in base we defined `metadata.name: scraper` with the suffix Kustomize generates manifests with a new name allowing us to deploy multiple scraper applications while only maintaining one common base.

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/name: scraper-foo
    app.kubernetes.io/part-of: backend
    env: prod
  name: scraper-foo # from nameSuffix in kustomization.yaml
  namespace: team1
```

### Advanced use cases

#### Patching a single value only

####

### CD integration

CD integration is available for common GitOps like [Flux](https://github.com/fluxcd/flux) and [ArgoCD](https://github.com/argoproj/argo-cd).
Due to its simplicity it is likely that you can integrate Kustomize in your workflow as well. This is the most basic command to apply your manifests:

```sh
kustomize build overlay/prod | kubectl apply -f -
```

Keep in mind that this approach does not do a garbage collection of resources like Flux does.

## Kustomize best practice

{{< hint info >}}
These things worked for me but keep in mind that your mileage might differ.
{{< /hint >}}

1. Naming convention.
2. Resources per file
3. Think about your labels
4. Think about your base
5. Prefix your commit messages

## Kustomize vs Helm

{{< hint warning >}}
Never blindly follow a tool recommendation but analyze the specific requirements in your environment and choose the best tool for your
{{< /hint >}}

### What is Helm

> The package manager for Kubernetes.

> Helm is the best way to find, share, and use software built for Kubernetes.

Helm is one of the old players in the Kubernetes ecosystem. Meanwhile the current version of Helm is v3 which replaced version 2 with a new architecture. See the official [migration guide](https://helm.sh/docs/topics/v2_v3_migration/) for the changes between v3 and v2. Helm is [available](https://helm.sh/docs/intro/install/) for all major operating systems.

Basically, Helm is used to define and distribute deployments for Kubernetes.

## Downsides of Kustomize

There are some aspects to consider:

- **boiler plate**: For more complex deployments you will write a lot of kustomization.yaml.
- **redundancy**: As shown, Kustomize reduces the redundancy of code. But there is still some redundancy. For instance in the basic example your have to write the deployment files to be patched three times with only minimal differences.
- **loose coupling**: components defined with Kustomize are only loosely coupled and dependencies between components are not easy to declare.
- **Limited "language"**: Kustomize, unlike Helm, is not a templating language and therefore does not include templating features like loops or control flows.

## Glossary
