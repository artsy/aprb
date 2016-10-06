#!/usr/bin/env bash

set -e

# more bash-friendly output for jq
JQ="jq --raw-output --exit-status"

configure_aws_cli(){
  aws --version
  aws configure set default.region us-east-1
  aws configure set default.output json
}

push_ecr_image(){
  eval $(aws ecr get-login --region us-east-1)
  docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/aprb:$CIRCLE_SHA1
}

rolling_update(){
  curl -O https://storage.googleapis.com/kubernetes-release/release/v1.3.3/bin/linux/amd64/kubectl
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/

  mkdir ~/.kube
  aws s3 cp s3://artsy-citadel/k8s/config ~/.kube/config

  /usr/local/bin/kubectl config use-context production
  /usr/local/bin/kubectl rolling-update aprb --image=$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/aprb:$CIRCLE_SHA1
  rm -rf ~/.kube
}

configure_aws_cli
push_ecr_image
rolling_update