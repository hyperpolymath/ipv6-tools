# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |
| < 0.1   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via one of the following methods:

### Email

Send details to: **security@ipv6-only.example.com**

Please include:

* Type of issue (e.g., buffer overflow, SQL injection, cross-site scripting, etc.)
* Full paths of source file(s) related to the manifestation of the issue
* The location of the affected source code (tag/branch/commit or direct URL)
* Any special configuration required to reproduce the issue
* Step-by-step instructions to reproduce the issue
* Proof-of-concept or exploit code (if possible)
* Impact of the issue, including how an attacker might exploit it

### GitHub Security Advisories

For GitHub-specific security issues, you can also use GitHub's private vulnerability reporting:

1. Navigate to the main page of the repository
2. Click on the "Security" tab
3. Click "Report a vulnerability"

## Response Timeline

* **Initial Response**: Within 48 hours
* **Status Update**: Within 7 days
* **Resolution Target**: Within 90 days (depending on severity)

## Disclosure Policy

* Security issues are kept confidential until a fix is available
* We will acknowledge your contribution in the security advisory
* You may publicly disclose the vulnerability after we have released a fix

## Security Update Process

1. Security issue is reported privately
2. Issue is triaged and severity assessed
3. Fix is developed in a private branch
4. Security advisory is drafted
5. Fix is released with security advisory
6. Public disclosure after fix is available

## Security Best Practices

When using IPv6-Only Tools:

### Network Security

* **Firewall Configuration**: Always configure firewalls for IPv6, not just IPv4
* **ICMPv6**: Allow necessary ICMPv6 messages but filter appropriately
* **Extension Headers**: Be aware of IPv6 extension header vulnerabilities
* **Router Advertisements**: Protect against rogue RAs

### Application Security

* **Input Validation**: All IPv6 addresses and networks are validated before processing
* **Injection Prevention**: Use parameterized queries and proper escaping
* **Least Privilege**: Run tools with minimum necessary permissions
* **Secure Defaults**: Privacy extensions enabled by default where appropriate

### Container Security

* **Wolfi Base**: We use Chainguard Wolfi for supply chain security
* **Non-root User**: Containers run as non-root by default
* **Minimal Dependencies**: Only essential packages included
* **Regular Updates**: Base images updated regularly

### Scanning Tools

When using security scanning features:

* **Authorization Required**: Only scan networks you own or have permission to scan
* **Rate Limiting**: Respect rate limits and network policies
* **Responsible Disclosure**: Report vulnerabilities found responsibly
* **Legal Compliance**: Ensure compliance with local laws and regulations

## Known Security Considerations

### IPv6-Specific Issues

1. **Neighbor Discovery Protocol (NDP)**
   - Vulnerable to spoofing attacks
   - Use RA Guard and ND inspection where available

2. **Address Scanning**
   - /64 subnets too large for traditional scanning
   - Tools implement smart scanning patterns

3. **Extension Headers**
   - Can be used for evasion
   - Filter unnecessary extension headers

4. **Privacy**
   - EUI-64 addresses leak MAC information
   - Use privacy extensions (RFC 4941)

### Tool-Specific Considerations

1. **Port Scanning**
   - Respect network policies
   - Avoid causing denial of service
   - Use appropriate rate limiting

2. **DNS Queries**
   - May trigger rate limiting
   - Respect TTL values
   - Consider privacy implications

3. **Tunnels (Hurricane Electric)**
   - Secure tunnel endpoints
   - Use strong authentication
   - Monitor for unauthorized access

## Security Features

### Input Validation

* All IPv6 addresses validated using standard library functions
* Network prefixes checked for valid ranges (0-128)
* Zone IDs validated for link-local addresses
* Hostnames validated before DNS queries

### Safe Defaults

* Privacy extensions recommended
* No unnecessary services exposed
* Minimal container attack surface
* Non-executable data directories

### Secure Communication

* HTTPS for web interfaces
* Encrypted tunnel support (IPsec, WireGuard)
* Secure credential storage
* No hardcoded secrets

## Dependency Security

We actively monitor dependencies for vulnerabilities:

* **Python**: Using `safety` and `bandit` for scanning
* **Go**: Using `gosec` for static analysis
* **Container**: Using Trivy for image scanning
* **CI/CD**: GitHub Dependabot enabled

## Security Checklist for Contributors

Before submitting code:

- [ ] All inputs validated
- [ ] No hardcoded credentials
- [ ] Error messages don't leak sensitive information
- [ ] Secure defaults used
- [ ] Security implications documented
- [ ] Tests include security scenarios
- [ ] Dependencies are up to date
- [ ] No known CVEs in dependencies

## Security Tools Integration

### Automated Scanning

* **Bandit**: Python code security scanning
* **Safety**: Python dependency vulnerability checking
* **gosec**: Go code security analysis
* **Trivy**: Container vulnerability scanning
* **Dependabot**: Automated dependency updates

### Manual Review

* Security-focused code review for all PRs
* Threat modeling for new features
* Penetration testing for major releases

## Compliance

### Standards

* OWASP Top 10 awareness
* CWE/SANS Top 25 consideration
* NIST Cybersecurity Framework alignment

### Privacy

* No telemetry by default
* User data stays local
* Privacy-preserving defaults (RFC 4941)

## Contact

For security concerns that are not vulnerabilities (questions, best practices, etc.):

* **Discussions**: Use GitHub Discussions
* **General Email**: contact@ipv6-only.example.com
* **Documentation**: See security documentation in `docs/`

## Acknowledgments

We thank the following researchers for responsibly disclosing vulnerabilities:

* (List will be maintained here)

## Updates

This security policy is reviewed quarterly and updated as needed.

Last updated: 2024-11-22

---

**Note**: This is a living document and will be updated as our security practices evolve.
