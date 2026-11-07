#!/bin/bash

set -euo pipefail

# Receive arguments from Azure Pipeline
SERVICE="$1"
IMAGE_REPOSITORY="$2"
TAG="$3"

# Construct the complete ACR image name
IMAGE="gaganazurecicd.azurecr.io/${IMAGE_REPOSITORY}:${TAG}"

# Define the Kubernetes deployment manifest
MANIFEST="k8s-specifications/${SERVICE}-deployment.yaml"

echo "======================================"
echo "Updating Kubernetes Deployment"
echo "Service: $SERVICE"
echo "Image: $IMAGE"
echo "Manifest: $MANIFEST"
echo "======================================"

# Navigate to the Azure Pipeline repository checkout
cd "$BUILD_SOURCESDIRECTORY"

# Update the container image in the manifest
sed -i -E "s|(^[[:space:]]*-[[:space:]]*image:[[:space:]]*).*$|\1${IMAGE}|" "$MANIFEST"

# Display the updated image
echo "Updated manifest image:"
grep -n "image:" "$MANIFEST"

# Display the changes before committing
echo "Git diff:"
git diff -- "$MANIFEST"

# Configure Git identity
git config user.email "azure-pipelines@local"
git config user.name "Azure Pipelines"

# Stage only the modified manifest
git add "$MANIFEST"

# Commit the change
git commit -m "Update ${SERVICE} image to ${TAG} [skip ci]"

# Push changes to the branch that triggered the pipeline
git push origin "HEAD:${BUILD_SOURCEBRANCH}"

echo "======================================"
echo "Kubernetes manifest updated successfully!"
echo "======================================"