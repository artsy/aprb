#!/usr/bin/env bash

set -e

curl -O https://storage.googleapis.com/kubernetes-release/release/v1.4.7/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
mkdir ~/.kube
aws configure set default.region us-east-1
aws s3 cp s3://artsy-citadel/k8s/config ~/.kube/config
