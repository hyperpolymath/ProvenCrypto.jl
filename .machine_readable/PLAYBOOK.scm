;; SPDX-License-Identifier: MPL-2.0
;; (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
;; PLAYBOOK.scm for ProvenCrypto.jl

(playbook
  (metadata
    (version "0.1.0")
    (last-updated "2026-03-14"))
  (build
    (test-command "julia --project=. -e 'using Pkg; Pkg.test()'")
    (ci-platform "github-actions"))
  (deployment
    (registry "Julia General")
    (release-strategy "semver")))
