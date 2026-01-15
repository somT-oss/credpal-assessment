#!/bin/bash
set -ex

IMAGE_FILE="/home/ec2-user/image_tag.txt"

# Debug: confirm file exists
if [ ! -f "$IMAGE_FILE" ]; then
  echo "ERROR: image_tag.txt not found!"
  ls -la /home/ec2-user
  exit 1
fi

IMAGE=$(cat "$IMAGE_FILE")
REGISTRY=$(echo "$IMAGE" | awk -F/ '{print $1}')

echo "Found image: $IMAGE"
echo "Registry: $REGISTRY"

# Log in to ECR
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$REGISTRY"

# Pull and run
docker pull "$IMAGE"
docker run -d -p 3000:3000 --name app -e PORT=3000 "$IMAGE"