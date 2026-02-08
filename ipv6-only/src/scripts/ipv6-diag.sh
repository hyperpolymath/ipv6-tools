#!/bin/bash
# IPv6 Diagnostics Script
# Comprehensive IPv6 network diagnostics and troubleshooting

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
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

# Check if running as root for some operations
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_warning "Some checks require root privileges"
        return 1
    fi
    return 0
}

# Check IPv6 support in kernel
check_ipv6_support() {
    print_header "IPv6 Kernel Support"

    if [ -f /proc/net/if_inet6 ]; then
        print_success "IPv6 is supported and enabled in kernel"
    else
        print_error "IPv6 is not enabled in kernel"
        echo "To enable: modprobe ipv6 or sysctl net.ipv6.conf.all.disable_ipv6=0"
        return 1
    fi
}

# List IPv6 addresses
list_ipv6_addresses() {
    print_header "IPv6 Addresses"

    if command -v ip &> /dev/null; then
        ip -6 addr show | grep -v "valid_lft"
    elif command -v ifconfig &> /dev/null; then
        ifconfig | grep -i "inet6"
    else
        print_error "Neither 'ip' nor 'ifconfig' command found"
    fi
}

# Show IPv6 routing table
show_routing_table() {
    print_header "IPv6 Routing Table"

    if command -v ip &> /dev/null; then
        ip -6 route show
    elif command -v netstat &> /dev/null; then
        netstat -rn -A inet6
    else
        print_error "Cannot display routing table"
    fi
}

# Show IPv6 neighbors (NDP cache)
show_neighbors() {
    print_header "IPv6 Neighbor Discovery Cache"

    if command -v ip &> /dev/null; then
        ip -6 neigh show
    else
        print_error "Cannot display neighbor cache"
    fi
}

# Test IPv6 connectivity
test_connectivity() {
    print_header "IPv6 Connectivity Tests"

    local test_hosts=(
        "2001:4860:4860::8888"  # Google DNS
        "2606:4700:4700::1111"  # Cloudflare DNS
        "2620:fe::fe"            # Quad9 DNS
    )

    for host in "${test_hosts[@]}"; do
        echo -n "Testing $host... "
        if ping6 -c 1 -W 2 "$host" &> /dev/null; then
            print_success "Reachable"
        else
            print_error "Unreachable"
        fi
    done

    # Test with hostname
    echo -n "Testing ipv6.google.com... "
    if ping6 -c 1 -W 2 ipv6.google.com &> /dev/null; then
        print_success "Reachable"
    else
        print_error "Unreachable"
    fi
}

# Check DNS resolution
test_dns() {
    print_header "DNS (AAAA) Resolution Test"

    local test_domains=(
        "google.com"
        "cloudflare.com"
        "facebook.com"
    )

    for domain in "${test_domains[@]}"; do
        echo "Resolving $domain:"
        if command -v dig &> /dev/null; then
            dig +short AAAA "$domain" | head -n 3
        elif command -v host &> /dev/null; then
            host -t AAAA "$domain" | grep "has IPv6 address"
        elif command -v nslookup &> /dev/null; then
            nslookup -type=AAAA "$domain" | grep "AAAA"
        else
            print_error "No DNS query tool found"
        fi
    done
}

# Check firewall rules
check_firewall() {
    print_header "IPv6 Firewall Rules"

    if ! check_root; then
        return
    fi

    if command -v ip6tables &> /dev/null; then
        echo "ip6tables rules:"
        ip6tables -L -n -v 2>/dev/null || print_error "Cannot read ip6tables rules"
    else
        print_warning "ip6tables not found"
    fi

    if command -v nft &> /dev/null; then
        echo -e "\nnftables rules (IPv6):"
        nft list tables ip6 2>/dev/null || true
    fi
}

# Check sysctl IPv6 settings
check_sysctl() {
    print_header "IPv6 Sysctl Settings"

    local important_settings=(
        "net.ipv6.conf.all.disable_ipv6"
        "net.ipv6.conf.default.disable_ipv6"
        "net.ipv6.conf.all.forwarding"
        "net.ipv6.conf.all.accept_ra"
        "net.ipv6.conf.all.accept_redirects"
        "net.ipv6.conf.all.autoconf"
    )

    for setting in "${important_settings[@]}"; do
        if [ -f "/proc/sys/${setting//./\/}" ]; then
            value=$(sysctl -n "$setting" 2>/dev/null || echo "N/A")
            echo "$setting = $value"
        fi
    done
}

# Check for privacy extensions
check_privacy_extensions() {
    print_header "Privacy Extensions Status"

    local use_tempaddr=$(sysctl -n net.ipv6.conf.all.use_tempaddr 2>/dev/null || echo "N/A")

    case $use_tempaddr in
        0)
            echo "Privacy extensions: Disabled"
            ;;
        1)
            echo "Privacy extensions: Enabled (prefer public addresses)"
            ;;
        2)
            echo "Privacy extensions: Enabled (prefer temporary addresses)"
            ;;
        *)
            echo "Privacy extensions: Unknown status"
            ;;
    esac
}

# Main execution
main() {
    echo -e "${GREEN}IPv6 Diagnostics Tool${NC}"
    echo "===================="

    check_ipv6_support
    list_ipv6_addresses
    show_routing_table
    show_neighbors
    check_sysctl
    check_privacy_extensions
    test_connectivity
    test_dns
    check_firewall

    print_header "Diagnostics Complete"
}

# Parse arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --quick, -q    Quick check (connectivity only)"
        echo ""
        echo "Run without arguments for full diagnostics"
        exit 0
        ;;
    --quick|-q)
        check_ipv6_support
        test_connectivity
        ;;
    *)
        main
        ;;
esac
