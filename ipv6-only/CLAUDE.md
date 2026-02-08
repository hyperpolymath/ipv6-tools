# CLAUDE.md

## Project Overview

This is **ipv6-only**, a project focused on IPv6-only networking implementations, tools, or testing infrastructure.

## Project Purpose

The project aims to work with IPv6-only environments, which may include:
- Tools for IPv6-only network connectivity
- Testing frameworks for IPv6-only scenarios
- Utilities to transition or work in IPv6-only environments
- Educational resources about IPv6-only networking

## Technical Context

### IPv6 Fundamentals
- IPv6 addresses are 128-bit, written in hexadecimal notation (e.g., `2001:0db8::1`)
- No NAT required - every device can have a globally routable address
- Supports multicast, anycast, and unicast addressing
- Uses Neighbor Discovery Protocol (NDP) instead of ARP
- IPSec is mandatory in IPv6 (optional in IPv4)

### Common IPv6 Address Types
- **Link-local**: `fe80::/10` - Used for local network communication
- **Unique local**: `fc00::/7` - Private addresses (similar to IPv4 RFC 1918)
- **Global unicast**: `2000::/3` - Public routable addresses
- **Loopback**: `::1` - Equivalent to 127.0.0.1
- **Multicast**: `ff00::/8` - Group communication

## Development Guidelines

### Code Standards
- Use descriptive variable names for IPv6 addresses and network interfaces
- Always validate IPv6 address format before processing
- Handle both compressed and expanded IPv6 address formats
- Consider dual-stack scenarios where appropriate
- Document any IPv6-specific assumptions or requirements

### Security Considerations
- Validate IPv6 input to prevent injection attacks
- Be aware of IPv6 fragmentation vulnerabilities
- Consider IPv6-specific firewall rules
- Handle IPv6 extension headers properly
- Be cautious with link-local addresses in security contexts

### Testing
- Test with various IPv6 address formats (compressed, expanded, with zones)
- Include edge cases (loopback, link-local, multicast)
- Test connectivity scenarios (reachability, routing)
- Validate error handling for malformed addresses
- Consider performance testing with large IPv6 routing tables

## Project Structure

```
ipv6-only/
├── src/           # Source code
├── tests/         # Test files
├── docs/          # Documentation
├── examples/      # Example usage
└── scripts/       # Utility scripts
```

## Common Commands

### Development
```bash
# Add project-specific development commands here
```

### Testing
```bash
# Add testing commands here
```

### IPv6 Testing Tools
```bash
# Check IPv6 connectivity
ping6 example.com

# Trace IPv6 route
traceroute6 example.com

# Show IPv6 addresses
ip -6 addr show

# Show IPv6 routing table
ip -6 route show
```

## Dependencies

Document any dependencies here as the project develops:
- Network libraries
- IPv6 parsing/validation libraries
- Testing frameworks
- Platform-specific requirements

## Environment Setup

### Prerequisites
- IPv6-enabled network stack
- IPv6 connectivity (native or tunneled)
- Development tools (to be specified)

### Configuration
- Network interface configuration
- IPv6 address assignment methods (SLAAC, DHCPv6, static)
- DNS configuration for IPv6 (AAAA records)

## Known Issues & Limitations

- Document platform-specific IPv6 limitations
- Note any dual-stack compatibility concerns
- List known bugs or workarounds

## Contributing

When contributing to this project:
1. Ensure code works in IPv6-only environments
2. Add tests for new functionality
3. Update documentation
4. Follow coding standards
5. Consider backwards compatibility carefully

## Resources

### IPv6 References
- [RFC 8200](https://tools.ietf.org/html/rfc8200) - Internet Protocol, Version 6 (IPv6) Specification
- [RFC 4291](https://tools.ietf.org/html/rfc4291) - IPv6 Addressing Architecture
- [RFC 4862](https://tools.ietf.org/html/rfc4862) - IPv6 Stateless Address Autoconfiguration
- [RFC 4443](https://tools.ietf.org/html/rfc4443) - ICMPv6 for IPv6

### Tools
- `iproute2` - Modern Linux networking tools
- `nmap` - Network scanning with IPv6 support
- `wireshark` - Packet analysis with IPv6 support
- `tcpdump` - Command-line packet analyzer

## Notes for Claude

### When Working on This Project
- Always consider IPv6-specific requirements and constraints
- Test with both compressed and full IPv6 address formats
- Be aware of scope zones for link-local addresses (e.g., `fe80::1%eth0`)
- Consider platform differences (Linux, Windows, macOS) in IPv6 implementation
- Document any assumptions about network configuration

### Common Patterns
- Use standard libraries for IPv6 parsing when possible
- Implement proper error handling for network operations
- Log IPv6 addresses in a consistent format
- Consider performance implications of IPv6 (larger headers, different MTU)

### Testing Approach
- Unit tests for address parsing and validation
- Integration tests for network connectivity
- Mock network interfaces for testing without real IPv6 connectivity
- Test error conditions and edge cases thoroughly
