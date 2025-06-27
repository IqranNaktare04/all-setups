#!/bin/bash

# Step 1: AWS credentials
aws configure

# Step 2: Install kubectl and kops
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
wget https://github.com/kubernetes/kops/releases/download/v1.32.0/kops-linux-amd64
chmod +x kubectl kops-linux-amd64
mv kubectl /usr/local/bin/
mv kops-linux-amd64 /usr/local/bin/kops

# Step 3: Create S3 bucket for Kops state
BUCKET_NAME=clouddevopsiqran04.k8s.local
CLUSTER_NAME=iqran.k8s.local
REGION=us-east-1

aws s3api create-bucket --bucket clouddevopsiqran04.k8s.local --region us-east-1
aws s3api put-bucket-versioning --bucket clouddevopsiqran04.k8s.local --versioning-configuration Status=Enabled
export KOPS_STATE_STORE=s3://clouddevopsiqran04.k8s.local

# Step 4: Create and apply Kops cluster
kops create cluster \
  --name=iqran.k8s.local \
  --zones=ap-south-1a \
  --image=ami-0f918f7e67a3323f0 \
  --control-plane-count=1 \
  --control-plane-size=t2.large \
  --node-count=3 \
  --node-size=t2.medium

kops update cluster --name=iqran.k8s.local --yes --admin
