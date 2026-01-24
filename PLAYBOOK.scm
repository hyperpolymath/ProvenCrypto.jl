;; SPDX-License-Identifier: PMPL-1.0-or-later
;; PLAYBOOK.scm - Operational playbooks for ProvenCrypto.jl
;; Part of 6scm standard (STATE, ECOSYSTEM, META, NEUROSYM, AGENTIC, PLAYBOOK)

(define-module (playbook provencrypto)
  #:use-module (ice-9 match)
  #:export (playbook get-playbook get-runbook))

(define playbook
  '((metadata
      (version . "0.1.0")
      (schema-version . "1.0.0")
      (created . "2026-01-24")
      (updated . "2026-01-24")
      (project . "ProvenCrypto.jl"))

    (playbooks
      ((playbook . "implement-new-pqc-algorithm")
       (description . "Add a new post-quantum cryptographic algorithm to the library")
       (trigger . "NIST announces new PQC standard, or research algorithm needs implementation")
       (prerequisites
         "Algorithm specification document (e.g., NIST submission)"
         "Reference implementation (C/Python/etc.) for validation"
         "Test vectors from specification")
       (steps
         ((step . 1)
          (action . "Create algorithm module")
          (details . "mkdir src/postquantum/<algorithm>.jl, define parameter sets (security levels)")
          (output . "Skeleton file with parameter constants"))
         ((step . 2)
          (action . "Implement core mathematical operations")
          (details . "NTT, polynomial arithmetic, sampling functions")
          (tools . "Julia, LinearAlgebra.jl, backend_ntt_transform")
          (verification . "Unit tests for each operation"))
         ((step . 3)
          (action . "Implement key generation")
          (details . "Following spec, generate public/secret keypairs")
          (verification . "Test with official test vectors"))
         ((step . 4)
          (action . "Implement encryption/signing")
          (details . "Encapsulation (KEM) or signing (signatures)")
          (verification . "Test against reference implementation"))
         ((step . 5)
          (action . "Implement decryption/verification")
          (details . "Decapsulation or signature verification")
          (verification . "Round-trip test: encrypt→decrypt, sign→verify"))
         ((step . 6)
          (action . "Add formal verification claims")
          (details . "Create ProofCertificate, export to Idris/Lean")
          (verification . "Type-check in proof assistant"))
         ((step . 7)
          (action . "Benchmark and optimize")
          (details . "Run benchmarks on CPU/GPU, optimize NTT")
          (tools . "BenchmarkTools.jl, CUDA.jl")
          (verification . "Compare performance to reference implementation"))
         ((step . 8)
          (action . "Add to CI/CD")
          (details . "Update ci.yml to test new algorithm")
          (verification . "CI passes on all platforms"))
         ((step . 9)
          (action . "Document")
          (details . "Add to README, write usage examples, security warnings")
          (verification . "Documentation review"))
         ((step . 10)
          (action . "Release")
          (details . "Tag version, create GitHub release with SBOM")
          (verification . "Release builds on all platforms")))
       (success-criteria
         "Algorithm passes all NIST test vectors"
         "Round-trip tests pass (encrypt→decrypt, sign→verify)"
         "Formal verification claims exported and type-checked"
         "Performance within 2x of reference implementation"
         "CI passes on Linux/macOS/Windows"))

      ((playbook . "fix-timing-side-channel")
       (description . "Detect and fix timing side-channel vulnerability")
       (trigger . "Side-channel analyzer detects timing leak, or security audit finds issue")
       (prerequisites
         "Vulnerable code location identified"
         "Timing measurements showing leak"
         "Understanding of attack model")
       (steps
         ((step . 1)
          (action . "Reproduce timing leak")
          (details . "Write test that measures timing variation on secret data")
          (tools . "BenchmarkTools.jl, statistical tests (t-test)")
          (output . "Proof of timing leak (p-value < 0.05)"))
         ((step . 2)
          (action . "Analyze root cause")
          (details . "Identify secret-dependent branches, variable-time operations")
          (tools . "Julia AST inspection, control-flow analysis")
          (output . "Exact code location causing leak"))
         ((step . 3)
          (action . "Design constant-time fix")
          (details . "Replace if-statements with bitwise ops, use FFI for timing-sensitive ops")
          (options
            "Option A: Rewrite in constant-time Julia (if possible)"
            "Option B: Use libsodium FFI (recommended for primitives)"
            "Option C: Use Rust FFI with constant-time crate")
          (decision-criteria . "Constant-time guarantee > performance"))
         ((step . 4)
          (action . "Implement fix")
          (details . "Apply constant-time transformation")
          (verification . "Code review for secret-dependent branches"))
         ((step . 5)
          (action . "Verify constant-time property")
          (details . "Re-run timing tests, use dudect (constant-time verification)")
          (tools . "Statistical timing analysis, SMT solver (if available)")
          (success . "No timing variation detected (p-value > 0.99)"))
         ((step . 6)
          (action . "Add regression test")
          (details . "Add timing test to CI to prevent reintroduction")
          (verification . "CI catches timing regressions"))
         ((step . 7)
          (action . "Document fix")
          (details . "Update security warnings, add ADR explaining fix")
          (output . "META.scm updated with ADR"))
         ((step . 8)
          (action . "Security advisory")
          (details . "If library already released, issue GitHub Security Advisory")
          (severity . "High (side-channel)")
          (remediation . "Upgrade to patched version")))
       (success-criteria
         "Timing leak eliminated (statistical tests pass)"
         "Formal verification confirms constant-time (if possible)"
         "Regression test in CI prevents reintroduction"
         "Security advisory published (if applicable)"))

      ((playbook . "add-hardware-acceleration")
       (description . "Add GPU/TPU/NPU acceleration for an algorithm")
       (trigger . "Algorithm is too slow on CPU, or new hardware backend available")
       (prerequisites
         "Algorithm already implemented in Julia"
         "Access to target hardware (GPU/TPU/NPU) for testing"
         "Profiling data showing bottleneck operations")
       (steps
         ((step . 1)
          (action . "Profile CPU implementation")
          (details . "Identify hot spots (NTT, polynomial multiply, etc.)")
          (tools . "ProfileView.jl, perf (Linux)")
          (output . "List of bottleneck functions"))
         ((step . 2)
          (action . "Create package extension")
          (details . "ext/ProvenCrypto<Backend>Ext.jl for CUDA/Metal/oneAPI")
          (verification . "Extension loads when backend package imported"))
         ((step . 3)
          (action . "Implement GPU kernels")
          (details . "Port NTT to CUDA/Metal, use GPU linear algebra")
          (tools . "CUDA.jl, Metal.jl, KernelAbstractions.jl")
          (verification . "Kernels produce same output as CPU"))
         ((step . 4)
          (action . "Add backend dispatch")
          (details . "Update backend_ntt_transform to call GPU version")
          (verification . "detect_hardware() returns GPU backend"))
         ((step . 5)
          (action . "Benchmark GPU vs CPU")
          (details . "Measure speedup for different problem sizes")
          (tools . "BenchmarkTools.jl, CUDA.jl profiler")
          (success . "GPU speedup ≥ 2x for large inputs"))
         ((step . 6)
          (action . "Add tests")
          (details . "Test GPU implementation with same test vectors as CPU")
          (verification . "All tests pass on GPU"))
         ((step . 7)
          (action . "Update documentation")
          (details . "Add GPU acceleration section to README, usage examples")
          (verification . "Documentation shows how to use GPU backend"))
         ((step . 8)
          (action . "CI testing")
          (details . "Add GPU CI (if available) or mock tests")
          (verification . "CI tests GPU extension (or mocks if no GPU)")))
       (success-criteria
         "GPU speedup ≥ 2x for target workload"
         "Correctness tests pass (same output as CPU)"
         "Documentation updated with GPU usage"
         "CI tests GPU extension"))

      ((playbook . "formal-verification-workflow")
       (description . "Formally verify a cryptographic property")
       (trigger . "New algorithm implemented, or security property needs proof")
       (prerequisites
         "Algorithm implemented in Julia"
         "Property specification (what to prove)"
         "Proof assistant installed (Idris/Lean/Coq)")
       (steps
         ((step . 1)
          (action . "Specify property")
          (details . "Write formal specification in natural language, then logic")
          (examples
            "∀pk,sk. decapsulate(sk, fst(encapsulate(pk))) = snd(encapsulate(pk))"
            "∀m,pk,sk. verify(pk, m, sign(sk, m)) = true")
          (output . "Formal specification string"))
         ((step . 2)
          (action . "Create proof certificate")
          (details . "ProofCertificate(property, spec, verified=false, ...)")
          (verification . "Certificate created"))
         ((step . 3)
          (action . "Export to proof assistant")
          (details . "export_idris(cert, 'proofs/property.idr')")
          (output . "Idris file with proof skeleton and holes"))
         ((step . 4)
          (action . "Complete proof interactively")
          (details . "Open .idr file in editor, fill proof holes using tactics")
          (tools . "Idris 2, LSP support, proof search")
          (verification . "idris2 --check proofs/property.idr succeeds"))
         ((step . 5)
          (action . "Update certificate")
          (details . "Set verified=true, add proof witness (證明)")
          (verification . "Certificate marked as verified"))
         ((step . 6)
          (action . "Commit proof")
          (details . "git add proofs/, update STATE.scm")
          (verification . "Proof in version control"))
         ((step . 7)
          (action . "Display verification status")
          (details . "Update README with Idris Inside badge if critical property")
          (verification . "Badge shown in README"))
         ((step . 8)
          (action . "CI verification")
          (details . "Add CI step to type-check Idris proofs")
          (verification . "CI fails if proof invalid")))
       (success-criteria
         "Proof type-checks in Idris/Lean/Coq"
         "Property is non-trivial (not just x = x)"
         "Proof committed to version control"
         "CI checks proof validity"))

      ((playbook . "container-security-hardening")
       (description . "Harden container security policy")
       (trigger . "Security audit, new attack vector, or policy drift")
       (prerequisites
         "Current svalinn-policy.json"
         "Understanding of threat model"
         "Access to container runtime for testing")
       (steps
         ((step . 1)
          (action . "Audit current policy")
          (details . "Review seccomp allowlist, capabilities, namespace config")
          (tools . "JSON schema validator, seccomp analyzer")
          (output . "List of potential improvements"))
         ((step . 2)
          (action . "Tighten seccomp filters")
          (details . "Remove unnecessary syscalls from allowlist")
          (verification . "Container still functional with reduced allowlist"))
         ((step . 3)
          (action . "Drop more capabilities")
          (details . "Verify no capabilities needed, drop all")
          (verification . "Container runs without capabilities"))
         ((step . 4)
          (action . "Reduce resource limits")
          (details . "Lower CPU/memory/pids if workload allows")
          (verification . "Workload completes within limits"))
         ((step . 5)
          (action . "Test isolation")
          (details . "Verify namespaces isolate container from host")
          (tools . "unshare, nsenter, lsns")
          (verification . "Cannot escape container"))
         ((step . 6)
          (action . "Document changes")
          (details . "Update svalinn-policy.json comments, add ADR")
          (verification . "Policy changes explained"))
         ((step . 7)
          (action . "CI testing")
          (details . "Run container in CI with new policy")
          (verification . "CI passes with hardened policy")))
       (success-criteria
         "Minimal seccomp allowlist (only necessary syscalls)"
         "No capabilities granted"
         "Resource limits appropriate for workload"
         "Isolation verified (namespaces, seccomp, cgroups)")))

    (runbooks
      ((runbook . "release-new-version")
       (description . "Create a new versioned release of ProvenCrypto.jl")
       (steps
         "1. Update version in Project.toml"
         "2. Update CHANGELOG.md with changes since last release"
         "3. Update STATE.scm with current completion percentage"
         "4. Run full test suite: julia --project -e 'using Pkg; Pkg.test()'"
         "5. Verify CI passes on all platforms"
         "6. Create git tag: git tag -a v0.x.y -m 'Release v0.x.y'"
         "7. Push tag: git push origin v0.x.y"
         "8. GitHub Actions builds release artifacts (SBOM, SLSA provenance)"
         "9. Verify release appears on GitHub with all artifacts"
         "10. Announce release (if public)")
       (verification
         "GitHub release created with SBOM and checksums"
         "All platform builds succeeded"
         "CI tests pass on release tag"))

      ((runbook . "security-incident-response")
       (description . "Respond to security vulnerability report")
       (steps
         "1. Acknowledge report within 24 hours"
         "2. Assess severity (Low/Medium/High/Critical)"
         "3. Reproduce vulnerability in isolated environment"
         "4. If Critical/High: Create private fork for fix development"
         "5. Develop fix following 'fix-timing-side-channel' playbook"
         "6. Test fix thoroughly (unit tests, timing tests, etc.)"
         "7. Prepare security advisory (GitHub Security Advisory)"
         "8. Coordinate disclosure date with reporter"
         "9. Release patched version"
         "10. Publish security advisory"
         "11. Notify users via GitHub, mailing list, etc."
         "12. Post-mortem: Add ADR to META.scm explaining fix")
       (sla
         "Acknowledge: 24 hours"
         "Assessment: 48 hours"
         "Fix for Critical: 7 days"
         "Fix for High: 14 days"))

      ((runbook . "benchmark-regression-investigation")
       (description . "Investigate performance regression detected in CI")
       (steps
         "1. Identify regressed benchmark (CI log)"
         "2. Bisect commits to find regression: git bisect"
         "3. Profile regressed commit vs. baseline"
         "4. Identify performance bottleneck (hot function)"
         "5. Analyze code changes in regressed commit"
         "6. Determine if regression is acceptable tradeoff (security vs. performance)"
         "7. If unacceptable: Revert commit or optimize"
         "8. If acceptable: Update benchmark baseline, document decision"
         "9. Add performance test to prevent future regressions")
       (tools
         "git bisect"
         "julia --project benchmark/benchmarks.jl"
         "ProfileView.jl"
         "perf (Linux)")))))

;; Helper functions
(define (get-playbook name)
  (let ((playbooks (assoc-ref playbook 'playbooks)))
    (find (lambda (p) (equal? (assoc-ref p 'playbook) name)) playbooks)))

(define (get-runbook name)
  (let ((runbooks (assoc-ref playbook 'runbooks)))
    (find (lambda (r) (equal? (assoc-ref r 'runbook) name)) runbooks)))
