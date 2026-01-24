;; SPDX-License-Identifier: PMPL-1.0-or-later
;; META.scm - ProvenCrypto.jl architectural decisions and design rationale
;; Media Type: application/meta+scheme

(define-module (meta provencrypto)
  #:use-module (ice-9 match)
  #:export (meta get-adr))

(define meta
  '((metadata
      (version . "0.1.0")
      (schema-version . "1.0.0")
      (created . "2026-01-24")
      (updated . "2026-01-24")
      (project . "ProvenCrypto.jl")
      (media-type . "application/meta+scheme"))

    (architecture-decisions
      ((adr-001
         (title . "Three-layer architecture for crypto safety")
         (status . accepted)
         (date . "2026-01-24")
         (context . "Pure Julia crypto implementations risk timing attacks and side-channel leaks. Battle-tested C libraries (libsodium) provide constant-time guarantees.")
         (decision . "Layer 1 (FFI to proven libs): Timing-sensitive primitives (AES, ChaCha20, Argon2). Layer 2 (Pure Julia): Protocols using Layer 1. Layer 3 (Pure Julia + verification): Post-quantum math (NTT, lattices) where timing is not critical.")
         (consequences . "Positive: Production-safe primitives, pure Julia for research. Negative: FFI overhead for primitives, requires system libsodium."))
       (adr-002
         (title . "Hardware acceleration via package extensions")
         (status . accepted)
         (date . "2026-01-24")
         (context . "Post-quantum crypto involves heavy polynomial arithmetic (NTT). GPUs/TPUs excel at matrix operations. Julia 1.9+ supports conditional package loading.")
         (decision . "Use package extensions for CUDA.jl, AMDGPU.jl, Metal.jl, oneAPI. Auto-detect best backend at runtime, graceful CPU fallback.")
         (consequences . "Positive: Optional GPU support, no mandatory deps. Negative: Requires Julia 1.9+, extension complexity."))
       (adr-003
         (title . "Idris 2 as primary proof assistant")
         (status . accepted)
         (date . "2026-01-24")
         (context . "Need dependent types for cryptographic correctness properties. Idris provides totality checking (termination) and linear types (resource safety).")
         (decision . "Primary export to Idris 2, secondary to Lean 4/Coq/Isabelle. Display 'Idris Inside' badge when critical properties are proven.")
         (consequences . "Positive: Strong correctness guarantees, modern language. Negative: Idris ecosystem smaller than Coq."))
       (adr-004
         (title . "Container isolation for crypto operations")
         (status . accepted)
         (date . "2026-01-24")
         (context . "Crypto code is security-critical and may handle secrets. Need OS-level isolation to prevent leaks from compromised Julia code.")
         (decision . "Run in svalinn/vordr containers with cerro-torre (Ada/SPARK verified) base image. Use Guix for reproducible builds, Nix as fallback. Full seccomp/namespaces/cgroups isolation.")
         (consequences . "Positive: Defense in depth, reproducible builds. Negative: Container overhead, Guix learning curve."))
       (adr-005
         (title . "Post-quantum focus over classical crypto")
         (status . accepted)
         (date . "2026-01-24")
         (context . "Classical crypto (RSA, ECDSA) well-served by libsodium/OpenSSL. Post-quantum needs more research implementations. NIST PQC finalists (Kyber, Dilithium) now standardized.")
         (decision . "Implement all NIST PQC finalists in pure Julia with formal verification. Use FFI for classical crypto. Focus on research/interoperability.")
         (consequences . "Positive: Fills gap in Julia ecosystem, PQC research tool. Negative: Not production-ready, larger codebase."))
       (adr-006
         (title . "No FIPS certification claims")
         (status . accepted)
         (date . "2026-01-24")
         (context . "FIPS 140-2/3 certification requires extensive testing, audits, and certified hardware. Julia implementations cannot be certified.")
         (decision . "Clearly document non-FIPS status. Recommend OpenSSL FIPS module for compliance needs. Focus on research and standards compliance testing.")
         (consequences . "Positive: Honest about limitations, no false security claims. Negative: Not usable in FIPS-required environments."))
       (adr-007
         (title . "Multi-platform support (x86, ARM, RISC-V)")
         (status . accepted)
         (date . "2026-01-24")
         (context . "Crypto needed on diverse hardware: servers (x86), mobile (ARM), embedded (RISC-V), Apple Silicon (M-series).")
         (decision . "Detect SIMD level (AVX-512, NEON, SVE), cache sizes, crypto extensions (AES-NI, SHA-NI), secure enclaves (SGX, SEV, TrustZone). Optimize per platform.")
         (consequences . "Positive: Wide hardware support, optimal performance. Negative: Platform-specific testing burden.")))

    (development-practices
      (code-style
        (formatter . "julia-format")
        (line-length . 100)
        (naming . "snake_case for functions, PascalCase for types")
        (comments . "Docstrings for public API, inline for complex crypto logic"))
      (security
        (constant-time . "All timing-sensitive operations via FFI to libsodium")
        (secret-zeroization . "Explicit zeroing of key material (TODO)")
        (side-channel-resistance . "Rely on libsodium for primitives, CPU-agnostic for PQC")
        (threat-model . "Assumes non-side-channel adversary for pure Julia code"))
      (testing
        (unit-tests . "All public functions")
        (property-tests . "QuickCheck-style for crypto properties")
        (test-vectors . "NIST CAVP, Wycheproof for interoperability")
        (coverage-target . 80))
      (versioning
        (scheme . "SemVer")
        (compatibility . "Julia 1.9+ for package extensions"))
      (documentation
        (api-docs . "Docstrings in source")
        (security-warnings . "Prominently displayed in README and docs")
        (examples . "Usage examples for each algorithm"))
      (branching
        (main-branch . "main")
        (feature-branches . "feat/*, fix/*")
        (release-process . "GitHub releases with SLSA provenance")))

    (design-rationale
      (why-julia
        "Excellent for math-heavy PQC (NTT, lattice operations)"
        "GPU/TPU integration for hardware acceleration"
        "Interop with scientific computing (Axiom.jl, ML security)"
        "Not suitable for timing-sensitive primitives (use FFI)")
      (why-not-pure-julia-primitives
        "Timing attacks on AES/ChaCha20 without constant-time"
        "Side-channel leaks from branch predictor, cache timing"
        "libsodium has 10+ years of hardening and audits"
        "Pure Julia good for PQC where timing less critical")
      (why-idris-over-coq
        "Dependent types + totality checking in one system"
        "Linear types for resource safety (key material)"
        "More modern syntax and tooling than Coq"
        "Quantitative type theory for usage tracking")
      (why-container-isolation
        "Defense in depth for crypto operations"
        "Reproducible builds via Guix"
        "Process isolation prevents memory leaks"
        "Syscall filtering blocks dangerous operations")
      (why-hardware-acceleration
        "PQC polynomial ops benefit from matrix units (Tensor cores, AMX)"
        "NTT parallelizes well on GPU/TPU"
        "Apple Neural Engine can accelerate lattice crypto"
        "Multi-platform reach (server, desktop, mobile)")
      (why-formal-verification
        "Crypto correctness not obvious from code inspection"
        "SMT solvers catch edge cases (zero keys, modular arithmetic)"
        "Proof assistants provide long-term formalization"
        "Idris totality checking prevents non-termination bugs")
      (why-esoteric-algorithms
        "Multivariate, code-based, isogeny crypto underrepresented"
        "Research value for PQC alternatives to lattices"
        "Potential future NIST rounds"
        "Educational: show crypto diversity beyond RSA/ECC"))))

;; Helper function
(define (get-adr id)
  (let ((adrs (assoc-ref meta 'architecture-decisions)))
    (assoc-ref adrs id)))
