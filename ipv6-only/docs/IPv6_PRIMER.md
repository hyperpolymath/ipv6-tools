# IPv6 Primer

A practical introduction to IPv6 for developers and network administrators.

## What is IPv6?

IPv6 (Internet Protocol version 6) is the latest version of the Internet Protocol, designed to replace IPv4. It provides:

- **Vastly larger address space**: 128-bit addresses vs 32-bit in IPv4
- **No NAT required**: Every device can have a globally routable address
- **Built-in security**: IPSec is mandatory (optional in IPv4)
- **Simpler routing**: More hierarchical addressing
- **Auto-configuration**: SLAAC (Stateless Address Autoconfiguration)

## IPv6 Address Format

### Structure

IPv6 addresses are 128 bits written as 8 groups of 4 hexadecimal digits:

```
2001:0db8:85a3:0000:0000:8a2e:0370:7334
```

### Compression Rules

1. **Leading zeros** can be omitted:
   ```
   2001:0db8:85a3:0000 → 2001:db8:85a3:0
   ```

2. **Consecutive zeros** can be replaced with `::` (only once):
   ```
   2001:0db8:0000:0000:0000:0000:0000:0001 → 2001:db8::1
   ```

### Examples

| Uncompressed | Compressed |
|-------------|-----------|
| `0000:0000:0000:0000:0000:0000:0000:0001` | `::1` |
| `fe80:0000:0000:0000:0000:0000:0000:0001` | `fe80::1` |
| `2001:0db8:0000:0042:0000:8a2e:0370:7334` | `2001:db8:0:42:0:8a2e:370:7334` |

## Address Types

### Unicast Addresses

#### Global Unicast (`2000::/3`)
- Globally routable addresses
- Similar to public IPv4 addresses
- Example: `2001:db8:1234::1`

#### Link-Local (`fe80::/10`)
- Only valid on local network segment
- Auto-configured on every IPv6 interface
- Not routable beyond local link
- Example: `fe80::1` (often with zone: `fe80::1%eth0`)

#### Unique Local (`fc00::/7`)
- Private addresses (like IPv4 RFC1918)
- Prefix: `fd00::/8` for locally assigned
- Not globally routable
- Example: `fd12:3456:789a::1`

#### Loopback (`::1/128`)
- Localhost address
- Equivalent to `127.0.0.1` in IPv4

#### Unspecified (`::/128`)
- All zeros
- Used to indicate absence of address
- Never assigned to interface

### Multicast (`ff00::/8`)
- One-to-many communication
- No broadcast in IPv6 (multicast instead)
- Examples:
  - `ff02::1` - All nodes on local link
  - `ff02::2` - All routers on local link
  - `ff02::1:ff00:0/104` - Solicited-node multicast

## Prefix Notation (CIDR)

IPv6 uses CIDR notation like IPv4:

```
2001:db8::/32
  ↑        ↑
  prefix   length
```

### Common Prefix Lengths

- `/128` - Single host
- `/64` - Single subnet (standard)
- `/56` - Typical home user allocation
- `/48` - Typical site/organization
- `/32` - ISP allocation
- `/8` - Large regional allocation

### Why /64 is Standard

- Required for SLAAC
- Allows 64-bit interface ID (EUI-64)
- 2^64 addresses per subnet (18 quintillion!)

## Address Assignment Methods

### 1. Static Configuration
Manually configure address and prefix:
```bash
ip -6 addr add 2001:db8::1/64 dev eth0
```

### 2. SLAAC (Stateless Address Autoconfiguration)
- Automatic configuration using Router Advertisements
- Interface creates address from prefix + interface ID
- Most common for hosts

### 3. DHCPv6 (Stateful)
- Similar to DHCP in IPv4
- Provides more control (DNS, etc.)
- Can work alongside SLAAC

### 4. Privacy Extensions (RFC 4941)
- Generates temporary random addresses
- Improves privacy (harder to track devices)
- Changes addresses periodically

## Special Addresses

| Address | Purpose |
|---------|---------|
| `::1` | Loopback |
| `::` | Unspecified |
| `fe80::/10` | Link-local |
| `ff00::/8` | Multicast |
| `2001:db8::/32` | Documentation (examples) |
| `2002::/16` | 6to4 transition |
| `fd00::/8` | Unique local |

## IPv6 in URLs

IPv6 addresses in URLs must be enclosed in brackets:

```
http://[2001:db8::1]/
http://[2001:db8::1]:8080/path
https://[fe80::1%eth0]/
```

## Neighbor Discovery Protocol (NDP)

Replaces ARP from IPv4:

- **Router Solicitation/Advertisement**: Find routers
- **Neighbor Solicitation/Advertisement**: Find neighbors (like ARP)
- **Redirect**: Inform of better routes

Uses ICMPv6 messages.

## Transition Mechanisms

### Dual Stack
- Run IPv4 and IPv6 simultaneously
- Most common approach
- Applications choose which to use

### Tunneling
- 6in4: IPv6 over IPv4 tunnel
- 6to4: Automatic tunneling
- Teredo: For hosts behind NAT

### Translation
- NAT64: IPv6-only to IPv4 communication
- DNS64: Synthesize AAAA records

## IPv6 Headers

### Simplified Header
IPv6 header is simpler than IPv4:
- Fixed 40-byte header
- No header checksum
- No fragmentation by routers
- Extension headers for optional features

### Extension Headers
- Routing
- Fragment
- Authentication (AH)
- Encapsulation (ESP)
- Hop-by-hop options
- Destination options

## Subnetting Examples

### Example 1: Enterprise Network

You receive: `2001:db8::/32`

Allocation:
```
HQ:          2001:db8:0::/48
Branch 1:    2001:db8:1::/48
Branch 2:    2001:db8:2::/48
...
Branch 65535: 2001:db8:ffff::/48
```

Within HQ:
```
Engineering: 2001:db8:0:1::/64
Sales:       2001:db8:0:2::/64
IT:          2001:db8:0:3::/64
...
```

### Example 2: Data Center

You have: `2001:db8::/32`

```
/32         Provider allocation
/40         Region (256 regions)
/48         Data center (256 DCs per region)
/56         Customer (256 customers per DC)
/64         Subnet (256 subnets per customer)
```

## Best Practices

### 1. Addressing Plan
- Plan hierarchy before deployment
- Use consistent patterns
- Document allocations
- Leave room for growth

### 2. Use Standard Prefixes
- `/64` for end-user subnets
- `/48` for sites
- Don't use prefixes longer than /64 for SLAAC

### 3. Security
- Still need firewalls (IPv6 doesn't mean "no firewall")
- Be aware of extension headers
- Monitor ICMPv6 (needed for functionality)
- Watch for ND attacks

### 4. Monitoring
- Track address usage
- Monitor ND cache
- Watch for rogue RAs
- Log unusual traffic

### 5. Documentation
- Document address plan
- Note special allocations
- Keep DNS updated
- Maintain IPAM database

## Common Misconceptions

### ❌ "IPv6 is secure so I don't need a firewall"
**FALSE**: IPv6 includes IPSec, but firewalls are still necessary.

### ❌ "I can use any address in fc00::/7"
**PARTIAL**: Use `fd00::/8`. Generate random global ID.

### ❌ "I should conserve IPv6 addresses"
**FALSE**: Address space is huge. Use /64 liberally.

### ❌ "NAT provides security"
**FALSE**: NAT provides obscurity, not security. Use firewalls.

### ❌ "I can disable ICMPv6"
**FALSE**: ICMPv6 is essential for IPv6 operation (NDP, PMTUD).

## Quick Reference

### Address Classes
```
::1/128                 Loopback
::/128                  Unspecified
fe80::/10               Link-local
fc00::/7                Unique local (ULA)
2000::/3                Global unicast
ff00::/8                Multicast
2001:db8::/32           Documentation
```

### Tools
```bash
# Show IPv6 addresses
ip -6 addr show

# Show IPv6 routes
ip -6 route show

# Show neighbors
ip -6 neigh show

# Ping IPv6
ping6 2001:db8::1

# Trace route
traceroute6 2001:db8::1

# DNS lookup
dig AAAA example.com
```

### Python Quick Start
```python
from ipv6tools import IPv6Address, IPv6Network

# Create address
addr = IPv6Address("2001:db8::1")
print(addr.is_global)  # True

# Create network
net = IPv6Network("2001:db8::/32")
print(net.contains("2001:db8::1"))  # True
```

## Learning Resources

### RFCs
- [RFC 8200](https://tools.ietf.org/html/rfc8200) - IPv6 Specification
- [RFC 4291](https://tools.ietf.org/html/rfc4291) - Addressing Architecture
- [RFC 4862](https://tools.ietf.org/html/rfc4862) - SLAAC
- [RFC 4443](https://tools.ietf.org/html/rfc4443) - ICMPv6

### Websites
- [IPv6.com](https://www.ipv6.com/)
- [Hurricane Electric IPv6 Certification](https://ipv6.he.net/certification/)
- [RIPE NCC IPv6 Info](https://www.ripe.net/support/training/material/ipv6)

### Books
- "IPv6 Fundamentals" by Rick Graziani
- "IPv6 Address Planning" by Tom Coffeen

## Next Steps

1. Read the [Tutorial](TUTORIAL.md)
2. Try the [Examples](../examples/)
3. Use the [Web Tools](../src/web/index.html)
4. Practice with the [CLI Tools](../README.md#command-line-tools)
