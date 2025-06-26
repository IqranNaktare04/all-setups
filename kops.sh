#!/bin/bash
echo "🔐 Configuring AWS credentials..."
aws configure

# Install tools
echo "⬇️ Downloading kubectl and kops..."
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
wget https://github.com/kubernetes/kops/releases/download/v1.32.0/kops-linux-amd64

chmod +x kubectl kops-linux-amd64
sudo mv kubectl /usr/local/bin/
sudo mv kops-linux-amd64 /usr/local/bin/kops

# Persist PATH and KOPS state
echo 'export PATH=$PATH:/usr/local/bin/' >> ~/.bashrc

# S3 bucket for kops
BUCKET_NAME=cloudiqran04.k8s.local
REGION=ap-south-1
CLUSTER_NAME=iqran.k8s.local

echo "☁️ Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket --bucket cloudiqran04.k8s.local \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

echo "🌀 Enabling versioning..."
aws s3api put-bucket-versioning --bucket cloudiqran04.k8s.local \
  --region ap-south-1 \
  --versioning-configuration Status=Enabled

export KOPS_STATE_STORE=s3://cloudiqran04.k8s.local
echo 'export KOPS_STATE_STORE=s3://'"cloudiqran.k8s.local" >> ~/.bashrc
source ~/.bashrc

# Create cluster
echo "🚀 Creating cluster: $CLUSTER_NAME"
kops create cluster \
  --name iqran.k8s.local \
  --zones ap-south-1a" \
  --control-plane-count=1 \
  --control-plane-size t2.large \
  --node-count=3 \
  --node-size t2.medium \
  --yes \
  --admin

# Validate cluster
echo "⏳ Validating cluster..."
if kops validate cluster --name iqran.k8s.local --wait 10m; then
  echo "✅ Cluster is up and running!"
else
  echo "❌ Cluster validation failed. Please check configuration."
  exit 1
fi
