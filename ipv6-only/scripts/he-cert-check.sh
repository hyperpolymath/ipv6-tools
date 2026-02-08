#!/usr/bin/env bash
# Hurricane Electric IPv6 Certification Status Checker
# Checks your progress on the HE IPv6 Sage certification

set -euo pipefail

# Colors
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

if [ $# -lt 1 ]; then
    echo "Usage: $0 <he-username>"
    echo ""
    echo "Check your IPv6 certification progress"
    echo "Visit https://ipv6.he.net/certification/ for details"
    exit 1
fi

USERNAME="$1"

echo "═══════════════════════════════════════════════════════════════"
echo "  Hurricane Electric IPv6 Certification Status"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Username: $USERNAME"
echo "URL: https://ipv6.he.net/certification/scoresheet.php?name=$USERNAME"
echo ""

print_info "IPv6 Certification Levels:"
echo ""
echo "  🥉 Newbie       - Basic IPv6 understanding"
echo "  🥈 Explorer     - IPv6 connectivity tests"
echo "  🥇 Enthusiast   - Web services over IPv6"
echo "  ⭐ Administrator - Email over IPv6"
echo "  ⭐⭐ Professional  - DNS and advanced tests"
echo "  ⭐⭐⭐ Guru         - Comprehensive IPv6 knowledge"
echo "  👑 Sage         - Maximum certification level"
echo ""

print_info "Test categories include:"
echo "  • Basic connectivity (ping, traceroute)"
echo "  • Web browsing (HTTP, HTTPS)"
echo "  • Email (SMTP, POP3, IMAP)"
echo "  • DNS (name servers, AAAA records)"
echo "  • Advanced services (IRC, XMPP, etc.)"
echo ""

print_info "Useful commands for certification tests:"
echo ""
echo "  # Test basic connectivity"
echo "  ping6 -c 4 ipv6.google.com"
echo ""
echo "  # Test web access"
echo "  curl -6 http://ipv6.google.com"
echo "  curl -6 https://ipv6.google.com"
echo ""
echo "  # Test DNS"
echo "  dig @2001:4860:4860::8888 AAAA google.com"
echo "  dig -6 google.com"
echo ""
echo "  # Check your IPv6 address"
echo "  curl -6 ifconfig.co"
echo ""

# Check if we can reach IPv6 sites
print_info "Quick IPv6 connectivity check..."

SITES=(
    "ipv6.google.com"
    "ipv6.he.net"
    "test-ipv6.com"
)

for SITE in "${SITES[@]}"; do
    if ping6 -c 1 -W 2 "$SITE" > /dev/null 2>&1; then
        print_success "Can reach $SITE"
    else
        echo "  ✗ Cannot reach $SITE"
    fi
done

echo ""
echo "Visit https://ipv6.he.net/certification/ to:"
echo "  • Check your current level"
echo "  • Take tests"
echo "  • View detailed scorecard"
echo "  • Get certification badge"
echo ""
echo "═══════════════════════════════════════════════════════════════"
