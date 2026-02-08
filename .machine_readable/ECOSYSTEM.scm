;; SPDX-License-Identifier: PMPL-1.0-or-later
;; IPv6 Tools - Ecosystem Position
;; Updated: 2026-02-08

(ecosystem
  (metadata
    (version "1.0")
    (name "ipv6-tools")
    (last-updated "2026-02-08"))
  (type (quote network-tools))
  (purpose "IPv6 policy enforcement and network administration")
  (position-in-ecosystem
    (role (quote network-security))
    (tier (quote infrastructure)))
  (related-projects
    ((name "security-tools")
     (relationship (quote sibling-standard))
     (interaction "Complementary network security tooling"))
    ((name "net-tools")
     (relationship (quote potential-consumer))
     (interaction "May consume IPv6 enforcement policies"))))
