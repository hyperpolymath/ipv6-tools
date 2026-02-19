# SPDX-License-Identifier: PMPL-1.0-or-later
# ipv6-site-enforcer module manifest for FlatRacoon orchestrator

{
  name = "ipv6-site-enforcer",
  version = "0.1.0",
  layer = 'network,
  description = "IPv6 site enforcement with Jool NAT64 translation and Unbound DNS64 synthesis",
  repo = "github.com/hyperpolymath/ipv6-site-enforcer",
  requires = ["kubernetes", "hesiod-dns-map"],
  provides = ["nat64", "dns64", "ipv6-enforcement"],
  config_schema = "configs/schema.ncl",
  health_endpoint = "/health",
  metrics_endpoint = "/metrics",
  deployment_mode = "kubectl",
  namespace = "ipv6-enforcer",
}
