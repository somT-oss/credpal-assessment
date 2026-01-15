#!/bin/bash
set -ex


# Log in to ECR
# We assume the instance role has permissions to run this command
# aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(cat /home/ec2-user/image_tag.txt | cut -d'/' -f1)

echo "=== WHO AM I ==="
whoami

echo "=== CURRENT WORKING DIRECTORY ==="
pwd

echo "=== LIST CURRENT DIRECTORY ==="
ls -la

echo "=== TREE (2 levels) ==="
find . -maxdepth 2 -type f

echo "=== CODEDEPLOY ENV VARS ==="
env | sort

IMAGE=$(cat image_tag.txt)
REGISTRY=$(echo "$IMAGE" | awk -F/ '{print $1}')

aws ecr get-login-password --region us-east-1 \
| docker login --username AWS --password-stdin "$REGISTRY"

ACTIVE_IMAGE=$(cat /home/ec2-user/image_tag.txt)

docker pull $ACTIVE_IMAGE
docker run -d -p 3000:3000 --name app -e PORT=3000 $ACTIVE_IMAGE
