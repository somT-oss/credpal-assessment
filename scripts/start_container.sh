#!/bin/bash


IMAGE=$(cat image_tag.txt)
echo "Found image >>> "
echo $IMAGE

# Read image tag
IMAGE=$(cat "$IMAGE_FILE")
REGISTRY=$(echo "$IMAGE" | awk -F/ '{print $1}')

# Log in to ECR
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$REGISTRY"

# Pull and run container
docker pull "$IMAGE"
docker run -d -p 3000:3000 --name app -e PORT=3000 "$IMAGE"
