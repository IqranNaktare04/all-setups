#vim .bashrc
#export PATH=$PATH:/usr/local/bin/
#source .bashrc
#!/bin/bash
echo "🔐 Configuring AWS credentials..."
aws configure
# STEP 2: Install kubectl (CLI)
echo "⬇️ Downloading latest kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# STEP 3: Install kops binary
echo "⬇️ Downloading kops..."
wget https://github.com/kubernetes/kops/releases/download/v1.32.0/kops-linux-amd64
# Make both binaries executable
chmod +x kubectl kops-linux-amd64
# Move binaries to system path
sudo mv kubectl /usr/local/bin/
sudo mv kops-linux-amd64 /usr/local/bin/kops
# STEP 4: Create S3 state bucket
BUCKET_NAME=cloudiqran04.k8s.local
REGION=ap-south-1
echo "☁️ Creating S3 bucket for kops state: $BUCKET_NAME"
aws s3api create-bucket --bucket cloudiqran04.k8s.local \
  --region us-east-1 \
  --create-bucket-configuration LocationConstraint=us-east-1

echo "🌀 Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
  --bucket cloudiqran04.k8s.local \
  --region us-east-1 \
  --versioning-configuration Status=Enabled
# Export Kops state store path
export KOPS_STATE_STORE=s3://cloudiqran04.k8s.local
# STEP 5: Create Kubernetes cluster
CLUSTER_NAME=iqran.k8s.local
echo "🚀 Creating Kubernetes cluster: $CLUSTER_NAME"
kops create cluster \
  --name iqran.k8s.local \
  --zones ap-south-1a \
  --image ami-0f918f7e67a3323f0 \
  --control-plane-count=1 \
  --control-plane-size t2.large \
  --node-count=3 \
  --node-size t2.medium \
  --yes \
  --admin
# STEP 6: Validate cluster
echo "⏳ Validating cluster (waits up to 10 minutes)..."
kops validate cluster --name iqran.k8s.local --wait 10m

