#!/usr/bin/env bash
# Hurricane Electric Tunnel Setup Script
# Sets up IPv6 tunnel with Hurricane Electric TunnelBroker

set -euo pipefail

# Colors for output
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

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root"
    exit 1
fi

# Parse arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <tunnel-id> <username> <password>"
    echo ""
    echo "Arguments:"
    echo "  tunnel-id  - Your Hurricane Electric tunnel ID"
    echo "  username   - Your HE.net username"
    echo "  password   - Your HE.net update key (not account password)"
    echo ""
    echo "Example:"
    echo "  $0 123456 user@example.com updatekey123"
    exit 1
fi

TUNNEL_ID="$1"
HE_USER="$2"
HE_PASSWORD="$3"

print_info "Setting up Hurricane Electric tunnel $TUNNEL_ID..."

# Get tunnel information from config
CONFIG_FILE="/etc/ipv6-he-tunnel.conf"

if [ -f "$CONFIG_FILE" ]; then
    print_warning "Configuration file exists. Reading existing config..."
    source "$CONFIG_FILE"
else
    print_info "Creating new configuration..."
fi

# Prompt for tunnel details if not in config
if [ -z "${CLIENT_IPV6:-}" ]; then
    read -p "Client IPv6 address (e.g., 2001:470:1234:5678::2): " CLIENT_IPV6
fi

if [ -z "${SERVER_IPV6:-}" ]; then
    read -p "Server IPv6 address (e.g., 2001:470:1234:5678::1): " SERVER_IPV6
fi

if [ -z "${SERVER_IPV4:-}" ]; then
    read -p "Server IPv4 address: " SERVER_IPV4
fi

if [ -z "${ROUTED_PREFIX:-}" ]; then
    read -p "Routed /64 or /48 prefix (e.g., 2001:470:abcd::/48): " ROUTED_PREFIX
fi

# Save configuration
cat > "$CONFIG_FILE" << EOF
# Hurricane Electric Tunnel Configuration
# Generated: $(date)

TUNNEL_ID="$TUNNEL_ID"
HE_USER="$HE_USER"
HE_PASSWORD="$HE_PASSWORD"

# Tunnel endpoints
CLIENT_IPV6="$CLIENT_IPV6"
SERVER_IPV6="$SERVER_IPV6"
SERVER_IPV4="$SERVER_IPV4"

# Routed prefix
ROUTED_PREFIX="$ROUTED_PREFIX"

# Interface name
TUNNEL_IFACE="he-ipv6"
EOF

chmod 600 "$CONFIG_FILE"
print_success "Configuration saved to $CONFIG_FILE"

# Create tunnel interface
print_info "Creating tunnel interface..."

# Remove existing tunnel if present
ip tunnel del "$TUNNEL_IFACE" 2>/dev/null || true

# Create new tunnel
ip tunnel add "$TUNNEL_IFACE" mode sit remote "$SERVER_IPV4" local "$(hostname -I | awk '{print $1}')" ttl 255

# Bring up interface
ip link set "$TUNNEL_IFACE" up

# Assign IPv6 address
ip addr add "$CLIENT_IPV6/64" dev "$TUNNEL_IFACE"

# Add default route
ip route add ::/0 dev "$TUNNEL_IFACE"

print_success "Tunnel interface created and configured"

# Configure routed prefix
if [ -n "$ROUTED_PREFIX" ]; then
    print_info "Configuring routed prefix $ROUTED_PREFIX..."

    # Add route for routed prefix
    ip -6 route add "$ROUTED_PREFIX" dev "$TUNNEL_IFACE"

    # Enable IPv6 forwarding
    sysctl -w net.ipv6.conf.all.forwarding=1

    print_success "Routed prefix configured"
fi

# Test connectivity
print_info "Testing tunnel connectivity..."

if ping6 -c 3 -W 2 "$SERVER_IPV6" > /dev/null 2>&1; then
    print_success "Tunnel is up and working!"
else
    print_error "Cannot ping tunnel server. Check configuration."
    exit 1
fi

# Test external connectivity
print_info "Testing external IPv6 connectivity..."

if ping6 -c 3 -W 2 2001:4860:4860::8888 > /dev/null 2>&1; then
    print_success "External IPv6 connectivity working!"
else
    print_warning "Cannot reach external IPv6. Check routing."
fi

# Create systemd service
print_info "Creating systemd service..."

cat > /etc/systemd/system/he-ipv6.service << EOF
[Unit]
Description=Hurricane Electric IPv6 Tunnel
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/he-tunnel-up.sh
ExecStop=/usr/local/bin/he-tunnel-down.sh
ExecReload=/usr/local/bin/he-update-endpoint.sh $TUNNEL_ID

[Install]
WantedBy=multi-user.target
EOF

# Create start script
cat > /usr/local/bin/he-tunnel-up.sh << 'EOF'
#!/bin/bash
source /etc/ipv6-he-tunnel.conf
ip tunnel add "$TUNNEL_IFACE" mode sit remote "$SERVER_IPV4" local "$(hostname -I | awk '{print $1}')" ttl 255
ip link set "$TUNNEL_IFACE" up
ip addr add "$CLIENT_IPV6/64" dev "$TUNNEL_IFACE"
ip route add ::/0 dev "$TUNNEL_IFACE"
[ -n "$ROUTED_PREFIX" ] && ip -6 route add "$ROUTED_PREFIX" dev "$TUNNEL_IFACE"
sysctl -w net.ipv6.conf.all.forwarding=1
EOF

# Create stop script
cat > /usr/local/bin/he-tunnel-down.sh << 'EOF'
#!/bin/bash
source /etc/ipv6-he-tunnel.conf
ip tunnel del "$TUNNEL_IFACE" 2>/dev/null || true
EOF

chmod +x /usr/local/bin/he-tunnel-up.sh
chmod +x /usr/local/bin/he-tunnel-down.sh

# Enable service
systemctl daemon-reload
systemctl enable he-ipv6.service

print_success "Systemd service created and enabled"

# Display summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Hurricane Electric Tunnel Setup Complete"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Tunnel Information:"
echo "  Tunnel ID:        $TUNNEL_ID"
echo "  Interface:        $TUNNEL_IFACE"
echo "  Client IPv6:      $CLIENT_IPV6"
echo "  Server IPv6:      $SERVER_IPV6"
echo "  Server IPv4:      $SERVER_IPV4"
echo "  Routed Prefix:    $ROUTED_PREFIX"
echo ""
echo "Configuration file: $CONFIG_FILE"
echo ""
echo "Management commands:"
echo "  Start tunnel:     systemctl start he-ipv6"
echo "  Stop tunnel:      systemctl stop he-ipv6"
echo "  Restart tunnel:   systemctl restart he-ipv6"
echo "  Check status:     systemctl status he-ipv6"
echo "  Update endpoint:  systemctl reload he-ipv6"
echo ""
echo "Next steps:"
echo "  1. Test IPv6 connectivity: ping6 ipv6.google.com"
echo "  2. Check your IPv6 address: curl -6 ifconfig.co"
echo "  3. Update endpoint if needed: systemctl reload he-ipv6"
echo "  4. Configure firewall for IPv6"
echo ""
echo "═══════════════════════════════════════════════════════════════"
