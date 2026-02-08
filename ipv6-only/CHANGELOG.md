# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Mustfile.epx for deployment state management
- Pre-commit hook script for RSR compliance
- Makefile prohibition enforcement in CI

### Changed
- **BREAKING**: Migrated from Python/Go to pure Rust implementation
- Justfile cleaned up to remove non-existent Python/Go/web paths
- CI workflows updated for Rust-only builds
- Containerfile now uses multi-stage Rust build with Wolfi base
- CONTRIBUTING.md updated with RSR language policy
- QUICKSTART.md rewritten for Rust CLI usage
- MAINTAINERS.md updated with RSR compliance responsibilities

### Removed
- Python library (ipv6tools package) - replaced by Rust crates
- Go tools - replaced by Rust implementation
- Web application references - not yet implemented
- Makefile - replaced by justfile
- npm/node dependencies - use Deno if needed

## [0.1.0] - 2024-12-26

### Added
- Rust implementation of IPv6 tools
  - `ipv6-only-core`: Core IPv6Address and IPv6Network types
  - `ipv6-only-utils`: Address utilities (compression, expansion, generation)
  - `ipv6-only-subnet`: Subnet calculator with division and containment
- CLI tool (`ipv6`) with subcommands:
  - `validate` - Address validation
  - `calc` - Subnet calculations
  - `generate` - Address generation (link-local, ULA, EUI-64)
  - `convert` - Format conversion (compress, expand, reverse DNS)
  - `analyze` - Address type analysis
- Complete Justfile automation framework
- Podman Containerfile with Chainguard Wolfi base
- Nickel configuration system (config/ipv6-tools.ncl)
- Hurricane Electric tunnel integration scripts:
  - he-tunnel-setup.sh
  - he-update-endpoint.sh
  - he-check-status.sh
  - he-cert-check.sh
- Shell scripts for diagnostics:
  - ipv6-diag.sh
  - ipv6-config.sh
- RSR compliance:
  - CODE_OF_CONDUCT.md
  - MAINTAINERS.md
  - CHANGELOG.md
  - RSR anti-pattern CI checks
- Documentation:
  - README.adoc with installation and usage
  - TUTORIAL.md
  - IPv6_PRIMER.md
  - QUICKSTART.md
  - ROADMAP.adoc
- CI/CD pipeline with GitHub Actions:
  - Multi-version Rust testing (stable, beta)
  - Clippy linting
  - Rustfmt checks
  - Security scanning (cargo-audit)
  - Container builds

### Security
- SECURITY.md with vulnerability reporting procedures
- Security scanning in CI/CD pipeline
- Podman containerization with minimal attack surface
- Non-root container execution
- RSR language policy for supply chain security

## Release Types

### Version Numbering

We use Semantic Versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Incompatible API changes
- **MINOR**: Backwards-compatible new features
- **PATCH**: Backwards-compatible bug fixes

### Release Process

1. Update version in Cargo.toml
2. Update this CHANGELOG.md
3. Create git tag: `git tag -a vX.Y.Z -m "Release X.Y.Z"`
4. Build packages: `just build-release`
5. Build container: `just container-build vX.Y.Z`
6. Create GitHub release with notes
7. Push container images

### Support Policy

- **Latest major version**: Full support (features + security)
- **Previous major version**: Security updates only (6 months)
- **Older versions**: Community support only

## Links

- [Repository](https://github.com/hyperpolymath/ipv6-only)
- [Issue Tracker](https://github.com/hyperpolymath/ipv6-only/issues)
- [Releases](https://github.com/hyperpolymath/ipv6-only/releases)
