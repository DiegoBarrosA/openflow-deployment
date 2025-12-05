# DNS Configuration Guide for OpenFlow

This guide explains how to configure DNS records to point `app.openflow.world` and `api.openflow.world` to your ALB.

## Prerequisites

1. **Get ALB hostname** from Kubernetes:
   ```bash
   kubectl get ingress openflow-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
   ```
   
   Example output: `k8s-openflow-openflowing-xxxxx.us-east-1.elb.amazonaws.com`

2. **Know your DNS provider** (where you manage DNS for `openflow.world`)

## Option 1: Automated Setup (Route 53)

If you're using AWS Route 53, use the automated script:

```bash
cd openflow-deployment
./setup-dns.sh
```

The script will:
- Get ALB hostname automatically
- Create A records (alias) for both subdomains
- Configure everything automatically

## Option 2: Manual Setup - AWS Route 53

### Step 1: Get ALB Hostname

```bash
kubectl get ingress openflow-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Copy the hostname (e.g., `k8s-openflow-openflowing-xxxxx.us-east-1.elb.amazonaws.com`)

### Step 2: Get Hosted Zone ID

1. Go to **AWS Console** → **Route 53** → **Hosted zones**
2. Find `openflow.world`
3. Note the **Hosted Zone ID** (e.g., `Z1234567890ABC`)

### Step 3: Create DNS Records

#### For app.openflow.world:

1. Click **Create record**
2. Configure:
   - **Record name**: `app`
   - **Record type**: `A`
   - **Alias**: **Yes**
   - **Route traffic to**: 
     - **Alias to Application and Classic Load Balancer**
     - **Region**: `us-east-1` (or your region)
     - **Load balancer**: Select your ALB (or paste ALB hostname)
   - **Routing policy**: **Simple routing**
   - **Evaluate target health**: **No**
3. Click **Create records**

#### For api.openflow.world:

1. Click **Create record**
2. Configure:
   - **Record name**: `api`
   - **Record type**: `A`
   - **Alias**: **Yes**
   - **Route traffic to**: 
     - **Alias to Application and Classic Load Balancer**
     - **Region**: `us-east-1` (or your region)
     - **Load balancer**: Select your ALB (same as above)
   - **Routing policy**: **Simple routing**
   - **Evaluate target health**: **No**
3. Click **Create records**

### Step 4: Verify Records

```bash
# Check DNS resolution (may take a few minutes)
dig app.openflow.world
dig api.openflow.world
```

## Option 3: Manual Setup - Other DNS Providers

If you're using Namecheap, GoDaddy, Cloudflare, or another provider:

### Step 1: Get ALB Hostname

```bash
kubectl get ingress openflow-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

### Step 2: Create CNAME Records

#### For Namecheap:

1. Log in to **Namecheap**
2. Go to **Domain List** → Click **Manage** next to `openflow.world`
3. Go to **Advanced DNS** tab
4. Click **Add New Record**

**Record 1 - Frontend:**
- **Type**: `CNAME Record`
- **Host**: `app`
- **Value**: `k8s-openflow-openflowing-xxxxx.us-east-1.elb.amazonaws.com` (your ALB hostname)
- **TTL**: `Automatic` (or `300`)
- Click **Save**

**Record 2 - Backend:**
- **Type**: `CNAME Record`
- **Host**: `api`
- **Value**: `k8s-openflow-openflowing-xxxxx.us-east-1.elb.amazonaws.com` (same ALB hostname)
- **TTL**: `Automatic` (or `300`)
- Click **Save**

#### For GoDaddy:

1. Log in to **GoDaddy**
2. Go to **My Products** → **DNS** next to `openflow.world`
3. Scroll to **Records** section
4. Click **Add**

**Record 1 - Frontend:**
- **Type**: `CNAME`
- **Name**: `app`
- **Value**: `k8s-openflow-openflowing-xxxxx.us-east-1.elb.amazonaws.com`
- **TTL**: `600` (10 minutes)
- Click **Save**

**Record 2 - Backend:**
- **Type**: `CNAME`
- **Name**: `api`
- **Value**: `k8s-openflow-openflowing-xxxxx.us-east-1.elb.amazonaws.com`
- **TTL**: `600`
- Click **Save**

#### For Cloudflare:

1. Log in to **Cloudflare**
2. Select `openflow.world`
3. Go to **DNS** → **Records**
4. Click **Add record**

**Record 1 - Frontend:**
- **Type**: `CNAME`
- **Name**: `app`
- **Target**: `k8s-openflow-openflowing-xxxxx.us-east-1.elb.amazonaws.com`
- **Proxy status**: **DNS only** (gray cloud) - Important for ALB!
- **TTL**: `Auto`
- Click **Save**

**Record 2 - Backend:**
- **Type**: `CNAME`
- **Name**: `api`
- **Target**: `k8s-openflow-openflowing-xxxxx.us-east-1.elb.amazonaws.com`
- **Proxy status**: **DNS only** (gray cloud) - Important for ALB!
- **TTL**: `Auto**
- Click **Save**

**Important for Cloudflare**: Make sure the proxy is **OFF** (gray cloud). ALB needs direct DNS resolution, not Cloudflare's proxy.

#### For Other Providers:

Create CNAME records:
- **Name/Host**: `app` (for app.openflow.world)
- **Name/Host**: `api` (for api.openflow.world)
- **Type**: `CNAME`
- **Value/Target**: Your ALB hostname
- **TTL**: `300` or `600` seconds

## Option 4: Using AWS CLI (Route 53)

If you prefer command line:

```bash
# Set variables
DOMAIN="openflow.world"
ALB_HOSTNAME="k8s-openflow-openflowing-xxxxx.us-east-1.elb.amazonaws.com"  # Replace with your ALB hostname
REGION="us-east-1"  # Your AWS region

# Get hosted zone ID
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name "$DOMAIN" --query 'HostedZones[0].Id' --output text | cut -d'/' -f3)

# ALB hosted zone ID (us-east-1)
ALB_HOSTED_ZONE_ID="Z35SXDOTRQ7X7K"

# For other regions, use:
# us-east-2: Z3AADJGX6KTTL2
# us-west-1: Z368ELLRRE2KJ0
# us-west-2: Z1H1FL5HABSF5

# Create frontend record
aws route53 change-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --change-batch "{
    \"Changes\": [{
      \"Action\": \"UPSERT\",
      \"ResourceRecordSet\": {
        \"Name\": \"app.$DOMAIN\",
        \"Type\": \"A\",
        \"AliasTarget\": {
          \"HostedZoneId\": \"$ALB_HOSTED_ZONE_ID\",
          \"DNSName\": \"$ALB_HOSTNAME\",
          \"EvaluateTargetHealth\": false
        }
      }
    }]
  }"

# Create backend record
aws route53 change-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --change-batch "{
    \"Changes\": [{
      \"Action\": \"UPSERT\",
      \"ResourceRecordSet\": {
        \"Name\": \"api.$DOMAIN\",
        \"Type\": \"A\",
        \"AliasTarget\": {
          \"HostedZoneId\": \"$ALB_HOSTED_ZONE_ID\",
          \"DNSName\": \"$ALB_HOSTNAME\",
          \"EvaluateTargetHealth\": false
        }
      }
    }]
  }"

echo "✅ DNS records created!"
```

## Verification

After creating DNS records, verify they're working:

### 1. Check DNS Resolution

```bash
# Check frontend
dig app.openflow.world +short
# Should return: ALB IP addresses or CNAME

# Check backend
dig api.openflow.world +short
# Should return: ALB IP addresses or CNAME

# Or use nslookup
nslookup app.openflow.world
nslookup api.openflow.world
```

### 2. Test HTTPS Access

Wait 5-30 minutes for DNS propagation, then:

```bash
# Test frontend
curl -I https://app.openflow.world

# Test backend
curl -I https://api.openflow.world/api/status
```

### 3. Check in Browser

- Frontend: `https://app.openflow.world`
- Backend API: `https://api.openflow.world/api/status`

## Troubleshooting

### DNS Not Resolving

**Symptoms**: `dig` or `nslookup` returns nothing or wrong IP

**Solutions**:
1. Wait 5-30 minutes for DNS propagation
2. Check DNS records are correct in your provider
3. Verify ALB hostname is correct
4. Clear DNS cache: `sudo systemd-resolve --flush-caches` (Linux) or `sudo dscacheutil -flushcache` (macOS)

### SSL Certificate Error

**Symptoms**: Browser shows "Not Secure" or certificate error

**Solutions**:
1. Verify certificate is issued in ACM
2. Check certificate ARN in Ingress matches your certificate
3. Ensure certificate covers both `app.openflow.world` and `api.openflow.world`
4. Wait for certificate to propagate (can take a few minutes)

### ALB Not Found

**Symptoms**: DNS resolves but connection fails

**Solutions**:
1. Check ALB exists: `aws elbv2 describe-load-balancers`
2. Verify Ingress is deployed: `kubectl get ingress`
3. Check ALB security groups allow traffic
4. Verify pods are running: `kubectl get pods`

### Cloudflare Proxy Issues

**Symptoms**: Works with proxy OFF, fails with proxy ON

**Solution**: 
- Keep Cloudflare proxy **OFF** (gray cloud) for ALB
- ALB needs direct DNS resolution, not Cloudflare's proxy

## Quick Reference

### ALB Hosted Zone IDs by Region

- **us-east-1**: `Z35SXDOTRQ7X7K`
- **us-east-2**: `Z3AADJGX6KTTL2`
- **us-west-1**: `Z368ELLRRE2KJ0`
- **us-west-2**: `Z1H1FL5HABSF5`
- **eu-west-1**: `Z3F0SRJ5LGBH90`
- **ap-southeast-1**: `Z1LMS91P8CMLE5`

For other regions, see: https://docs.aws.amazon.com/general/latest/gr/elb.html

### DNS Record Summary

| Subdomain | Type | Value |
|-----------|------|-------|
| `app.openflow.world` | A (Alias) or CNAME | ALB hostname |
| `api.openflow.world` | A (Alias) or CNAME | ALB hostname |

Both point to the **same ALB hostname** - the Ingress routes based on the Host header.

## Next Steps

After DNS is configured:
1. Wait for DNS propagation (5-30 minutes)
2. Update Azure AD redirect URI: `https://api.openflow.world/login/oauth2/code/azure`
3. Test the application
4. Verify HTTPS is working

See [Azure AD Setup Guide](azure-ad-setup.md) for Azure Portal configuration.

