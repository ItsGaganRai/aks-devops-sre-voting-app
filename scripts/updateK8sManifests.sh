#!/bin/bash

set -euo pipefail

# Arguments passed from Azure Pipeline
SERVICE="$1"
IMAGE_REPOSITORY="$2"
TAG="$3"

# ACR image
IMAGE="gaganazurecicd.azurecr.io/${IMAGE_REPOSITORY}:${TAG}"

# Manifest path
MANIFEST="k8s-specifications/${SERVICE}-deployment.yaml"

echo "Updating manifest: $MANIFEST"
echo "New image: $IMAGE"

# Go to the checked-out repository
cd "$BUILD_SOURCESDIRECTORY"

# Update the image line
sed -i -E "s|(^[[:space:]]*-[[:space:]]*image:[[:space:]]*).*$|\1${IMAGE}|" "$MANIFEST"

# Configure Git identity
git config user.email "azure-pipelines@local"
git config user.name "Azure Pipelines"

# Stage only the modified manifest
git add "$MANIFEST"

# Commit the change
git commit -m "Update ${SERVICE} image to ${TAG} [skip ci]"

# Push to the branch that triggered the pipeline
git push origin "HEAD:${BUILD_SOURCEBRANCH}"

echo "Manifest update completed successfully."