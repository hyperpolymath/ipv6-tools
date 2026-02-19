<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- TOPOLOGY.md — Project architecture map and completion dashboard -->
<!-- Last updated: 2026-02-14 -->

# TOPOLOGY — ipv6-tools

## System Architecture

```
ipv6-tools/
├── .machine_readable/    # RSR state files (STATE, META, ECOSYSTEM, etc.)
├── .github/workflows/    # CI/CD (17 standard workflows)
├── ipv6-only/            # IPv6-only network policy
├── ipv6-site-enforcer/   # Site-level IPv6 enforcement tool
├── contractiles/         # K9, dust, lust, must, trust contractiles
├── README.adoc           # Overview
└── Justfile              # Task runner
```

## Completion Dashboard

| Component | Status | Progress |
|-----------|--------|----------|
| RSR Structure | Active | `████████░░` 80% |
| ipv6-only | Active | `██████░░░░` 60% |
| ipv6-site-enforcer | Active | `██████░░░░` 60% |
| Documentation | Active | `██████░░░░` 60% |

## Key Dependencies

- RSR Template: `rsr-template-repo`
