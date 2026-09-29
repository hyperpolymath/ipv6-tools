#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# check-doc-format.sh — enforce the AsciiDoc-first documentation policy.
#
# Policy and exception rationale: docs/documentation-format-policy.adoc
#
# Checks:
#   1. Markdown may only exist at allowlisted paths (platform/tool exceptions).
#   2. No document may point at a repository-local .md file that has been
#      converted to .adoc (a stale reference left by the migration).
#   3. No .adoc file may contain Markdown inline-link syntax, which renders
#      literally in AsciiDoc.
#
# Exit codes: 0 = policy satisfied, 1 = violations (listed on stdout).

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "doc-format: SKIP (not a git work tree)" >&2
  exit 0
fi

# ── 1. Markdown allowlist ────────────────────────────────────────────────────
# Bash globs matched against the repo-relative path ('*' also matches '/').
# Every entry MUST be justified in docs/documentation-format-policy.adoc.
allow_md=(
  '.github/CONTRIBUTING.md'          # GitHub community-health detection (md only)
  '.github/CODE_OF_CONDUCT.md'       # GitHub community-health detection (md only)
  '.github/SECURITY.md'              # GitHub community-health detection (md only)
  '.github/PULL_REQUEST_TEMPLATE.md' # GitHub PR template (md only)
  '*CLAUDE.md'                       # Claude agent config filename
  '*GEMINI.md'                       # Gemini agent config filename
  '*AGENTS.md'                       # generic agent config filename
  '*.claude/*.md'                    # agent support files
  '*.github/ISSUE_TEMPLATE/*.md'     # GitHub issue templates (md or yml only)
  '*.github/ISSUE_TEMPLATE/*/*.md'   # nested issue-template assets
  'CHANGELOG.md'                     # legacy output of external changelog tooling
)

# ── Helpers ──────────────────────────────────────────────────────────────────
fail=0
section() { printf '\n%s\n' "$1"; }

# All tracked files plus untracked-but-not-ignored files, repo-relative.
list_files() {
  git ls-files --cached --others --exclude-standard -- "$@"
}

# Extract reference tokens that point at a .md file:
#   link:path.md[...]   xref:path.md[...]   [label](path.md)
#   `path.md`   `+path.md+`   +path.md+
ref_pattern='((link|xref):[^][ ]+\.md|\[[^]]*\]\([^)]+\.md|`\+?[A-Za-z0-9_./-]+\.md\+?`|\+[A-Za-z0-9_./-]+\.md\+)'

# Normalise a matched token to a bare path.
normalise_path() {
  printf '%s' "$1" | sed -E \
    -e 's/^(link|xref)://' \
    -e 's/^.*\]\(//' \
    -e 's/\).*$//' \
    -e 's/`//g' \
    -e 's/^\+//' -e 's/\+$//' \
    -e 's/#.*$//' \
    -e 's/[[:space:]]+$//'
}

# ── Check 1: Markdown allowlist ──────────────────────────────────────────────
section "== Markdown allowlist"
mapfile -t md_files < <(list_files '*.md' | sort)
unlisted=()
for f in "${md_files[@]}"; do
  allowed=0
  for pattern in "${allow_md[@]}"; do
    # shellcheck disable=SC2053  # intentional glob match, not regex
    if [[ "$f" == $pattern ]]; then allowed=1; break; fi
  done
  if (( allowed == 0 )); then
    unlisted+=("$f")
    echo "::error file=$f::Markdown not allowlisted — convert to AsciiDoc (.adoc), or justify an exception in docs/documentation-format-policy.adoc and scripts/check-doc-format.sh"
  fi
done
if (( ${#unlisted[@]} == 0 )); then
  echo "OK: ${#md_files[@]} Markdown file(s), all allowlisted."
else
  fail=1
  printf 'FAIL: %d unlisted Markdown file(s).\n' "${#unlisted[@]}"
fi

# ── Check 2: references to converted files ───────────────────────────────────
# A reference fails only when it resolves to a path in this repository that is
# absent as .md but present as .adoc — i.e. provably stale. References into
# other repositories (and template tokens) are ignored.
section "== References to converted (.md -> .adoc) files"
stale=0
while IFS= read -r file; do
  [ -n "$file" ] || continue
  dir="$(dirname "$file")"
  while IFS= read -r token; do
    [ -n "$token" ] || continue
    path="$(normalise_path "$token")"
    [ -n "$path" ] || continue
    case "$path" in
      *://*|*'{{'*|*'%7B'*|/*) continue ;;   # URL, template token, absolute path
    esac
    resolved="$dir/$path"
    twin="${resolved%.md}.adoc"
    if [ ! -e "$resolved" ] && [ -e "$twin" ]; then
      echo "::error file=$file::stale reference '$path' — the file is now '$(basename "$twin")'"
      stale=$((stale + 1))
    fi
  done < <(grep -oE "$ref_pattern" "$file" 2>/dev/null || true)
done < <(list_files '*.adoc' '*.a2ml' '*.yml' '*.yaml' '*.just' 'Justfile' '*.sh' '*.ncl' | sort)
if (( stale == 0 )); then
  echo "OK: no stale .md references."
else
  fail=1
  printf 'FAIL: %d stale .md reference(s).\n' "$stale"
fi

# ── Check 3: Markdown inline-link syntax inside AsciiDoc ─────────────────────
section "== Markdown syntax in AsciiDoc"
md_syntax=0
while IFS= read -r file; do
  [ -n "$file" ] || continue
  while IFS= read -r hit; do
    [ -n "$hit" ] || continue
    echo "::error file=$file,line=${hit%%:*}::Markdown inline-link syntax in AsciiDoc — use link:target[label]"
    md_syntax=$((md_syntax + 1))
  done < <(grep -nE '\]\([A-Za-z0-9_./#%:+-]+\)' "$file" 2>/dev/null || true)
done < <(list_files '*.adoc' | sort)
if (( md_syntax == 0 )); then
  echo "OK: no Markdown link syntax in .adoc files."
else
  fail=1
  printf 'FAIL: %d Markdown-syntax occurrence(s).\n' "$md_syntax"
fi

# ── Verdict ──────────────────────────────────────────────────────────────────
echo
if (( fail )); then
  echo "doc-format: FAIL — see docs/documentation-format-policy.adoc"
  exit 1
fi
echo "doc-format: PASS"
