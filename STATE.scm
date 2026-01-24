;; SPDX-License-Identifier: PMPL-1.0-or-later
;; STATE.scm - Project state tracking for ProvenCrypto.jl

(define-module (state provencrypto)
  #:use-module (ice-9 match)
  #:export (state get-completion-percentage get-blockers get-milestone))

(define state
  '((metadata
      (version . "0.1.0")
      (schema-version . "1.0.0")
      (created . "2026-01-24")
      (updated . "2026-01-24")
      (project . "ProvenCrypto.jl")
      (repo . "https://github.com/hyperpolymath/ProvenCrypto.jl"))

    (project-context
      (name . "ProvenCrypto.jl")
      (tagline . "Formally verified cryptographic protocols and post-quantum primitives for Julia")
      (tech-stack . ("Julia" "Idris 2" "Lean 4" "Coq" "Rust (benchmarks)" "libsodium FFI" "Guix" "Nix" "svalinn/vordr" "cerro-torre"))
      (target-platforms . ("Linux" "macOS" "Windows" "BSD" "RISC-V" "ARM" "Apple Silicon")))

    (current-position
      (phase . "initial-implementation")
      (overall-completion . 35)
      (components
        ((name . "Hardware backends")
         (status . "implemented")
         (completion . 80)
         (notes . "GPU/NPU/TPU detection, SIMD, advanced features (SGX, SEV, QAT)"))
        ((name . "FFI primitives")
         (status . "implemented")
         (completion . 70)
         (notes . "libsodium wrappers for AEAD, hashing, KDF"))
        ((name . "Post-quantum (Kyber)")
         (status . "skeleton")
         (completion . 40)
         (notes . "Structure complete, NTT placeholders need implementation"))
        ((name . "Post-quantum (Dilithium)")
         (status . "skeleton")
         (completion . 40)
         (notes . "Signature scheme structure, needs full implementation"))
        ((name . "Post-quantum (SPHINCS+)")
         (status . "skeleton")
         (completion . 40)
         (notes . "Hash-based signatures, FORS/HyperTree placeholders"))
        ((name . "Protocols")
         (status . "stub")
         (completion . 10)
         (notes . "Noise, Signal, TLS 1.3 - stubs only"))
        ((name . "Zero-knowledge proofs")
         (status . "stub")
         (completion . 10)
         (notes . "zk-SNARKs, zk-STARKs - stubs only"))
        ((name . "Threshold crypto")
         (status . "stub")
         (completion . 10)
         (notes . "Shamir secret sharing stub"))
        ((name . "Verification/proof export")
         (status . "implemented")
         (completion . 60)
         (notes . "Idris, Lean, Coq, Isabelle export functions"))
        ((name . "Container spec")
         (status . "complete")
         (completion . 100)
         (notes . "svalinn/vordr + cerro-torre, full security policy"))
        ((name . "Documentation")
         (status . "complete")
         (completion . 90)
         (notes . "README with Idris Inside badge, usage examples"))
        ((name . "CI/CD")
         (status . "implemented")
         (completion . 80)
         (notes . "Release workflow, CI tests, CodeQL"))))

      (working-features
        "Hardware detection"
        "AEAD encryption via libsodium"
        "BLAKE3 hashing"
        "Argon2 KDF"
        "Idris/Lean/Coq proof export"
        "Container isolation"))

    (route-to-mvp
      (milestones
        ((name . "Core primitives")
         (target-date . "2026-02-01")
         (status . "in-progress")
         (items
           "Complete Kyber NTT implementation"
           "Complete Dilithium polynomial arithmetic"
           "Complete SPHINCS+ Merkle tree operations"
           "Add comprehensive tests for post-quantum algorithms"))
        ((name . "Protocol implementations")
         (target-date . "2026-02-15")
         (status . "not-started")
         (items
           "Implement Noise Protocol handshake patterns"
           "Implement Signal Double Ratchet"
           "TLS 1.3 handshake (educational reference)"))
        ((name . "Hardware acceleration")
         (target-date . "2026-03-01")
         (status . "partially-done")
         (items
           "CUDA extension for NTT"
           "Metal extension for Apple Silicon"
           "oneAPI extension for Intel GPUs/NPUs"
           "Benchmark suite comparing backends"))
        ((name . "Formal verification")
         (target-date . "2026-03-15")
         (status . "planned")
         (items
           "SMT integration for property verification"
           "Prove Kyber correctness in Idris 2"
           "Prove Dilithium EUF-CMA in Lean 4"
           "Export all critical properties to proof assistants"))
        ((name . "v0.1.0 Release")
         (target-date . "2026-04-01")
         (status . "planned")
         (items
           "All post-quantum algorithms functional"
           "At least one protocol fully implemented"
           "GPU acceleration working"
           "Documentation complete"
           "Test coverage >80%"
           "Container spec tested"))))

    (blockers-and-issues
      (critical
        ())
      (high
        ("NTT (Number Theoretic Transform) implementation for Kyber/Dilithium performance"
         "libsodium availability on Windows CI"))
      (medium
        ("CUDA/Metal/oneAPI package extension implementation"
         "SMT solver integration for formal verification"
         "Comprehensive test vectors from NIST"))
      (low
        ("Benchmark regression tracking"
         "SLSA provenance for releases")))

    (critical-next-actions
      (immediate
        "Implement CPU-optimized NTT for Kyber"
        "Add test cases for Kyber encapsulation/decapsulation"
        "Set up libsodium in CI for all platforms")
      (this-week
        "Implement Dilithium signing and verification"
        "Add CUDA extension skeleton"
        "Create test suite structure")
      (this-month
        "Complete all post-quantum algorithm implementations"
        "Implement Noise Protocol XX pattern"
        "Add SMT property verification"))

    (session-history
      ((date . "2026-01-24")
       (description . "Initial ProvenCrypto.jl implementation")
       (accomplishments
         "Created package structure with Project.toml"
         "Implemented hardware backend detection (GPU, NPU, TPU, CPU SIMD)"
         "Added advanced hardware feature detection (SGX, SEV, QAT, AES-NI)"
         "Implemented libsodium FFI wrappers (AEAD, hash, KDF)"
         "Created post-quantum algorithm skeletons (Kyber, Dilithium, SPHINCS+)"
         "Implemented proof export to Idris, Lean, Coq, Isabelle"
         "Created containerization spec (svalinn/vordr + cerro-torre)"
         "Added comprehensive README with Idris Inside badge"
         "Set up CI/CD workflows (release, tests, CodeQL)")))))

;; Helper functions
(define (get-completion-percentage)
  (assoc-ref (assoc-ref state 'current-position) 'overall-completion))

(define (get-blockers)
  (assoc-ref state 'blockers-and-issues))

(define (get-milestone name)
  (let ((milestones (assoc-ref (assoc-ref state 'route-to-mvp) 'milestones)))
    (find (lambda (m) (equal? (assoc-ref m 'name) name)) milestones)))
