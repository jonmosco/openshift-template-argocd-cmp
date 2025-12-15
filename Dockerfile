# Dockerfile for ArgoCD OpenShift Template Processor Plugin (Simple)
# This image contains the oc binary for processing OpenShift templates
#
# Build with:
#   podman build --build-arg OPENSHIFT_VERSION=4.15.0 -t argocd-openshift-template-processor-simple:1.0 .

ARG BASE_IMAGE=registry.access.redhat.com/ubi9-minimal:latest
FROM ${BASE_IMAGE}

# Install required packages
RUN microdnf install -y \
    tar \
    gzip \
    && microdnf clean all

# Set OpenShift version as build argument
# Default to a recent stable version if not specified
# Use format like "4.14.0", "4.15.1", or "stable-4.15" for stable branches
ARG OPENSHIFT_VERSION=4.14.0

# Download and install oc binary
# The oc binary is available from the OpenShift client tools release
# Reference: https://github.com/app-sre/container-images/blob/master/qontract-reconcile-oc/Dockerfile
RUN OPENSHIFT_VERSION=${OPENSHIFT_VERSION} && \
    echo "Downloading oc client for OpenShift ${OPENSHIFT_VERSION}..." && \
    curl -sfL "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OPENSHIFT_VERSION}/openshift-client-linux.tar.gz" \
    -o /tmp/oc.tar.gz && \
    tar -xzf /tmp/oc.tar.gz -C /usr/local/bin oc && \
    chmod +x /usr/local/bin/oc && \
    rm -f /tmp/oc.tar.gz && \
    echo "Verifying oc installation..." && \
    oc version --client && \
    echo "oc client installed successfully"

# Set up non-root user for security
RUN groupadd -r argocd -g 999 && \
    useradd -r -u 999 -g argocd -m -d /home/argocd -s /bin/bash argocd

USER argocd
WORKDIR /home/argocd

# Default command (will be overridden by ArgoCD)
CMD ["/var/run/argocd/argocd-cmp-server"]

