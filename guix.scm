; SPDX-License-Identifier: MPL-2.0
;; guix.scm — GNU Guix package definition for ipv6-tools
;; Usage: guix shell -f guix.scm

(use-modules (guix packages)
             (guix build-system gnu)
             (guix licenses))

(package
  (name "ipv6-tools")
  (version "0.1.0")
  (source #f)
  (build-system gnu-build-system)
  (synopsis "ipv6-tools")
  (description "ipv6-tools — part of the hyperpolymath ecosystem.")
  (home-page "https://github.com/hyperpolymath/ipv6-tools")
  (license ((@@ (guix licenses) license) "MPL-2.0"
             "https://github.com/hyperpolymath/palimpsest-license")))
