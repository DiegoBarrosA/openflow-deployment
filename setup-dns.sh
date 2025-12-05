#!/bin/bash
# Script to set up DNS records for OpenFlow ALB
# This script helps configure DNS to point to the ALB

set -e

echo "🔧 OpenFlow DNS Setup Script"
echo "============================"
echo ""

# Get ALB hostname from Ingress
echo "📡 Getting ALB hostname from Kubernetes..."
ALB_HOSTNAME=$(kubectl get ingress openflow-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [ -z "$ALB_HOSTNAME" ]; then
    echo "❌ Error: Could not get ALB hostname from Ingress"
    echo "Make sure the Ingress is deployed and ALB is created"
    echo "Run: kubectl get ingress openflow-ingress"
    exit 1
fi

echo "✅ ALB Hostname: $ALB_HOSTNAME"
echo ""

# Check if using Route 53
echo "🔍 Checking DNS provider..."
read -p "Are you using AWS Route 53 for DNS? (y/n): " use_route53

if [ "$use_route53" = "y" ] || [ "$use_route53" = "Y" ]; then
    echo ""
    echo "📝 Setting up Route 53 DNS records..."
    
    # Get hosted zone
    read -p "Enter your domain (e.g., openflow.world): " domain
    HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name "$domain" --query 'HostedZones[0].Id' --output text 2>/dev/null | cut -d'/' -f3)
    
    if [ -z "$HOSTED_ZONE_ID" ] || [ "$HOSTED_ZONE_ID" = "None" ]; then
        echo "❌ Error: Could not find hosted zone for $domain"
        echo "Make sure the hosted zone exists in Route 53"
        exit 1
    fi
    
    echo "✅ Found hosted zone: $HOSTED_ZONE_ID"
    echo ""
    
    # ALB hosted zone ID for us-east-1 (change if using different region)
    ALB_HOSTED_ZONE_ID="Z35SXDOTRQ7X7K"
    read -p "Enter AWS region (default: us-east-1): " region
    region=${region:-us-east-1}
    
    # Get ALB hosted zone ID based on region
    case $region in
        us-east-1) ALB_HOSTED_ZONE_ID="Z35SXDOTRQ7X7K" ;;
        us-east-2) ALB_HOSTED_ZONE_ID="Z3AADJGX6KTTL2" ;;
        us-west-1) ALB_HOSTED_ZONE_ID="Z368ELLRRE2KJ0" ;;
        us-west-2) ALB_HOSTED_ZONE_ID="Z1H1FL5HABSF5" ;;
        *) echo "⚠️  Using default ALB hosted zone ID. If records fail, check AWS docs for your region." ;;
    esac
    
    # Create records
    echo "Creating DNS records..."
    
    # Frontend record
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch "{
            \"Changes\": [{
                \"Action\": \"UPSERT\",
                \"ResourceRecordSet\": {
                    \"Name\": \"app.$domain\",
                    \"Type\": \"A\",
                    \"AliasTarget\": {
                        \"HostedZoneId\": \"$ALB_HOSTED_ZONE_ID\",
                        \"DNSName\": \"$ALB_HOSTNAME\",
                        \"EvaluateTargetHealth\": false
                    }
                }
            }]
        }" > /dev/null
    
    echo "✅ Created A record: app.$domain -> $ALB_HOSTNAME"
    
    # Backend record
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch "{
            \"Changes\": [{
                \"Action\": \"UPSERT\",
                \"ResourceRecordSet\": {
                    \"Name\": \"api.$domain\",
                    \"Type\": \"A\",
                    \"AliasTarget\": {
                        \"HostedZoneId\": \"$ALB_HOSTED_ZONE_ID\",
                        \"DNSName\": \"$ALB_HOSTNAME\",
                        \"EvaluateTargetHealth\": false
                    }
                }
            }]
        }" > /dev/null
    
    echo "✅ Created A record: api.$domain -> $ALB_HOSTNAME"
    echo ""
    echo "🎉 DNS records created successfully!"
    echo ""
    echo "⏳ Wait 5-30 minutes for DNS propagation"
    echo "Then test:"
    echo "  - https://app.$domain"
    echo "  - https://api.$domain"
    
else
    echo ""
    echo "📝 Manual DNS Configuration Required"
    echo "===================================="
    echo ""
    echo "Create the following DNS records in your DNS provider:"
    echo ""
    echo "Record 1:"
    echo "  Type: A (Alias) or CNAME"
    echo "  Name: app.openflow.world"
    echo "  Value: $ALB_HOSTNAME"
    echo ""
    echo "Record 2:"
    echo "  Type: A (Alias) or CNAME"
    echo "  Name: api.openflow.world"
    echo "  Value: $ALB_HOSTNAME"
    echo ""
    echo "Note: If using CNAME, use the full ALB hostname"
    echo "      If using A record alias, use the ALB hostname as alias target"
    echo ""
    echo "⏳ After creating records, wait 5-30 minutes for DNS propagation"
fi

echo ""
echo "✅ Setup complete!"

