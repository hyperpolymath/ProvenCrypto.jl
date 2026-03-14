;; SPDX-License-Identifier: MPL-2.0
;; (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
;; ECOSYSTEM.scm for ProvenCrypto.jl
;; Media-Type: application/vnd.ecosystem+scm

(ecosystem
  (metadata
    (version "0.1.2")
    (last-updated "2026-03-14"))
  (project
    (name "ProvenCrypto.jl")
    (purpose "Formally verified cryptographic primitives for Julia with GPU acceleration")
    (role library))
  (related-projects
    ((name . "KnotTheory.jl")
     (relationship . sibling-project)
     (note . "Julia mathematical library in same ecosystem"))
    ((name . "AcceleratorGate")
     (relationship . dependency)
     (note . "GPU/coprocessor detection and dispatch"))))
