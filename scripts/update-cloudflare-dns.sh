#!/bin/bash
# Script to update Cloudflare DNS records with NLB hostnames
# This is called automatically during deployment
# Uses Cloudflare proxy for SSL termination (Flexible mode)

set -e

# Configuration
DOMAIN="openflow.world"
FRONTEND_SUBDOMAIN="app"
BACKEND_SUBDOMAIN="api"

echo "📡 Getting NLB hostnames from Kubernetes Services..."

# Get Frontend NLB hostname
FRONTEND_HOSTNAME=$(kubectl get svc openflow-frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
# Get Backend NLB hostname
BACKEND_HOSTNAME=$(kubectl get svc openflow-backend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [ -z "$FRONTEND_HOSTNAME" ] || [ -z "$BACKEND_HOSTNAME" ]; then
    echo "⚠️  Warning: NLB hostname(s) not found yet"
    echo "Frontend NLB: ${FRONTEND_HOSTNAME:-NOT FOUND}"
    echo "Backend NLB: ${BACKEND_HOSTNAME:-NOT FOUND}"
    echo "This is normal on first deployment - NLB creation can take a few minutes"
    echo "DNS records will be updated on next deployment or manually"
    exit 0  # Don't fail the deployment
fi

echo "✅ Frontend NLB: $FRONTEND_HOSTNAME"
echo "✅ Backend NLB: $BACKEND_HOSTNAME"
echo ""

# Check if Cloudflare credentials are set
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "❌ Error: CLOUDFLARE_API_TOKEN is not set"
    echo "Please set it as a GitHub Secret"
    exit 1
fi

if [ -z "$CLOUDFLARE_ZONE_ID" ]; then
    echo "❌ Error: CLOUDFLARE_ZONE_ID is not set"
    echo "Please set it as a GitHub Secret"
    exit 1
fi

echo "🔧 Updating Cloudflare DNS records..."
echo ""

# Function to get DNS record ID
get_record_id() {
    local subdomain=$1
    local name="${subdomain}.${DOMAIN}"
    
    curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/dns_records?type=CNAME&name=${name}" \
        -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
        -H "Content-Type: application/json" | \
        jq -r '.result[0].id // empty'
}

# Function to create or update DNS record
# Parameters: subdomain, target_hostname
update_dns_record() {
    local subdomain=$1
    local target_hostname=$2
    local name="${subdomain}.${DOMAIN}"
    local record_id=$(get_record_id "$subdomain")
    
    # Use proxied: true for Cloudflare SSL termination (Flexible mode)
    if [ -n "$record_id" ]; then
        echo "📝 Updating existing record: $name -> $target_hostname"
        response=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/dns_records/${record_id}" \
            -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
            -H "Content-Type: application/json" \
            --data "{
                \"type\": \"CNAME\",
                \"name\": \"${subdomain}\",
                \"content\": \"${target_hostname}\",
                \"ttl\": 1,
                \"proxied\": true
            }")
    else
        echo "➕ Creating new record: $name -> $target_hostname"
        response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/dns_records" \
            -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
            -H "Content-Type: application/json" \
            --data "{
                \"type\": \"CNAME\",
                \"name\": \"${subdomain}\",
                \"content\": \"${target_hostname}\",
                \"ttl\": 1,
                \"proxied\": true
            }")
    fi
    
    # Check if request was successful
    success=$(echo "$response" | jq -r '.success // false')
    if [ "$success" = "true" ]; then
        echo "✅ Successfully updated: $name -> $target_hostname (proxied)"
    else
        errors=$(echo "$response" | jq -r '.errors[]?.message // "Unknown error"' | head -1)
        echo "❌ Failed to update $name: $errors"
        echo "Response: $response"
        return 1
    fi
}

# Update frontend DNS record (points to frontend NLB)
echo "🌐 Updating frontend DNS record..."
update_dns_record "$FRONTEND_SUBDOMAIN" "$FRONTEND_HOSTNAME" || echo "⚠️  Frontend DNS update failed, but continuing..."

echo ""

# Update backend DNS record (points to backend NLB)
echo "🌐 Updating backend DNS record..."
update_dns_record "$BACKEND_SUBDOMAIN" "$BACKEND_HOSTNAME" || echo "⚠️  Backend DNS update failed, but continuing..."

echo ""
echo "✅ DNS update complete!"
echo ""
echo "📋 Updated records (with Cloudflare proxy enabled for HTTPS):"
echo "  - ${FRONTEND_SUBDOMAIN}.${DOMAIN} -> $FRONTEND_HOSTNAME"
echo "  - ${BACKEND_SUBDOMAIN}.${DOMAIN} -> $BACKEND_HOSTNAME"
echo ""
echo "🔒 SSL Mode: Cloudflare Flexible (Cloudflare handles HTTPS, connects to NLB via HTTP)"
echo ""
echo "⏳ DNS changes should propagate within a few minutes"
echo "Test after propagation:"
echo "  - https://${FRONTEND_SUBDOMAIN}.${DOMAIN}"
echo "  - https://${BACKEND_SUBDOMAIN}.${DOMAIN}"
