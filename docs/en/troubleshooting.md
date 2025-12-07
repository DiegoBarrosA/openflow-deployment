# Troubleshooting Guide

This guide helps you diagnose and fix common deployment issues with OpenFlow on EKS.

## Quick Diagnostics

### Check Overall Status

```bash
# Connect to cluster first
aws eks update-kubeconfig --region us-east-1 --name openflow-cluster

# Check all OpenFlow resources
kubectl get pods,services,deployments | grep openflow

# Expected output:
# - Backend pod: Should be Running (1/1)
# - Frontend pod: Should be Running (1/1)
# - Services: Should have EXTERNAL-IP or pending
```

## Common Issues

### 1. Backend Pod: ImagePullBackOff

**Symptoms:**
```bash
kubectl get pods | grep openflow-backend
# Shows: ImagePullBackOff or ErrImagePull
```

**Error Message:**
```
Failed to pull image: failed to authorize: 
failed to fetch oauth token: 403 Forbidden
```

**Root Cause:**
The GitHub Container Registry (GHCR) image is private or the authentication token lacks permissions.

**Solutions:**

#### Solution A: Make Package Public (Easiest)

**Note:** If your frontend package is already public (check at `https://github.com/users/DiegoBarrosA/packages/container/openflow-frontend`), you need to make the backend package public too.

1. Go to GitHub → Your profile/org → **Packages**
   - Direct link: `https://github.com/users/DiegoBarrosA/packages/container/openflow-backend`
2. Find `openflow-backend` package
3. Click on the package name
4. Click **Package settings** (gear icon or settings link in the right sidebar)
5. Scroll down to **Danger Zone** section
6. Click **Change visibility**
7. Select **Make public**
8. Confirm the change

#### Solution B: Fix Authentication Secret

The workflow uses `GITHUB_TOKEN` which may not have package read permissions.

1. **Create a Personal Access Token (PAT):**
   - GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with `read:packages` scope
   - Copy the token

2. **Update the secret manually:**
   ```bash
   kubectl delete secret ghcr-secret
   
   kubectl create secret docker-registry ghcr-secret \
     --docker-server=ghcr.io \
     --docker-username=YOUR_GITHUB_USERNAME \
     --docker-password=YOUR_PAT_TOKEN
   ```

3. **Restart the backend pod:**
   ```bash
   kubectl delete pod -l app=openflow-backend
   ```

#### Solution C: Update Workflow Permissions

1. Go to repository → **Settings** → **Actions** → **General**
2. Under **Workflow permissions**, select:
   - ✅ **Read and write permissions**
   - ✅ **Allow GitHub Actions to create and approve pull requests**
3. Save changes
4. Re-run the deployment workflow

### 2. Frontend Pod: ImagePullBackOff

Same issue as backend. Apply the same solutions above, but for `openflow-frontend` package.

**Note:** If frontend shows `Running (1/1)`, it's working correctly. The frontend is likely fine.

### 3. Backend Pod: CrashLoopBackOff

**Symptoms:**
```bash
kubectl get pods | grep openflow-backend
# Shows: CrashLoopBackOff
```

**Diagnosis:**
```bash
# Check pod events
kubectl describe pod -l app=openflow-backend

# Check container logs
kubectl logs -l app=openflow-backend --tail=100
```

**Common Causes:**

#### A. Database Connection Failure

**Error in logs:**
```
Unable to connect to database
ORA-12154: TNS:could not resolve the connect identifier
```

**Solution:**
1. Verify `ORACLE_DB_URL` secret value matches service name in `tnsnames.ora`
2. Check wallet secret is mounted:
   ```bash
   kubectl describe pod -l app=openflow-backend | grep -A 10 "Mounts"
   ```
3. Verify wallet files exist in secret:
   ```bash
   kubectl get secret oracle-wallet-secret -o jsonpath='{.data}' | jq 'keys'
   ```

#### B. Missing Environment Variables

**Error in logs:**
```
Required environment variable 'ORACLE_SERVICE_NAME' is not set
```

**Solution:**
1. Check secrets exist:
   ```bash
   kubectl get secrets | grep -E "oracle-db-secret|app-secrets"
   ```
2. Verify secret keys:
   ```bash
   kubectl get secret oracle-db-secret -o jsonpath='{.data}' | jq 'keys'
   # Should show: username, password, db-url
   ```
3. Check pod environment:
   ```bash
   kubectl describe pod -l app=openflow-backend | grep -A 20 "Environment"
   ```

#### C. Wallet Files Not Found

**Error in logs:**
```
TNS_ADMIN directory not found or wallet files missing
```

**Solution:**
1. Verify wallet secret:
   ```bash
   kubectl get secret oracle-wallet-secret
   ```
2. Check wallet files in secret:
   ```bash
   kubectl get secret oracle-wallet-secret -o jsonpath='{.data}' | jq 'keys'
   # Should show: cwallet.sso, ewallet.p12, keystore.jks, etc.
   ```
3. Recreate wallet secret if missing files (re-run deployment workflow)

### 4. Services: EXTERNAL-IP Pending

**Symptoms:**
```bash
kubectl get services | grep openflow
# EXTERNAL-IP shows <pending>
```

**Diagnosis:**
```bash
# Check service details
kubectl describe service openflow-backend
kubectl describe service openflow-frontend
```

**Common Causes:**

#### A. LoadBalancer Provisioning

AWS LoadBalancer creation can take 2-5 minutes. Wait and check again:
```bash
kubectl get services -w
# Watch for EXTERNAL-IP to appear
```

#### B. AWS Quota/Service Limits

**Error in service events:**
```
Error creating load balancer: insufficient capacity
```

**Solution:**
1. Check AWS Console → EC2 → Load Balancers
2. Verify you haven't exceeded LoadBalancer quota
3. Delete unused LoadBalancers if needed
4. Try a different AWS region

#### C. IAM Permissions

**Error:**
```
User is not authorized to perform: elasticloadbalancing:CreateLoadBalancer
```

**Solution:**
1. Verify IAM user/role has ELB permissions
2. Add policy: `ElasticLoadBalancingFullAccess` (or more restrictive)
3. Re-run deployment

### 5. Frontend Can't Reach Backend

**Symptoms:**
- Frontend loads but API calls fail
- Browser console shows connection errors

**Diagnosis:**
```bash
# Check if services can resolve each other
kubectl run -it --rm debug --image=busybox --restart=Never -- \
  wget -qO- http://openflow-backend:8080/api/status
```

**Common Causes:**

#### A. Backend Service Not Running

```bash
# Check backend pod
kubectl get pods | grep openflow-backend
# Should be Running

# Check backend service
kubectl get service openflow-backend
# Should have ClusterIP
```

#### B. CORS Configuration

If frontend and backend are on different domains, CORS might block requests.

**Solution:**
1. Check CORS configuration in `kube.yaml`:
   ```yaml
   env:
     - name: CORS_ALLOWED_ORIGINS
       value: "*"  # Or specific origins
   ```
2. Update to include frontend URL if needed
3. Redeploy

### 6. Database Connection: Authentication Failed

**Error in logs:**
```
ORA-01017: invalid username/password; logon denied
```

**Solution:**
1. Verify database credentials:
   ```bash
   kubectl get secret oracle-db-secret -o jsonpath='{.data.username}' | base64 -d
   kubectl get secret oracle-db-secret -o jsonpath='{.data.password}' | base64 -d
   ```
2. Test credentials manually (if you have SQL client)
3. Update GitHub Secrets if incorrect
4. Re-run deployment workflow

## Diagnostic Commands Reference

### Check Pod Status
```bash
# All OpenFlow pods
kubectl get pods -l 'app in (openflow-backend,openflow-frontend)'

# Specific pod
kubectl get pod openflow-backend-xxxxx
```

### View Pod Logs
```bash
# Current logs
kubectl logs -l app=openflow-backend

# Follow logs
kubectl logs -f -l app=openflow-backend

# Previous container logs (if restarted)
kubectl logs -l app=openflow-backend --previous
```

### Check Secrets
```bash
# List all secrets
kubectl get secrets | grep openflow

# Check secret exists
kubectl get secret oracle-db-secret

# View secret keys (not values)
kubectl get secret oracle-db-secret -o jsonpath='{.data}' | jq 'keys'
```

### Check Services
```bash
# All services
kubectl get services | grep openflow

# Service details
kubectl describe service openflow-backend

# Get service URL
kubectl get service openflow-backend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

### Check Deployments
```bash
# Deployment status
kubectl get deployments | grep openflow

# Deployment details
kubectl describe deployment openflow-backend

# Deployment history
kubectl rollout history deployment/openflow-backend
```

### Restart Resources
```bash
# Restart deployment (rolling update)
kubectl rollout restart deployment/openflow-backend

# Delete pod (will be recreated)
kubectl delete pod -l app=openflow-backend

# Scale deployment
kubectl scale deployment/openflow-backend --replicas=0
kubectl scale deployment/openflow-backend --replicas=1
```

## Getting Help

If issues persist:

1. **Collect diagnostic information:**
   ```bash
   # Save all output
   kubectl get all -l app=openflow-backend -o yaml > backend-status.yaml
   kubectl logs -l app=openflow-backend > backend-logs.txt
   kubectl describe pod -l app=openflow-backend > backend-describe.txt
   ```

2. **Check GitHub Actions workflow logs:**
   - Go to repository → Actions
   - Find the failed workflow run
   - Review all step logs

3. **Verify GitHub Secrets:**
   - Go to repository → Settings → Secrets
   - Ensure all required secrets are present
   - Verify secret names match exactly (case-sensitive)

4. **Review documentation:**
   - [Installation Guide](installation.md)
   - [GitHub Secrets Setup](github-secrets-setup.md)
   - [Architecture Overview](overview.md)

