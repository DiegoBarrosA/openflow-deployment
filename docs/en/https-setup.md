# HTTPS Setup Guide for EKS with Azure AD

This guide explains how to set up HTTPS for your OpenFlow deployment on AWS EKS to support Azure AD redirect URIs.

## Overview

Azure AD requires HTTPS for redirect URIs (except `http://localhost`). To enable HTTPS in EKS, we'll use:
- **AWS Application Load Balancer (ALB)** - Supports HTTPS termination
- **AWS Certificate Manager (ACM)** - Free SSL/TLS certificates
- **AWS Load Balancer Controller** - Kubernetes controller for ALB
- **Kubernetes Ingress** - Routes traffic to services

## Prerequisites

- EKS cluster running
- Domain name OR use ALB hostname (see options below)
- Access to domain DNS settings (if using custom domain)
- AWS CLI configured
- kubectl configured for your cluster

## Domain Options

### Option 1: Use ALB Hostname (Simplest, No Domain Needed)

You can use the ALB's default hostname that AWS provides (e.g., `k8s-openflow-xxxxx.us-east-1.elb.amazonaws.com`). However, **Azure AD requires HTTPS with a valid certificate**, and you cannot get an ACM certificate for the ALB hostname without owning the domain.

**Workaround**: Use a very cheap domain ($1-2/year) or see Option 2.

### Option 2: Cheap Domain ($1-2/year)

- **Namecheap**: Often has $0.99-1.88/year domains for first year
- **Google Domains**: $12/year for .com domains
- **Cloudflare Registrar**: At-cost pricing (~$8-10/year for .com)
- **Freenom**: Free .tk, .ml, .ga domains (less reliable, may not work with Azure AD)

### Option 3: Use Existing Domain

If you already own a domain, use a subdomain:
- `openflow.yourdomain.com` (frontend)
- `api-openflow.yourdomain.com` (backend)

### Option 4: Development Only - Use ngrok or Similar

For development/testing only:
- Use `ngrok` or `localtunnel` to create HTTPS tunnel
- Not recommended for production

## Step 1: Install AWS Load Balancer Controller

The AWS Load Balancer Controller manages ALB resources in Kubernetes.

### 1.1 Create IAM Policy

```bash
# Download the IAM policy
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.0/docs/install/iam_policy.json

# Create the policy
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

Note the Policy ARN for the next step.

### 1.2 Create IAM Service Account

```bash
# Replace with your cluster name and region
CLUSTER_NAME=openflow-cluster
REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
POLICY_ARN=arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy

# Create service account
eksctl create iamserviceaccount \
  --cluster=${CLUSTER_NAME} \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=${POLICY_ARN} \
  --approve
```

### 1.3 Install Controller via Helm

```bash
# Add EKS Helm repo
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=${CLUSTER_NAME} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### 1.4 Verify Installation

```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
```

## Step 2: Request SSL Certificate in ACM

### 2.1 Request Certificate

1. Go to **AWS Console** → **Certificate Manager**
2. Click **Request a certificate**
3. Select **Request a public certificate**
4. Enter your domain:
   - **Domain name**: `yourdomain.com`
   - **Subject alternative names**: 
     - `*.yourdomain.com` (wildcard for subdomains)
     - `www.yourdomain.com` (if needed)
5. Choose **DNS validation** (recommended)
6. Click **Request**

### 2.2 Validate Certificate

1. ACM will provide DNS records to add
2. Add CNAME records to your domain DNS:
   - Go to your domain registrar (e.g., Route 53, GoDaddy, Namecheap)
   - Add the CNAME records provided by ACM
3. Wait for validation (usually 5-30 minutes)
4. Once validated, note the **Certificate ARN**

### 2.3 Alternative: Import Certificate

If you already have a certificate:
1. Go to **Certificate Manager**
2. Click **Import certificate**
3. Upload your certificate, private key, and certificate chain
4. Note the **Certificate ARN**

## Step 3: Update Kubernetes Services

The services need to be changed from `LoadBalancer` to `ClusterIP` since the Ingress will handle external access.

### 3.1 Update Backend Service

Update `kube.yaml` backend service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: openflow-backend
  labels:
    app: openflow-backend
spec:
  selector:
    app: openflow-backend
  ports:
    - name: http
      port: 80
      targetPort: 8080
  type: ClusterIP  # Changed from LoadBalancer
```

### 3.2 Update Frontend Service

Update `kube.yaml` frontend service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: openflow-frontend
  labels:
    app: openflow-frontend
spec:
  selector:
    app: openflow-frontend
  ports:
    - name: http
      port: 80
      targetPort: 80
  type: ClusterIP  # Changed from LoadBalancer
```

## Step 4: Create Ingress Resource

### 4.1 Update Ingress Configuration

Edit `kube-ingress.yaml`:

1. Replace `REPLACE_WITH_YOUR_ACM_CERTIFICATE_ARN` with your certificate ARN
2. Replace `yourdomain.com` with your actual domain
3. Replace `api.yourdomain.com` with your backend subdomain (if using separate domain)

### 4.2 Apply Ingress

```bash
kubectl apply -f kube-ingress.yaml
```

### 4.3 Get ALB Address

```bash
# Wait for ALB to be created (2-5 minutes)
kubectl get ingress openflow-ingress

# Get the ALB address
kubectl get ingress openflow-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## Step 5: Configure DNS

Point your domain to the ALB:

### 5.1 Get ALB Hostname

```bash
ALB_HOSTNAME=$(kubectl get ingress openflow-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo $ALB_HOSTNAME
```

### 5.2 Create DNS Records

#### Option A: Using Route 53

```bash
# Get hosted zone ID
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name yourdomain.com --query 'HostedZones[0].Id' --output text | cut -d'/' -f3)

# Create A record (alias to ALB)
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "yourdomain.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z35SXDOTRQ7X7K",
          "DNSName": "'$ALB_HOSTNAME'",
          "EvaluateTargetHealth": false
        }
      }
    }]
  }'

# Create A record for API subdomain
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "api.yourdomain.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z35SXDOTRQ7X7K",
          "DNSName": "'$ALB_HOSTNAME'",
          "EvaluateTargetHealth": false
        }
      }
    }]
  }'
```

**Note**: The HostedZoneId `Z35SXDOTRQ7X7K` is for ALB in us-east-1. For other regions, see [AWS documentation](https://docs.aws.amazon.com/general/latest/gr/elb.html).

#### Option B: Using Other DNS Providers

1. Create **A record** (alias) or **CNAME record**:
   - **Name**: `yourdomain.com` (or `@`)
   - **Type**: A (alias) or CNAME
   - **Value**: ALB hostname from Step 5.1
   - **TTL**: 300 (or default)

2. For API subdomain:
   - **Name**: `api.yourdomain.com`
   - **Type**: A (alias) or CNAME
   - **Value**: Same ALB hostname
   - **TTL**: 300

## Step 6: Update Azure AD Redirect URI

1. Go to **Azure Portal** → **Azure Active Directory** → **App registrations** → Your app
2. Go to **Authentication**
3. Update redirect URI:
   - **Type**: Web
   - **URI**: `https://api.yourdomain.com/login/oauth2/code/azure`
   - (Or `https://yourdomain.com/login/oauth2/code/azure` if using same domain)
4. Click **Save**

## Step 7: Update GitHub Secrets

Update the following secrets with your HTTPS URLs:

- `AZURE_ISSUER_URI`: `https://login.microsoftonline.com/{tenant-id}/v2.0` (unchanged)
- `AZURE_JWK_SET_URI`: `https://login.microsoftonline.com/{tenant-id}/discovery/v2.0/keys` (unchanged)

The redirect URI is configured in Azure Portal, not in GitHub Secrets.

## Step 8: Update CORS Configuration

The deployment workflow should automatically update CORS, but verify:

```bash
# Check current CORS setting
kubectl get deployment openflow-backend -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="CORS_ALLOWED_ORIGINS")].value}'

# Should show: https://yourdomain.com
```

If needed, update manually:

```bash
kubectl set env deployment/openflow-backend CORS_ALLOWED_ORIGINS="https://yourdomain.com"
```

## Step 9: Verify HTTPS Setup

### 9.1 Test HTTPS Access

```bash
# Test frontend
curl -I https://yourdomain.com

# Test backend
curl -I https://api.yourdomain.com/api/status

# Should return HTTP 200 or 401 (if auth required)
```

### 9.2 Test Azure AD Redirect

1. Open browser: `https://yourdomain.com`
2. Click "Sign in with Microsoft"
3. Should redirect to Azure AD login
4. After login, should redirect back to `https://api.yourdomain.com/login/oauth2/code/azure`

### 9.3 Check Certificate

```bash
# Check certificate details
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com < /dev/null 2>/dev/null | openssl x509 -noout -dates
```

## Troubleshooting

### ALB Not Created

**Symptoms**: `kubectl get ingress` shows no address

**Solutions**:
1. Check controller logs:
   ```bash
   kubectl logs -n kube-system deployment/aws-load-balancer-controller
   ```
2. Verify IAM permissions
3. Check certificate ARN is correct
4. Verify certificate is in the same region as your cluster

### Certificate Not Found

**Error**: `CertificateNotFound` in controller logs

**Solutions**:
1. Verify certificate ARN is correct
2. Ensure certificate is in the same AWS region as your EKS cluster
3. Check certificate status in ACM (should be "Issued")

### DNS Not Resolving

**Symptoms**: Domain doesn't resolve to ALB

**Solutions**:
1. Verify DNS records are correct
2. Wait for DNS propagation (can take up to 48 hours, usually 5-30 minutes)
3. Check DNS with: `dig yourdomain.com` or `nslookup yourdomain.com`
4. Verify ALB hostname is correct

### HTTPS Redirect Loop

**Symptoms**: Infinite redirects

**Solutions**:
1. Check Ingress annotation: `alb.ingress.kubernetes.io/ssl-redirect: '443'`
2. Verify backend services are responding on HTTP (not HTTPS)
3. Check ALB listener configuration

### Azure AD Redirect Fails

**Symptoms**: "Redirect URI mismatch" error

**Solutions**:
1. Verify redirect URI in Azure Portal matches exactly:
   - `https://api.yourdomain.com/login/oauth2/code/azure`
2. Check for trailing slashes
3. Verify HTTPS is working: `curl -I https://api.yourdomain.com`

## Cost Considerations

- **ALB**: ~$16/month + data transfer costs
- **ACM Certificate**: Free
- **Data Transfer**: Standard AWS data transfer pricing

Compare to NLB (current setup): ~$16/month, but NLB doesn't support HTTPS termination.

## Alternative: Single Domain Setup

If you prefer a single domain instead of separate API subdomain:

1. Use one domain: `yourdomain.com`
2. Frontend at: `https://yourdomain.com`
3. Backend API at: `https://yourdomain.com/api`
4. Azure AD redirect: `https://yourdomain.com/login/oauth2/code/azure`

Update the Ingress configuration accordingly.

## Next Steps

- Review [Azure AD Setup Guide](azure-ad-setup.md) for Azure Portal configuration
- Check [GitHub Secrets Setup Guide](github-secrets-setup.md) for secret configuration
- See [Architecture Documentation](architecture.md) for system overview

