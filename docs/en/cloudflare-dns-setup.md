# Cloudflare DNS Automation Setup

This guide explains how to set up automatic DNS record updates using Cloudflare API during deployment.

## Overview

The deployment workflow automatically updates Cloudflare DNS records when the ALB is created, pointing:
- `app.openflow.world` → ALB hostname
- `api.openflow.world` → ALB hostname

## Prerequisites

1. Domain `openflow.world` managed in Cloudflare
2. Cloudflare API token with DNS edit permissions
3. Cloudflare Zone ID for `openflow.world`

## Step 1: Get Cloudflare Zone ID

1. Log in to **Cloudflare Dashboard**
2. Select `openflow.world`
3. Scroll down to **API** section on the right sidebar
4. Copy the **Zone ID** (e.g., `abc123def456ghi789`)

Alternatively, use API:
```bash
curl -X GET "https://api.cloudflare.com/client/v4/zones?name=openflow.world" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" | jq -r '.result[0].id'
```

## Step 2: Create Cloudflare API Token

1. Go to **Cloudflare Dashboard** → **My Profile** → **API Tokens**
2. Click **Create Token**
3. Click **Edit zone DNS** template (or create custom token)
4. Configure permissions:
   - **Permissions**: 
     - Zone → DNS → Edit
   - **Zone Resources**:
     - Include → Specific zone → `openflow.world`
5. Click **Continue to summary** → **Create Token**
6. **IMPORTANT**: Copy the token immediately - it's shown only once!

## Step 3: Add GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

### Add CLOUDFLARE_API_TOKEN
- **Name**: `CLOUDFLARE_API_TOKEN`
- **Value**: Your Cloudflare API token from Step 2
- Click **Add secret**

### Add CLOUDFLARE_ZONE_ID
- **Name**: `CLOUDFLARE_ZONE_ID`
- **Value**: Your Zone ID from Step 1
- Click **Add secret**

## Step 4: Verify Setup

The next deployment will automatically:
1. Create/update DNS records when ALB is ready
2. Point `app.openflow.world` to ALB
3. Point `api.openflow.world` to ALB
4. Set proxy to OFF (gray cloud) for ALB compatibility

## How It Works

1. **During Deployment**:
   - Workflow waits for ALB to be created
   - Gets ALB hostname from Ingress
   - Calls Cloudflare API to update DNS records

2. **DNS Records Created**:
   - Type: `CNAME`
   - Name: `app` (for app.openflow.world)
   - Name: `api` (for api.openflow.world)
   - Content: ALB hostname
   - TTL: 300 seconds
   - Proxied: `false` (required for ALB)

3. **Automatic Updates**:
   - Records are updated on every deployment
   - If ALB hostname changes, DNS is updated automatically
   - No manual intervention needed

## Verification

After deployment, verify DNS records:

### Check in Cloudflare Dashboard

1. Go to **Cloudflare Dashboard** → `openflow.world` → **DNS**
2. Verify records exist:
   - `app` → CNAME → ALB hostname (gray cloud)
   - `api` → CNAME → ALB hostname (gray cloud)

### Check via API

```bash
curl -X GET "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/dns_records?type=CNAME" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" | jq '.result[] | {name: .name, content: .content, proxied: .proxied}'
```

### Check DNS Resolution

```bash
# Wait 5-30 minutes for DNS propagation, then:
dig app.openflow.world +short
dig api.openflow.world +short
```

Both should return the ALB hostname or IP addresses.

## Troubleshooting

### DNS Records Not Created

**Symptoms**: Deployment succeeds but DNS records don't exist

**Solutions**:
1. Check GitHub Secrets are set correctly
2. Verify API token has correct permissions
3. Check workflow logs for DNS update step
4. Verify Zone ID is correct

### API Token Errors

**Error**: `Authentication error` or `Invalid API token`

**Solutions**:
1. Verify token is correct in GitHub Secrets
2. Check token hasn't expired
3. Ensure token has DNS Edit permissions
4. Verify token is scoped to `openflow.world` zone

### ALB Hostname Not Found

**Error**: `ALB hostname not found yet`

**Solutions**:
1. This is normal on first deployment - ALB takes 5-10 minutes
2. DNS will be updated on next deployment
3. Or manually run the script after ALB is created

### Proxy Enabled (Orange Cloud)

**Issue**: Records show orange cloud (proxy enabled)

**Solution**: 
- Script automatically sets `proxied: false`
- If you see orange cloud, manually disable it in Cloudflare Dashboard
- ALB requires direct DNS resolution, not Cloudflare proxy

## Manual DNS Update

If automatic update fails, you can manually run the script:

```bash
export CLOUDFLARE_API_TOKEN="your-token"
export CLOUDFLARE_ZONE_ID="your-zone-id"
cd openflow-deployment
./scripts/update-cloudflare-dns.sh
```

## Security Notes

1. **API Token Security**:
   - Use least privilege (DNS Edit only)
   - Scope to specific zone
   - Rotate tokens regularly
   - Never commit tokens to code

2. **GitHub Secrets**:
   - Secrets are encrypted
   - Only accessible during workflow runs
   - Not visible in logs (masked)

3. **DNS Records**:
   - Records are public (as required for DNS)
   - ALB hostname is public information
   - No sensitive data exposed

## Alternative: Manual DNS Setup

If you prefer manual DNS management:
1. Don't set `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ZONE_ID` secrets
2. Workflow will skip automatic DNS update
3. Manually create DNS records in Cloudflare Dashboard
4. See [DNS Setup Guide](dns-setup.md) for manual instructions

## Next Steps

After DNS is configured:
1. Wait for DNS propagation (5-30 minutes)
2. Test: `https://app.openflow.world` and `https://api.openflow.world`
3. Update Azure AD redirect URI: `https://api.openflow.world/login/oauth2/code/azure`

See [Azure AD Setup Guide](azure-ad-setup.md) for Azure Portal configuration.

