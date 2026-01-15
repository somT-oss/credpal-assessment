#!/bin/bash
# Log in to ECR
# We assume the instance role has permissions to run this command
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(cat /home/ec2-user/image_tag.txt | cut -d'/' -f1)

ACTIVE_IMAGE=$(cat /home/ec2-user/image_tag.txt)

docker pull $ACTIVE_IMAGE
docker run -d -p 3000:3000 --name app -e PORT=3000 $ACTIVE_IMAGE
