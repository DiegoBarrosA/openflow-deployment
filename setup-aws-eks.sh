#!/bin/bash

# AWS EKS Cluster Setup for OpenFlow
# This script creates a free-tier EKS cluster

set -e

# Configuration
CLUSTER_NAME="openflow-cluster"
REGION="us-east-1"
NODE_TYPE="t3.micro"  # Free tier eligible
NODE_COUNT=1

echo "🚀 Setting up AWS EKS Cluster for OpenFlow"
echo "=========================================="

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI not configured. Please run:"
    echo "aws configure"
    exit 1
fi

# Check if eksctl is installed
if ! command -v eksctl &> /dev/null; then
    echo "📦 Installing eksctl..."
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
fi

echo "🔍 Checking for existing cluster..."
if eksctl get cluster --name "$CLUSTER_NAME" --region "$REGION" &> /dev/null; then
    echo "✅ Cluster '$CLUSTER_NAME' already exists"
else
    echo "🏗️  Creating EKS cluster..."
    eksctl create cluster \
        --name "$CLUSTER_NAME" \
        --region "$REGION" \
        --node-type "$NODE_TYPE" \
        --nodes "$NODE_COUNT" \
        --node-volume-size 20 \
        --managed \
        --with-oidc \
        --ssh-access \
        --ssh-public-key ~/.ssh/id_rsa.pub 2>/dev/null || true

    echo "✅ Cluster created successfully!"
fi

# Configure kubectl
echo "🔧 Configuring kubectl..."
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

# Verify cluster
echo "🔍 Verifying cluster..."
kubectl get nodes
kubectl get pods -A

echo ""
echo "�� EKS Cluster Setup Complete!"
echo ""
echo "📋 Next steps:"
echo "1. Add these to GitHub Secrets:"
echo "   - AWS_ACCESS_KEY_ID"
echo "   - AWS_SECRET_ACCESS_KEY"
echo "   - ORACLE_DB_USERNAME"
echo "   - ORACLE_DB_PASSWORD"
echo "   - ORACLE_DB_URL"
echo "   - JWT_SECRET"
echo "   - ORACLE_WALLET_* (base64 encoded wallet files)"
echo ""
echo "2. Run GitHub Actions workflow to deploy"
echo ""
echo "💰 Free tier note: t3.micro instances are free for 750 hours/month"
echo "   Monitor usage at: https://console.aws.amazon.com/billing/home"
