;; SPDX-License-Identifier: PMPL-1.0-or-later
;; ECOSYSTEM.scm - ProvenCrypto.jl position in the hyperpolymath ecosystem

(ecosystem
  (version "1.0.0")
  (name "ProvenCrypto.jl")
  (type "library")
  (purpose "Formally verified cryptographic protocols and post-quantum primitives")

  (position-in-ecosystem
    (category "proven-library-suite")
    (role "cryptography-standards")
    (layer "application-crypto")
    (maturity "initial-implementation"))

  (related-projects
    ((name . "Axiom.jl")
     (relationship . "sibling-standard")
     (connection . "Both use formal verification, hardware acceleration, proven library patterns")
     (integration . "ProvenCrypto can verify neural network encryption, Axiom can use ProvenCrypto for model security"))

    ((name . "SMTLib.jl")
     (relationship . "dependency")
     (connection . "SMT solver integration for cryptographic property verification")
     (integration . "ProvenCrypto uses SMTLib for @prove macro and verification certificates"))

    ((name . "verified-container-spec")
     (relationship . "infrastructure")
     (connection . "Container specifications for isolated crypto operations")
     (integration . "ProvenCrypto runs in svalinn/vordr containers with cerro-torre base image"))

    ((name . "proven (OCaml)")
     (relationship . "sibling-standard")
     (connection . "Same proven library philosophy, different language")
     (integration . "Shared verification patterns, FFI to same proven C libraries"))

    ((name . "proven (Nim)")
     (relationship . "sibling-standard")
     (connection . "Same proven library philosophy, different language")
     (integration . "Shared verification patterns, FFI to same proven C libraries"))

    ((name . "bunsenite")
     (relationship . "potential-consumer")
     (connection . "Nickel configuration with crypto operations")
     (integration . "Could use ProvenCrypto for config encryption/signing"))

    ((name . "januskey")
     (relationship . "potential-consumer")
     (connection . "SSH key management and authentication")
     (integration . "Post-quantum SSH keys via ProvenCrypto"))

    ((name . "libsodium")
     (relationship . "external-dependency")
     (connection . "Battle-tested cryptographic primitives via FFI")
     (integration . "ProvenCrypto wraps libsodium for timing-sensitive operations"))

    ((name . "Idris 2")
     (relationship . "verification-backend")
     (connection . "Dependent types for proof export")
     (integration . "ProvenCrypto exports verification certificates to Idris"))

    ((name . "Lean 4")
     (relationship . "verification-backend")
     (connection . "Mathlib for mathematical proofs")
     (integration . "ProvenCrypto exports theorems to Lean"))

    ((name . "Coq")
     (relationship . "verification-backend")
     (connection . "Proof assistant for long-term formalization")
     (integration . "ProvenCrypto exports Gallina definitions"))

    ((name . "WireGuard")
     (relationship . "inspiration")
     (connection . "Uses Noise Protocol - same protocol we implement")
     (integration . "Interoperability testing with WireGuard's Noise implementation"))

    ((name . "Signal Protocol")
     (relationship . "inspiration")
     (connection . "Double Ratchet reference implementation")
     (integration . "Interoperability with Signal's protocol"))

    ((name . "NIST PQC")
     (relationship . "specification")
     (connection . "Post-quantum algorithm specifications")
     (integration . "Implement Kyber, Dilithium per NIST specs, test with official vectors")))

  (what-this-is
    "A Julia library providing formally verified cryptographic protocols"
    "Post-quantum cryptography (Kyber, Dilithium, SPHINCS+) with hardware acceleration"
    "Protocol implementations (Noise, Signal, TLS 1.3) for research and verification"
    "FFI wrappers to proven libraries (libsodium) for production-safe primitives"
    "Proof export to Idris, Lean, Coq for long-term formalization"
    "Multi-platform support (x86, ARM, RISC-V, Apple Silicon, GPU, NPU, TPU)"
    "Container-based isolation for security-critical operations"
    "Educational and research tool for modern cryptography")

  (what-this-is-not
    "Not a FIPS-certified implementation (use OpenSSL FIPS module for compliance)"
    "Not a replacement for libsodium in production (use our FFI wrappers instead)"
    "Not optimized for embedded systems (focuses on server/desktop)"
    "Not a blockchain library (though it provides crypto primitives blockchains could use)"
    "Not a key management system (focuses on algorithms, not key lifecycle)"
    "Not battle-tested for production (research/educational focus)")

  (dependencies
    (runtime
      ("Julia" "1.9+")
      ("libsodium" "system library for AEAD/hash/KDF"))
    (optional
      ("CUDA.jl" "NVIDIA GPU acceleration")
      ("AMDGPU.jl" "AMD GPU acceleration")
      ("Metal.jl" "Apple Silicon acceleration")
      ("SMTLib.jl" "Formal verification")
      ("Guix" "Reproducible builds in containers")
      ("Nix" "Fallback package manager")))

  (used-by
    (planned
      "Axiom.jl - Model encryption and verification"
      "bunsenite - Configuration security"
      "januskey - Post-quantum SSH"
      "Research projects - PQC interoperability testing")))
