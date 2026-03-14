;; SPDX-License-Identifier: MPL-2.0
;; (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
;; STATE.scm for ProvenCrypto.jl

(state
  (metadata
    (version "0.1.2")
    (last-updated "2026-03-14")
    (status active))
  (project-context
    (name "ProvenCrypto.jl")
    (purpose "Formally verified cryptographic primitives for Julia with GPU acceleration")
    (completion-percentage 30))
  (components
    (component "core-crypto" "SHA, hashing, primitives")
    (component "accelerator-gate" "GPU/coprocessor dispatch")
    (component "zig-ffi" "Zig FFI for verified implementations")
    (component "idris2-abi" "Formal ABI proofs"))
  (critical-next-actions
    (immediate "Implement core cryptographic primitives")
    (short-term "GPU backend integration via AcceleratorGate")
    (long-term "Formal verification of all algorithms via Idris2 ABI")))
