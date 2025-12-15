# ArgoCD Configuration Management plugin for OpenShift Templates (Simple)

A simple ArgoCD Configuration Management Plugin for processing OpenShift templates. This plugin provides basic template rendering for standard OpenShift template files.

## Overview

This plugin:
- Discovers OpenShift template files in your repository
- Processes them using the `oc` command-line tool
- Passes parameters from ArgoCD Application configuration
- Generates standard Kubernetes/OpenShift manifests

## OpenShift Templates

The plugin looks for OpenShift template files in the following locations:
- Files in `./openshift/` directory
- Files named `template.yaml` or `template.yml` in the root or subdirectories
- Any YAML file containing `kind: Template` or `apiVersion: template.openshift.io/v1`

Example template:

```yaml
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: my-template
parameters:
  - name: APP_NAME
    description: Application name
    required: true
  - name: APP_NAMESPACE
    description: Application namespace
    required: true
  - name: REPLICAS
    description: Number of replicas
    value: "3"  # Default value
  - name: IMAGE_TAG
    description: Image tag
    value: "latest"  # Default value
objects:
  - apiVersion: v1
    kind: ConfigMap
    metadata:
      name: ${APP_NAME}-config
      namespace: ${APP_NAMESPACE}
```

### Template Parameters

The plugin handles template parameters as follows:

1. **Parameters with default values**: If a template parameter has a `value` field (default), `oc process` will automatically use it if the parameter is not provided via `plugin.parameters`.

2. **Required parameters**: If a template parameter has `required: true` and no default value, it must be provided via `plugin.parameters` or the processing will fail.

3. **Parameter precedence**: Parameters provided via `plugin.parameters` will override template default values.

4. **Unknown parameters**: The plugin uses `--ignore-unknown-parameters`, so if you pass a parameter that doesn't exist in the template, it will be ignored (useful for optional parameters).

Example with defaults:

```yaml
# Template defines:
parameters:
  - name: REPLICAS
    value: "3"  # Default

# If you don't provide REPLICAS in plugin.parameters, it will use "3"
# If you provide REPLICAS: "5", it will use "5"
```

## Building the Plugin Image

The plugin requires a container image containing the `oc` binary. The version of the `oc` binary should match the OpenShift cluster version where ArgoCD is running.

Build the image using Podman:

```bash
# Build with default OpenShift version (4.15.0)
podman build -t argocd-openshift-template-processor-simple:1.0 .

# Build for a specific OpenShift version
podman build \
  --build-arg OPENSHIFT_VERSION=4.15.0 \
  -t argocd-openshift-template-processor-simple:1.0 \
  -f Dockerfile .

# Build and tag for a container registry
podman build \
  --build-arg OPENSHIFT_VERSION=4.15.0 \
  -t quay.io/myorg/argocd-openshift-template-processor-simple:1.0 \
  -f Dockerfile .

# Load image into kind cluster (if using kind for local testing)
kind load docker-image argocd-openshift-template-processor-simple:1.0 --name <cluster-name>
```

### Finding the Correct OpenShift Version

To determine which OpenShift version your cluster is running:

```bash
oc version
```

The `oc` binary version should match your OpenShift cluster version. You can find available OpenShift client versions at:
https://mirror.openshift.com/pub/openshift-v4/clients/ocp/

## Registering the Plugin

1. Apply the ConfigMap containing the plugin definition:
   ```bash
   oc apply -f configmap.yaml
   ```

2. Patch the ArgoCD repo-server deployment to add the sidecar container:
   ```bash
   oc patch deployment argocd-repo-server -n argocd --patch-file repo-server-patch.yaml
   ```

3. Update the `image` field in `repo-server-patch.yaml` to point to your built image.

## Using the Plugin

Create an ArgoCD Application that uses this plugin:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
spec:
  source:
    repoURL: https://github.com/myorg/myrepo
    path: .
    plugin:
      name: openshift-template-processor-simple
      parameters:
        - name: MY_PARAM
          string: my-value
        - name: ANOTHER_PARAM
          string: another-value
```

The plugin will automatically:
- Discover template files in your repository
- Pass `APP_NAME` and `APP_NAMESPACE` from ArgoCD
- Pass any parameters you specify in `spec.source.plugin.parameters`
- Use default values from the template for parameters not explicitly provided
- Process the template with `oc process`

**Note**: Parameters defined in the template with default values will be used automatically. You only need to provide parameters in `plugin.parameters` if you want to override the defaults or if the parameter is required.

## Requirements

- The plugin requires the `oc` command-line tool to be installed in the container image.
- The `oc` binary version must match the OpenShift cluster version where ArgoCD is running.

