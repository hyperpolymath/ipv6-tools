# IPv6 Tools Tutorial

A comprehensive guide to using the IPv6-only toolkit.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Address Basics](#address-basics)
3. [Network Operations](#network-operations)
4. [Subnet Planning](#subnet-planning)
5. [Address Generation](#address-generation)
6. [Command-Line Tools](#command-line-tools)
7. [Advanced Topics](#advanced-topics)

## Getting Started

### Installation

```bash
pip install ipv6-only
```

### First Steps

```python
from ipv6tools import IPv6Address, IPv6Network

# Create an address
addr = IPv6Address("2001:db8::1")
print(addr.compressed)  # 2001:db8::1
```

## Address Basics

### Creating Addresses

```python
from ipv6tools import IPv6Address

# Various formats work
addr1 = IPv6Address("2001:db8::1")
addr2 = IPv6Address("2001:0db8:0000:0000:0000:0000:0000:0001")
addr3 = IPv6Address("fe80::1%eth0")  # With zone ID

print(addr1 == addr2)  # True - same address
```

### Address Properties

```python
addr = IPv6Address("fe80::1")

# Check address type
print(addr.is_link_local)    # True
print(addr.is_global)         # False
print(addr.is_multicast)      # False

# Get readable type
print(addr.get_address_type())  # "Link-Local"
```

### Format Conversion

```python
from ipv6tools.utils import compress_address, expand_address

# Compress
long = "2001:0db8:0000:0000:0000:0000:0000:0001"
short = compress_address(long)  # "2001:db8::1"

# Expand
expanded = expand_address("2001:db8::1")
# "2001:0db8:0000:0000:0000:0000:0000:0001"
```

## Network Operations

### Creating Networks

```python
from ipv6tools import IPv6Network

# Create network
net = IPv6Network("2001:db8::/32")

# Get properties
print(net.network_address)  # 2001:db8::
print(net.prefix_length)    # 32
print(net.num_addresses)    # 2^96
```

### Testing Address Membership

```python
net = IPv6Network("2001:db8::/32")

# Test if address is in network
print(net.contains("2001:db8::1"))        # True
print(net.contains("2001:db8:1234::1"))   # True
print(net.contains("2001:db9::1"))        # False

# Use 'in' operator
from ipv6tools import IPv6Address
addr = IPv6Address("2001:db8::1")
print(addr in net)  # True
```

### Network Division

```python
net = IPv6Network("2001:db8::/32")

# Create 4 subnets
subnets = net.subnets(prefixlen_diff=2)  # /34 subnets
for subnet in subnets:
    print(subnet)
```

## Subnet Planning

### Basic Subnet Calculator

```python
from ipv6tools import IPv6SubnetCalculator

calc = IPv6SubnetCalculator("2001:db8::/32")

# Get network information
info = calc.get_info()
print(f"Network: {info.network}")
print(f"Addresses: {info.num_addresses}")
```

### Dividing Networks

```python
calc = IPv6SubnetCalculator("2001:db8::/32")

# Method 1: Specify number of subnets
subnets = calc.divide_into_subnets(16)
for subnet in subnets:
    print(subnet.network)

# Method 2: Specify new prefix length
subnets = calc.divide_by_prefix(36)  # Create /36 subnets
```

### Supernet Calculation

```python
calc = IPv6SubnetCalculator("2001:db8::/32")

# Get larger network
supernet = calc.get_supernet(24)  # Get /24
print(supernet.network)
```

### Department Allocation

```python
calc = IPv6SubnetCalculator

# Allocate to departments
allocation = calc.recommend_allocation(
    "2001:db8::/32",
    {
        "Engineering": 10,
        "Sales": 5,
        "IT": 3,
    }
)

for dept, subnets in allocation.items():
    print(f"{dept}:")
    for subnet in subnets:
        print(f"  {subnet.network}")
```

## Address Generation

### Link-Local Addresses

```python
from ipv6tools.utils import generate_link_local

# Random link-local
addr = generate_link_local()
print(addr)  # fe80::xxxx:xxxx:xxxx:xxxx

# With specific interface ID
addr = generate_link_local("0000000000000001")
print(addr)  # fe80::1
```

### Unique Local Addresses (ULA)

```python
from ipv6tools.utils import generate_unique_local

# Random ULA
addr = generate_unique_local()
print(addr)  # fd...:...

# With specific parameters
addr = generate_unique_local(
    global_id="0123456789",
    subnet_id="0001",
    interface_id="0000000000000001"
)
```

### Random Addresses

```python
from ipv6tools.utils import generate_random_ipv6

# Generate in default prefix (2001:db8::/64)
addr = generate_random_ipv6()

# Generate in custom prefix
addr = generate_random_ipv6("2001:db8:1234::/48")
```

### MAC to IPv6 (EUI-64)

```python
from ipv6tools.utils import mac_to_ipv6_link_local

# Convert MAC to link-local IPv6
mac = "00:11:22:33:44:55"
addr = mac_to_ipv6_link_local(mac)
print(addr)  # fe80::211:22ff:fe33:4455
```

## Command-Line Tools

### ipv6-calc - Network Calculator

```bash
# Get network info
ipv6-calc 2001:db8::/32 --info

# Divide into subnets
ipv6-calc 2001:db8::/32 --divide 16

# Divide by prefix
ipv6-calc 2001:db8::/32 --prefix 36

# Get supernet
ipv6-calc 2001:db8::/32 --supernet 24

# Check if address is in network
ipv6-calc 2001:db8::/32 --contains 2001:db8::1
```

### ipv6-validate - Validator

```bash
# Validate addresses
ipv6-validate 2001:db8::1 fe80::1%eth0

# Validate networks
ipv6-validate -n 2001:db8::/32 fe80::/10

# Quiet mode (exit code only)
ipv6-validate -q 2001:db8::1 && echo "Valid"
```

### ipv6-gen - Generator

```bash
# Generate link-local
ipv6-gen link-local

# Generate ULA
ipv6-gen ula

# Generate random
ipv6-gen random -p 2001:db8::/64

# From MAC
ipv6-gen from-mac 00:11:22:33:44:55

# Generate multiple
ipv6-gen link-local -n 10
```

### Shell Scripts

```bash
# Run diagnostics
sudo ./src/scripts/ipv6-diag.sh

# Quick connectivity check
./src/scripts/ipv6-diag.sh --quick

# Enable IPv6
sudo ./src/scripts/ipv6-config.sh enable

# Configure static address
sudo ./src/scripts/ipv6-config.sh static eth0 2001:db8::10 64

# Enable privacy extensions
sudo ./src/scripts/ipv6-config.sh enable-privacy
```

## Advanced Topics

### Reverse DNS Pointers

```python
from ipv6tools.utils import reverse_pointer

addr = "2001:db8::1"
ptr = reverse_pointer(addr)
print(ptr)
# 1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa
```

### Binary and Hex Representation

```python
addr = IPv6Address("2001:db8::1")

# Binary (128 bits)
binary = addr.to_binary()
print(binary)

# Hexadecimal (32 hex digits)
hex_str = addr.to_hex()
print(hex_str)
```

### Network Overlap Detection

```python
calc = IPv6SubnetCalculator("2001:db8::/32")

# Check overlap
overlaps = calc.overlaps_with("2001:db8:1::/48")
print(overlaps)  # True - /48 is within /32
```

### Summary Address Calculation

```python
calc = IPv6SubnetCalculator("2001:db8::/48")

# Summarize multiple networks
summary = calc.get_summary_address([
    "2001:db8:1::/48",
    "2001:db8:2::/48",
    "2001:db8:3::/48",
])
print(summary)  # Smallest network containing all
```

## Best Practices

### 1. Always Validate Input

```python
from ipv6tools.validator import validate_ipv6

addr_input = input("Enter IPv6 address: ")
valid, error = validate_ipv6(addr_input)

if valid:
    addr = IPv6Address(addr_input)
    # Process address
else:
    print(f"Invalid: {error}")
```

### 2. Use Appropriate Prefixes

- `/64` - Standard subnet (SLAAC)
- `/48` - Typical site allocation
- `/32` - ISP allocation
- `/128` - Single host

### 3. Handle Zone IDs

```python
# Zone IDs are important for link-local
addr = IPv6Address("fe80::1%eth0")
print(addr.zone_id)  # "eth0"
```

### 4. Consider Address Types

```python
def is_usable_for_public(addr_str):
    """Check if address is suitable for public use."""
    addr = IPv6Address(addr_str)

    if addr.is_link_local:
        return False  # Only local
    if addr.is_loopback:
        return False  # Only localhost
    if addr.is_private:
        return False  # ULA - not globally routable

    return addr.is_global
```

## Common Patterns

### Network Inventory

```python
networks = [
    "2001:db8::/32",
    "2001:db8:1000::/36",
    "2001:db8:2000::/36",
]

for net_str in networks:
    net = IPv6Network(net_str)
    calc = IPv6SubnetCalculator(net_str)
    info = calc.get_info()

    print(f"{info.network}")
    print(f"  Addresses: {info.num_addresses}")
    print(f"  Type: {info.addressType}")
```

### Batch Validation

```python
from ipv6tools.validator import is_valid_ipv6

addresses = [
    "2001:db8::1",
    "invalid",
    "fe80::1",
    "::1",
]

valid_addresses = [addr for addr in addresses if is_valid_ipv6(addr)]
print(f"Valid: {len(valid_addresses)}/{len(addresses)}")
```

## Next Steps

- Explore the [API Documentation](API.md)
- Check out [Examples](../examples/)
- Read about [IPv6 Best Practices](BEST_PRACTICES.md)
- Try the [Web Interface](../src/web/index.html)

## Troubleshooting

### Common Issues

**Import Error**
```python
# Make sure package is installed
pip install -e .
```

**Invalid Address**
```python
# Check address format
from ipv6tools.validator import validate_ipv6
valid, error = validate_ipv6("your-address")
print(error)  # See specific error
```

**Network Too Large**
```python
# Don't try to enumerate hosts in large networks
net = IPv6Network("2001:db8::/32")
# net.hosts()  # Don't do this! Too many addresses

# Instead, calculate specific addresses or use smaller subnets
```

## Resources

- [IPv6 Addressing Architecture (RFC 4291)](https://tools.ietf.org/html/rfc4291)
- [IPv6 Address Planning](https://www.ripe.net/publications/docs/ipv6-address-planning)
- [IANA IPv6 Allocations](https://www.iana.org/assignments/ipv6-address-space/)
