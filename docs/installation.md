# EKS Deployment Installation Guide

This guide walks you through deploying OpenFlow to AWS EKS (Elastic Kubernetes Service) using GitHub Actions.

## Prerequisites

### Required Accounts and Services

- **AWS Account** with EKS permissions
- **Oracle Cloud Account** with Autonomous Database instance
- **GitHub Account** with repository access
- **kubectl** installed and configured
- **AWS CLI** installed and configured

### AWS Requirements

- AWS CLI configured with credentials
- Permissions to create EKS clusters (or access to existing cluster)
- Permissions to create LoadBalancers in your AWS region

### Oracle Database Requirements

- Oracle Autonomous Database instance created
- Database wallet files downloaded
- Database credentials (username, password, service name)

## Step 1: Set Up AWS EKS Cluster

### Option A: Use Existing Cluster

If you already have an EKS cluster:

```bash
# Configure kubectl to use your cluster
aws eks update-kubeconfig --region us-east-1 --name your-cluster-name
```

### Option B: Create New Cluster (Optional)

The repository includes an optional setup script:

```bash
cd openflow-deployment
chmod +x setup-aws-eks.sh
./setup-aws-eks.sh
```

This script:
- Creates a free-tier EKS cluster named `openflow-cluster`
- Uses 1 t3.micro node (750 free hours/month)
- Configures kubectl automatically

**Note:** The cluster name is hardcoded as `openflow-cluster` in the script. If you use a different name, update the `EKS_CLUSTER_NAME` in the GitHub Actions workflow.

## Step 2: Prepare Oracle Database Wallet

1. **Download Wallet from Oracle Cloud Console:**
   - Navigate to your Autonomous Database
   - Go to **DB Connection** → **Download Wallet**
   - Extract the ZIP file to a temporary location

2. **Encode Wallet Files:**
   ```bash
   cd openflow-deployment
   # Create a temporary wallet directory
   mkdir -p wallet-temp
   # Extract wallet files to wallet-temp/
   unzip Wallet_yourdb.zip -d wallet-temp/
   # Rename to 'wallet' for the script
   mv wallet-temp wallet
   # Run encoding script
   ./encode-wallet.sh
   ```

3. **Review Generated Secrets:**
   The script creates `wallet-secrets.env` with base64-encoded values.

   ⚠️ **SECURITY:** Delete `wallet-secrets.env` and the `wallet/` directory immediately after copying values to GitHub Secrets.

## Step 3: Configure GitHub Secrets

Navigate to your GitHub repository: **Settings → Secrets and variables → Actions**

### Required Secrets

#### AWS Credentials
- `AWS_ACCESS_KEY_ID` - Your AWS access key
- `AWS_SECRET_ACCESS_KEY` - Your AWS secret key
- `AWS_SESSION_TOKEN` - (Optional) If using temporary credentials

#### Oracle Database
- `ORACLE_DB_USERNAME` - Database username
- `ORACLE_DB_PASSWORD` - Database password
- `ORACLE_DB_URL` - Database service name (e.g., `s5fjid90p5pnlifv_high`)

#### Application Secrets
- `JWT_SECRET` - A secure random string for JWT token signing
  ```bash
  # Generate a secure JWT secret
  openssl rand -base64 32
  ```

#### Oracle Wallet Files (Base64 Encoded)
Copy the values from `wallet-secrets.env` (generated in Step 2):

- `ORACLE_WALLET_CWALLET` - Base64 encoded `cwallet.sso`
- `ORACLE_WALLET_EWALLET` - Base64 encoded `ewallet.p12`
- `ORACLE_WALLET_KEYSTORE` - Base64 encoded `keystore.jks`
- `ORACLE_WALLET_OJDBC` - Base64 encoded `ojdbc.properties`
- `ORACLE_WALLET_SQLNET` - Base64 encoded `sqlnet.ora`
- `ORACLE_WALLET_TNSNAMES` - Base64 encoded `tnsnames.ora`
- `ORACLE_WALLET_TRUSTSTORE` - Base64 encoded `truststore.jks`

**Note:** The workflow expects these exact secret names. See [GitHub Secrets Setup Guide](github-secrets-setup.md) for detailed instructions.

## Step 4: Deploy to EKS

### Automatic Deployment

The deployment workflow (`deploy-on-image-update.yml`) triggers on:
- Push to `main` branch
- Manual workflow dispatch
- `repository_dispatch` event (from backend/frontend repos)

Simply push your changes:

```bash
git add .
git commit -m "Deploy to EKS"
git push origin main
```

### Manual Deployment

You can also trigger the workflow manually:

1. Go to **Actions** tab in GitHub
2. Select **Deploy (on image update or manual)**
3. Click **Run workflow**
4. Choose environment (staging/production)
5. Click **Run workflow**

## Step 5: Connect to EKS Cluster

Before verifying deployment, you need to configure `kubectl` to connect to your EKS cluster.

### Connect to Cluster

```bash
# Configure kubectl to use your EKS cluster
aws eks update-kubeconfig --region us-east-1 --name openflow-cluster
```

**Note:** Replace `us-east-1` with your AWS region and `openflow-cluster` with your cluster name if different.

### Verify Connection

```bash
# Test connection
kubectl get nodes

# Should show your EKS nodes
```

If you see your nodes listed, the connection is successful.

## Step 6: Verify Deployment

### Check Deployment Status

```bash
# Check all OpenFlow pods
kubectl get pods | grep openflow

# Check services
kubectl get services | grep openflow

# Check deployments
kubectl get deployments | grep openflow
```

### Get Service URLs

```bash
# Backend URL
kubectl get svc openflow-backend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Frontend URL
kubectl get svc openflow-frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

### View Logs

```bash
# Backend logs
kubectl logs -l app=openflow-backend

# Frontend logs
kubectl logs -l app=openflow-frontend

# Follow logs
kubectl logs -f deployment/openflow-backend
```

### Test Application

```bash
# Test backend API
curl http://<backend-loadbalancer-url>:8080/api/status

# Test frontend
curl http://<frontend-loadbalancer-url>
```

## Configuration

### Environment Variables

The deployment uses Kubernetes secrets for sensitive data. To modify configuration:

1. Update `kube.yaml` environment variables
2. Commit and push changes
3. The workflow will redeploy automatically

### Resource Limits

Default resource limits in `kube.yaml`:

**Backend:**
- Requests: 512Mi memory, 250m CPU
- Limits: 1Gi memory, 500m CPU

**Frontend:**
- Requests: 128Mi memory, 100m CPU
- Limits: 256Mi memory, 200m CPU

Adjust these in `kube.yaml` based on your needs.

### CORS Configuration

CORS is currently set to allow all origins (`*`). To restrict:

1. Update `CORS_ALLOWED_ORIGINS` in `kube.yaml`
2. Set to comma-separated list of allowed origins
3. Redeploy

## Troubleshooting

### Backend Pod Not Starting

```bash
# Check pod status
kubectl get pods | grep openflow-backend

# Check detailed pod information
kubectl describe pod -l app=openflow-backend

# Check logs (if container started)
kubectl logs -l app=openflow-backend

# Common issues and solutions:

# 1. ImagePullBackOff - Cannot pull image from GHCR
#    See "Image Pull Errors" section above

# 2. Missing secrets
kubectl get secrets | grep -E "oracle-db-secret|app-secrets|oracle-wallet-secret"
# If missing, check GitHub Secrets are configured and workflow ran successfully

# 3. Database connection failure
# Verify ORACLE_DB_URL matches service name in tnsnames.ora
# Check database credentials in oracle-db-secret

# 4. Wallet mount issues
kubectl describe pod -l app=openflow-backend | grep -A 5 "oracle-wallet"
# Verify oracle-wallet-secret exists and has all wallet files
```

### Frontend Pod Not Starting

```bash
# Check pod status
kubectl get pods | grep openflow-frontend

# If pod shows as Running, frontend is working
# If not, check detailed status:
kubectl describe pod -l app=openflow-frontend

# Check logs
kubectl logs -l app=openflow-frontend

# Common issues:
# - ImagePullBackOff (same as backend - see Image Pull Errors)
# - Port conflicts (unlikely in Kubernetes)
# - Resource limits (check if pod is OOMKilled)
```

### Database Connection Issues

1. Verify `ORACLE_DB_URL` matches service name in `tnsnames.ora`
2. Check wallet secret is properly mounted
3. Verify database credentials in `oracle-db-secret`
4. Check network connectivity from EKS to Oracle Cloud

### Image Pull Errors (403 Forbidden from GHCR)

**Error**: `failed to authorize: failed to fetch oauth token: unexpected status from GET request to https://ghcr.io/token: 403 Forbidden`

**Cause**: The GitHub Container Registry image is private or the authentication token doesn't have proper permissions.

**Solutions**:

1. **Check if image exists and is accessible:**
   ```bash
   # Verify image pull secret exists
   kubectl get secret ghcr-secret
   
   # Check secret details
   kubectl describe secret ghcr-secret
   ```

2. **Make the package public (if using public images):**
   - Go to GitHub → Your repository → Packages
   - Find the `openflow-backend` package
   - Go to Package settings → Change visibility to Public

3. **Use a Personal Access Token (PAT) instead of GITHUB_TOKEN:**
   - Create a PAT with `read:packages` scope
   - Update the workflow to use PAT instead of GITHUB_TOKEN
   - Or manually create the secret:
     ```bash
     kubectl create secret docker-registry ghcr-secret \
       --docker-server=ghcr.io \
       --docker-username=YOUR_GITHUB_USERNAME \
       --docker-password=YOUR_PAT_TOKEN \
       --dry-run=client -o yaml | kubectl apply -f -
     ```

4. **Verify package permissions:**
   - Ensure the GitHub Actions workflow has permission to read packages
   - Check repository settings → Actions → General → Workflow permissions
   - Enable "Read and write permissions" or at least "Read package permissions"

5. **Recreate the image pull secret:**
   ```bash
   # Delete existing secret
   kubectl delete secret ghcr-secret
   
   # The workflow will recreate it on next deployment
   # Or manually create with PAT (see step 3)
   ```

6. **Check pod events for detailed error:**
   ```bash
   kubectl describe pod -l app=openflow-backend
   # Look for Events section at the bottom
   ```

### LoadBalancer Not Provisioning

- Check AWS quota for LoadBalancers in your region
- Verify IAM permissions for ELB service
- Check AWS console for LoadBalancer creation errors

## Cleanup

### Delete Deployment

```bash
# Delete all resources
kubectl delete -f kube.yaml

# Or delete individually
kubectl delete deployment openflow-backend openflow-frontend
kubectl delete service openflow-backend openflow-frontend
kubectl delete secret oracle-db-secret app-secrets oracle-wallet-secret ghcr-secret
```

### Delete EKS Cluster (if created by script)

```bash
eksctl delete cluster --name openflow-cluster --region us-east-1
```

## Next Steps

- Review [Architecture Documentation](architecture.md)
- Check [Workflow Documentation](workflows.md)
- See [GitHub Secrets Setup Guide](github-secrets-setup.md) for detailed secret configuration
