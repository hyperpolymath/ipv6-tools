;; SPDX-License-Identifier: PMPL-1.0-or-later
(ecosystem (metadata (version "0.2.0") (last-updated "2026-02-08"))
  (project (name "ipv6-site-enforcer") (purpose "IPv6 enforcement with NAT64/DNS64") (role network-enforcement))
  (flatracoon-integration
    (parent "flatracoon/netstack")
    (layer network)
    (depended-on-by ())
    (depends-on ("hesiod-dns-map"))))
