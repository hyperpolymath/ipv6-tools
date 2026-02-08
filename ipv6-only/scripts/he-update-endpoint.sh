#!/usr/bin/env bash
# Hurricane Electric Tunnel Endpoint Update Script
# Updates your IPv4 endpoint with Hurricane Electric for dynamic IPs

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Load configuration
CONFIG_FILE="/etc/ipv6-he-tunnel.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    print_error "Configuration file not found: $CONFIG_FILE"
    echo "Run he-tunnel-setup.sh first"
    exit 1
fi

source "$CONFIG_FILE"

# Get tunnel ID from argument or config
TUNNEL_ID="${1:-${TUNNEL_ID}}"

if [ -z "$TUNNEL_ID" ]; then
    print_error "Tunnel ID not specified"
    echo "Usage: $0 <tunnel-id>"
    exit 1
fi

print_info "Updating endpoint for tunnel $TUNNEL_ID..."

# Get current public IPv4 address
print_info "Detecting public IPv4 address..."

# Try multiple services
PUBLIC_IP=""
for service in "ifconfig.co" "icanhazip.com" "ipinfo.io/ip" "api.ipify.org"; do
    IP=$(curl -4 -s --max-time 5 "$service" 2>/dev/null || true)
    if [ -n "$IP" ] && [[ "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        PUBLIC_IP="$IP"
        break
    fi
done

if [ -z "$PUBLIC_IP" ]; then
    print_error "Could not detect public IPv4 address"
    exit 1
fi

print_info "Public IPv4: $PUBLIC_IP"

# Check if IP has changed
LAST_IP_FILE="/var/run/he-tunnel-last-ip"
if [ -f "$LAST_IP_FILE" ]; then
    LAST_IP=$(cat "$LAST_IP_FILE")
    if [ "$LAST_IP" = "$PUBLIC_IP" ]; then
        print_info "IP address unchanged, no update needed"
        exit 0
    fi
fi

# Update endpoint via API
print_info "Updating tunnel endpoint via API..."

# HE API endpoint
API_URL="https://ipv4.tunnelbroker.net/nic/update"

# Make request
RESPONSE=$(curl -s -u "$HE_USER:$HE_PASSWORD" \
    "${API_URL}?hostname=${TUNNEL_ID}&myip=${PUBLIC_IP}" || true)

# Check response
if [[ "$RESPONSE" =~ ^(good|nochg) ]]; then
    print_success "Endpoint updated successfully!"
    echo "$PUBLIC_IP" > "$LAST_IP_FILE"

    # Restart tunnel if running as root
    if [ "$EUID" -eq 0 ] && systemctl is-active --quiet he-ipv6; then
        print_info "Restarting tunnel..."
        systemctl restart he-ipv6
        print_success "Tunnel restarted"
    fi
elif [[ "$RESPONSE" =~ ^abuse ]]; then
    print_error "Update blocked - abuse detected"
    print_error "Wait before trying again"
    exit 1
elif [[ "$RESPONSE" =~ ^badauth ]]; then
    print_error "Authentication failed - check credentials"
    exit 1
else
    print_error "Update failed: $RESPONSE"
    exit 1
fi

# Verify connectivity
print_info "Verifying tunnel connectivity..."

if ping6 -c 2 -W 2 "$SERVER_IPV6" > /dev/null 2>&1; then
    print_success "Tunnel is working!"
else
    print_error "Cannot ping tunnel server"
    print_error "Tunnel may need time to update or configuration may be incorrect"
fi

# Log update
if [ "$EUID" -eq 0 ]; then
    logger -t he-tunnel "Endpoint updated to $PUBLIC_IP"
fi

echo ""
echo "Update complete!"
echo "  Old IP: ${LAST_IP:-unknown}"
echo "  New IP: $PUBLIC_IP"
echo "  Time: $(date)"
