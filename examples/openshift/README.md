# Example OpenShift Template

This directory contains an example OpenShift template to test the ArgoCD OpenShift template processor plugin.

## Template: `template.yaml`

A simple template that creates:
- A ConfigMap with application configuration
- A Service for the application
- A Deployment with the application container

## Parameters

The template defines the following parameters:

- **APP_NAME** (required): The name of the application
- **APP_NAMESPACE** (required): The namespace where resources will be created
- **IMAGE** (default: "nginx:latest"): Container image to use (e.g., "nginx:latest", "myapp:v1.0.0", or a local image for kind)
- **REPLICAS** (default: "1"): Number of replicas for the deployment
- **IMAGE_TAG** (default: "latest"): Image tag to use (deprecated, use IMAGE instead)
- **ENVIRONMENT** (default: "dev"): Environment name

## Testing with ArgoCD

See example ArgoCD Application manifest in the parent `examples/` directory:

- **`application.yaml`** - Minimal example using only required parameters

To use:

1. Update the `repoURL` in the application YAML to point to your repository
2. Apply the application:
   ```bash
   kubectl apply -f examples/application.yaml
   ```

## Notes

- `APP_NAME` and `APP_NAMESPACE` are required and will be automatically provided by ArgoCD
- `IMAGE`, `REPLICAS`, and `ENVIRONMENT` have default values, so they're optional
- You can override any default values by providing them in `plugin.parameters`
- For kind clusters, you can use a local image by setting `IMAGE` to your image name (e.g., `myapp:1.0`)

