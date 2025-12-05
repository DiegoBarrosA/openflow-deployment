# Simple HTTPS Setup Without Personal Domain

If you don't want to use your personal domain, here are the simplest options:

## Option 1: Use a Cheap Domain ($1-2/year)

This is the **recommended approach** - it's the simplest and most reliable.

### Step 1: Buy a Cheap Domain

1. Go to **Namecheap** or **Google Domains**
2. Search for available domains
3. Look for deals (often `.xyz`, `.online`, `.site` domains are $1-2/year)
4. Purchase the domain

**Example**: `openflow-xyz.xyz` for $1/year

### Step 2: Follow Main HTTPS Setup Guide

Follow the [HTTPS Setup Guide](https-setup.md) using your new domain.

**Total Cost**: ~$1-2/year for domain + AWS ALB costs (~$16/month)

## Option 2: Use AWS Route 53 Hosted Zone (If You Have AWS Credits)

If you have AWS student credits or want to use Route 53:

1. Buy domain through Route 53 (or transfer existing)
2. Route 53 automatically creates hosted zone
3. Follow HTTPS setup guide
4. DNS management is easier

**Cost**: Domain price + $0.50/month for hosted zone

## Option 3: Use Free Subdomain Service (Not Recommended)

**Warning**: These may not work reliably with Azure AD due to certificate validation.

### Freenom (Free Domains)

1. Go to [Freenom](https://www.freenom.com)
2. Register for free `.tk`, `.ml`, `.ga`, `.cf` domain
3. Follow HTTPS setup guide
4. **Note**: These domains are less reliable and may be blocked by some services

### DuckDNS (Free Subdomain)

1. Go to [DuckDNS](https://www.duckdns.org)
2. Create free subdomain (e.g., `openflow.duckdns.org`)
3. **Note**: You'll need to use Let's Encrypt instead of ACM (more complex setup)

## Option 4: Development - Use ngrok (Temporary)

For **development/testing only**:

```bash
# Install ngrok
# Then create HTTPS tunnel
ngrok http 8080

# Use the ngrok HTTPS URL in Azure AD redirect URI
# Example: https://abc123.ngrok.io/login/oauth2/code/azure
```

**Limitations**:
- URL changes each time (unless paid plan)
- Not suitable for production
- May violate Azure AD terms

## Recommendation

**Use Option 1** (cheap domain) - it's:
- ✅ Most reliable
- ✅ Works with Azure AD
- ✅ Very cheap ($1-2/year)
- ✅ Professional
- ✅ Easy to set up

The domain cost is minimal compared to the ALB cost (~$16/month), and you get a professional setup.

## Quick Start: Namecheap + ACM

1. **Buy domain** at Namecheap ($1-2/year)
2. **Request certificate** in ACM (free)
3. **Validate via DNS** (add CNAME records in Namecheap)
4. **Follow HTTPS setup guide** with your new domain
5. **Total time**: ~30 minutes
6. **Total cost**: $1-2/year

## Alternative: Use Existing Subdomain

If you have any existing domain (even a free one from a service), you can use a subdomain:

- `openflow.your-existing-domain.com`
- `api-openflow.your-existing-domain.com`

This works the same way and doesn't require buying a new domain.

