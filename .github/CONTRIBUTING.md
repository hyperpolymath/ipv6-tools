# Contributing to ipv6-tools

Thank you for your interest in contributing to `ipv6-tools` — IPv6 policy
enforcement and tooling for the hyperpolymath ecosystem.

This is the GitHub-detected copy of the contribution guide. It is kept in
Markdown on purpose: GitHub's Community Standards checklist only recognises
Markdown for community-health files, even though it renders AsciiDoc. The
canonical AsciiDoc guide is [`CONTRIBUTING.adoc`](../CONTRIBUTING.adoc);
the policy and its exceptions are recorded in
[`docs/documentation-format-policy.adoc`](../docs/documentation-format-policy.adoc).

## Contents

- [Repository layout](#repository-layout)
- [Development setup](#development-setup)
- [Making changes](#making-changes)
- [Documentation format](#documentation-format)
- [Reporting bugs and requesting features](#reporting-bugs-and-requesting-features)
- [Perimeter model](#perimeter-model)

## Repository layout

```text
ipv6-tools/
├── ipv6-only/                  # Rust workspace: IPv6-only policy enforcement
│   ├── crates/                 # core, subnet, utils
│   └── docs/                   # primer, tutorial, citations
├── ipv6-site-enforcer/         # Site-level IPv6 checks + Kubernetes manifests
│   ├── manifests/              # namespace, configmap, deployment, service, networkpolicy
│   ├── hooks/                  # workflow validation hooks (SPDX, SHA pins, permissions)
│   └── contractiles/           # MUST/DUST contracts for this component
├── docs/                       # Repository documentation
│   ├── documentation-format-policy.adoc
│   └── tech-debt-2026-05-26.adoc
├── tests/                      # Test scaffolding (fuzzing placeholder)
├── www/.well-known/            # Protocol files served by the site
├── contractiles/               # MUST/DUST/TRUST/INTENT/ADJUST contracts
├── .machine_readable/          # Machine-readable state (a2ml, contractiles)
├── .github/                    # Workflows, CODEOWNERS, this guide
├── CHANGELOG.adoc
├── CODE_OF_CONDUCT.adoc
├── CONTRIBUTING.adoc           # Canonical AsciiDoc contributor guide
├── GOVERNANCE.adoc
├── Justfile                    # Task runner (run `just` for the recipe list)
├── LICENSES/
├── MAINTAINERS.adoc
├── README.adoc
├── REQUIRES_INITIALISATION.adoc
├── ROADMAP.adoc
├── SECURITY.adoc
├── TEST-NEEDS.adoc
└── TOPOLOGY.adoc
```

## Development setup

```bash
git clone https://github.com/hyperpolymath/ipv6-tools.git
cd ipv6-tools

# Reproducible shell (preferred)
guix develop            # or: mise install && mise exec -- bash

# Verify the checkout
just quality            # fmt-check + clippy + tests
just validate           # RSR + state + documentation-format checks
```

Rust tooling lives under `ipv6-only/`; its workspace parses, has a no_std
core, and is exercised with:

```bash
cd ipv6-only
cargo fmt --all -- --check
cargo clippy --all-targets -- -D warnings
cargo test
cargo audit --deny warnings
```

The enforcer side is Kubernetes manifests plus shell hooks; validate with
`cd ipv6-site-enforcer && just validate`.

## Making changes

### Branch naming

| Prefix | Use |
| --- | --- |
| `feat/` | New functionality |
| `fix/` | Bug fix |
| `docs/` | Documentation |
| `refactor/` | Behaviour-preserving change |
| `ci/` | Workflows and automation |
| `security/` | Security fix |

### Commit messages

Conventional Commits, signed off, GPG-signed where possible:

```text
type(scope): short description

What changed and why. Wrap at 72 columns.

Closes #123
```

Types: `feat`, `fix`, `docs`, `test`, `refactor`, `perf`, `style`,
`chore`, `ci`, `security`.

## Documentation format

AsciiDoc is the canonical documentation format. Write new documents as
`.adoc`. Markdown is permitted only where a platform or tool requires it —
`.github/CONTRIBUTING.md` (this file), issue templates, and agent configs
such as `CLAUDE.md`.

`just docs-format` enforces this, and the Dogfood Gate runs the same check
on pull requests. The full rule, the exception list, and the migration
record live in
[`docs/documentation-format-policy.adoc`](../docs/documentation-format-policy.adoc).

## Reporting bugs and requesting features

Open an issue at <https://github.com/hyperpolymath/ipv6-tools/issues/new>.
Include a clear title, your environment (OS, Rust/Kubernetes versions,
`ipv6-only` or `ipv6-site-enforcer`), steps to reproduce, expected versus
actual behaviour, and a minimal reproduction or log excerpt.

Search existing issues first, and report security problems privately via
<https://github.com/hyperpolymath/ipv6-tools/security/advisories/new> — see
[`SECURITY.adoc`](../SECURITY.adoc).

## Perimeter model

This repository follows the Tri-Perimeter Contribution Framework (TPCF):

- **Perimeter 1 — core**: the release-blocking surface (`ipv6-only`
  core/subnet crates, CI, licensing). Changes need maintainer review.
- **Perimeter 2 — trusted**: tooling around the core (workflows, hooks,
  deployment manifests). Review by a trusted contributor.
- **Perimeter 3 — community sandbox**: documentation, examples, and
  experiments. Open to any contributor.

Good first issues are labelled `good first issue`; help is welcome on
anything labelled `help wanted`.

## Licence

Contributions are licensed under MPL-2.0 (see [`LICENSE`](../LICENSE));
prose and documentation are CC-BY-SA-4.0.
