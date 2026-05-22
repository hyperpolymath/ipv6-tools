# SPDX-License-Identifier: MPL-2.0
# ipv6-site-enforcer module manifest for FlatRacoon orchestrator
#
# This module implements the "Danger Zone" network policy: 
# enforcing IPv6-only internal routing while providing transparent access 
# to the legacy IPv4 internet via NAT64/DNS64.

{
  name = "ipv6-site-enforcer",
  version = "0.1.0",
  
  # LAYER: Operates at the network topology layer.
  layer = 'network,
  
  description = "IPv6 site enforcement with Jool NAT64 translation and Unbound DNS64 synthesis",
  repo = "github.com/hyperpolymath/ipv6-site-enforcer",
  
  # DEPENDENCIES: Requires a K8s control plane and the Hesiod DNS discovery service.
  requires = ["kubernetes", "hesiod-dns-map"],
  
  # CAPABILITIES: Exposes IPv6 transition services to the rest of the stack.
  provides = ["nat64", "dns64", "ipv6-enforcement"],
  
  # Validated against the standard FlatRacoon network schema.
  config_schema = "configs/schema.ncl",
  
  # Target namespace for isolation.
  namespace = "ipv6-enforcer",
}
