;; SPDX-License-Identifier: PMPL-1.0-or-later
;; IPv6 Tools - Meta Information
;; Updated: 2026-02-08

(meta
  (metadata
    (version "1.0")
    (name "ipv6-tools")
    (type (quote monorepo))
    (last-updated "2026-02-08"))
  (languages
    ("rust" "bash"))
  (architecture-decisions
    ((id "ADR-001")
     (title "Monorepo structure for IPv6 tools")
     (status (quote accepted))
     (rationale "Shared code and consistent tooling across IPv6 enforcement components")))
  (development-practices
    ((practice "RSR compliance")
     (status (quote active))
     (description "Repository follows hyperpolymath RSR template standards")))
  (design-rationale
    ((area "Network enforcement")
     (rationale "Focus on IPv6-only policies to improve network security and reduce IPv4 dependency"))))
