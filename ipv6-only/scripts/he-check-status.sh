#!/usr/bin/env bash
# Hurricane Electric Tunnel Status Check
# Checks the status of your HE tunnel and connectivity

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

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Load configuration
CONFIG_FILE="/etc/ipv6-he-tunnel.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    print_error "Tunnel not configured. Run he-tunnel-setup.sh first"
    exit 1
fi

source "$CONFIG_FILE"

echo "═══════════════════════════════════════════════════════════════"
echo "  Hurricane Electric Tunnel Status"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check if interface exists
print_info "Checking tunnel interface..."
if ip link show "$TUNNEL_IFACE" > /dev/null 2>&1; then
    STATUS=$(ip link show "$TUNNEL_IFACE" | grep -o "state [A-Z]*" | awk '{print $2}')
    if [ "$STATUS" = "UP" ]; then
        print_success "Interface $TUNNEL_IFACE is UP"
    else
        print_error "Interface $TUNNEL_IFACE is $STATUS"
    fi
else
    print_error "Interface $TUNNEL_IFACE does not exist"
    echo "  Run: systemctl start he-ipv6"
    exit 1
fi

# Check IPv6 address
print_info "Checking IPv6 address..."
if ip -6 addr show dev "$TUNNEL_IFACE" | grep -q "$CLIENT_IPV6"; then
    print_success "IPv6 address configured: $CLIENT_IPV6"
else
    print_error "IPv6 address not configured"
fi

# Check routing
print_info "Checking default route..."
if ip -6 route | grep -q "default dev $TUNNEL_IFACE"; then
    print_success "Default IPv6 route configured"
else
    print_warning "Default IPv6 route not found"
fi

# Check tunnel server connectivity
print_info "Testing tunnel server connectivity..."
if ping6 -c 3 -W 2 "$SERVER_IPV6" > /dev/null 2>&1; then
    print_success "Tunnel server reachable: $SERVER_IPV6"
else
    print_error "Cannot reach tunnel server"
fi

# Check external connectivity
print_info "Testing external IPv6 connectivity..."
TEST_HOSTS=(
    "2001:4860:4860::8888|Google DNS"
    "2606:4700:4700::1111|Cloudflare DNS"
    "ipv6.google.com|Google"
)

EXTERNAL_OK=0
for TEST in "${TEST_HOSTS[@]}"; do
    IFS='|' read -r ADDR NAME <<< "$TEST"
    if ping6 -c 2 -W 2 "$ADDR" > /dev/null 2>&1; then
        print_success "Can reach $NAME ($ADDR)"
        EXTERNAL_OK=1
        break
    fi
done

if [ $EXTERNAL_OK -eq 0 ]; then
    print_error "Cannot reach external IPv6 hosts"
fi

# Check public IPv6 address
print_info "Checking public IPv6 address..."
PUBLIC_IPV6=$(curl -6 -s --max-time 5 ifconfig.co 2>/dev/null || echo "Unable to detect")
echo "  Public IPv6: $PUBLIC_IPV6"

# Check DNS resolution
print_info "Testing DNS resolution..."
if host -t AAAA google.com > /dev/null 2>&1; then
    print_success "DNS resolution working"
else
    print_warning "DNS resolution may not be working"
fi

# System information
echo ""
echo "System Information:"
echo "  Hostname: $(hostname)"
echo "  Kernel: $(uname -r)"
echo "  IPv6 forwarding: $(sysctl -n net.ipv6.conf.all.forwarding)"

# Tunnel statistics if available
if [ -f "/sys/class/net/$TUNNEL_IFACE/statistics/rx_packets" ]; then
    echo ""
    echo "Tunnel Statistics:"
    echo "  RX packets: $(cat /sys/class/net/$TUNNEL_IFACE/statistics/rx_packets)"
    echo "  TX packets: $(cat /sys/class/net/$TUNNEL_IFACE/statistics/tx_packets)"
    echo "  RX bytes: $(cat /sys/class/net/$TUNNEL_IFACE/statistics/rx_bytes)"
    echo "  TX bytes: $(cat /sys/class/net/$TUNNEL_IFACE/statistics/tx_bytes)"
fi

# MTU information
MTU=$(ip link show "$TUNNEL_IFACE" | grep -o "mtu [0-9]*" | awk '{print $2}')
echo ""
echo "MTU: $MTU"
if [ "$MTU" -lt 1280 ]; then
    print_warning "MTU is less than IPv6 minimum (1280)"
fi

# Service status
if systemctl is-active --quiet he-ipv6 2>/dev/null; then
    echo ""
    print_success "Systemd service is active"
    echo "  Service: he-ipv6.service"
    echo "  Status: $(systemctl is-active he-ipv6)"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
