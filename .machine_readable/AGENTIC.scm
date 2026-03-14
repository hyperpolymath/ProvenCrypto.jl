;; SPDX-License-Identifier: MPL-2.0
;; (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
;; AGENTIC.scm for ProvenCrypto.jl

(agentic
  (metadata
    (version "0.1.0")
    (last-updated "2026-03-14"))
  (agent-rules
    (license-policy "MPL-2.0 for Julia ecosystem compatibility")
    (never "Use AGPL license" "Use believe_me or sorry in proofs")
    (always "Run tests before committing" "Verify SPDX headers")))
