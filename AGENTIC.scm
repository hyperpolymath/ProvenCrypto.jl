;; SPDX-License-Identifier: PMPL-1.0-or-later
;; AGENTIC.scm - Agentic capabilities for ProvenCrypto.jl
;; Part of 6scm standard (STATE, ECOSYSTEM, META, NEUROSYM, AGENTIC, PLAYBOOK)

(define-module (agentic provencrypto)
  #:use-module (ice-9 match)
  #:export (agentic get-agent get-capability))

(define agentic
  '((metadata
      (version . "0.1.0")
      (schema-version . "1.0.0")
      (created . "2026-01-24")
      (updated . "2026-01-24")
      (project . "ProvenCrypto.jl"))

    (agentic-paradigm
      (approach . "tool-assisted-verification")
      (description . "Agents assist humans in cryptographic verification and implementation, but critical decisions remain human-controlled")
      (autonomy-level . "collaborative")
      (human-in-loop . "required-for-security-decisions"))

    (agents
      ((agent . "proof-assistant-agent")
       (role . "formal-verification-helper")
       (capabilities
         "Generate Idris/Lean/Coq proof skeletons from specifications"
         "Suggest proof tactics based on proof state"
         "Detect proof obligations that need manual attention"
         "Check proof completeness and correctness")
       (autonomy . "suggest-only")
       (human-approval . "required-for-proof-acceptance")
       (tools
         ("Idris 2 type checker" "Lean 4 tactic engine" "Coq proof assistant" "SMT solvers (Z3, CVC5)"))
       (status . "planned")
       (example-workflow
         "1. Agent reads crypto property from Julia docstring"
         "2. Agent generates Idris proof skeleton with holes"
         "3. Human fills critical proof steps"
         "4. Agent checks proof validity with Idris type checker"
         "5. Human reviews and approves final proof"))

      ((agent . "side-channel-analyzer")
       (role . "security-vulnerability-detection")
       (capabilities
         "Analyze Julia code for timing variations"
         "Detect non-constant-time operations"
         "Suggest constant-time alternatives"
         "Generate test cases to expose timing leaks")
       (autonomy . "detect-and-suggest")
       (human-approval . "required-for-code-changes")
       (tools
         ("Static analysis (Julia AST inspection)" "Dynamic analysis (timing measurements)" "Symbolic execution" "Fuzzing"))
       (status . "planned")
       (example-workflow
         "1. Agent scans kyber.jl for timing-dependent branches"
         "2. Agent flags suspicious if-statements on secret data"
         "3. Agent suggests constant-time alternatives (e.g., bitwise ops)"
         "4. Human reviews suggestions and implements fixes"
         "5. Agent verifies fixes with timing measurements"))

      ((agent . "benchmark-optimizer")
       (role . "performance-optimization")
       (capabilities
         "Run benchmarks across different backends (CPU/GPU/TPU)"
         "Detect performance regressions"
         "Suggest optimal backend for workload"
         "Tune parameters (memory allocation, parallelism)")
       (autonomy . "measure-and-recommend")
       (human-approval . "not-required-for-benchmarks")
       (tools
         ("BenchmarkTools.jl" "CUDA.jl profiler" "perf (Linux)" "Instruments (macOS)"))
       (status . "partially-implemented")
       (example-workflow
         "1. Agent runs NTT benchmark on CPU, CUDA, Metal"
         "2. Agent measures throughput and latency"
         "3. Agent recommends Metal for current workload (M3 Mac)"
         "4. Human accepts or overrides recommendation"
         "5. Agent updates default backend configuration"))

      ((agent . "container-security-auditor")
       (role . "security-policy-validation")
       (capabilities
         "Audit svalinn-policy.json for missing restrictions"
         "Detect overly permissive seccomp filters"
         "Suggest capability drops"
         "Verify namespace isolation")
       (autonomy . "audit-and-report")
       (human-approval . "required-for-policy-changes")
       (tools
         ("JSON schema validator" "Seccomp analyzer" "Capability checker" "Namespace inspector"))
       (status . "planned")
       (example-workflow
         "1. Agent parses svalinn-policy.json"
         "2. Agent checks seccomp allowlist for dangerous syscalls (ptrace, etc.)"
         "3. Agent flags CAP_SYS_ADMIN if granted"
         "4. Human reviews audit report and tightens policy"
         "5. Agent re-validates updated policy"))

      ((agent . "test-vector-generator")
       (role . "standards-compliance-testing")
       (capabilities
         "Download NIST CAVP test vectors"
         "Generate QuickCheck-style property tests"
         "Create interoperability tests (vs. libsodium, OpenSSL)"
         "Detect non-compliance with specifications")
       (autonomy . "generate-tests-autonomously")
       (human-approval . "not-required-for-test-generation")
       (tools
         ("NIST CAVP database" "QuickCheck.jl" "Wycheproof test suite" "RFC parsers"))
       (status . "planned")
       (example-workflow
         "1. Agent downloads Kyber768 NIST test vectors"
         "2. Agent generates Julia test cases from vectors"
         "3. Agent runs tests, detects 2 failures"
         "4. Agent reports failures to human (NTT implementation bug)"
         "5. Human fixes bug, agent re-runs tests (all pass)")))

    (capabilities
      ((capability . "formal-verification-automation")
       (description . "Automate proof skeleton generation and checking")
       (agents-using . ("proof-assistant-agent"))
       (maturity . "experimental")
       (limitations . "Cannot replace human mathematical insight for complex proofs"))

      ((capability . "security-vulnerability-detection")
       (description . "Detect timing leaks, side-channels, and policy violations")
       (agents-using . ("side-channel-analyzer" "container-security-auditor"))
       (maturity . "research")
       (limitations . "Static analysis has false positives, dynamic analysis incomplete"))

      ((capability . "performance-optimization")
       (description . "Benchmark, profile, and recommend performance improvements")
       (agents-using . ("benchmark-optimizer"))
       (maturity . "production-ready")
       (limitations . "Cannot optimize correctness, only performance"))

      ((capability . "standards-compliance-testing")
       (description . "Automated testing against NIST, RFC, and industry standards")
       (agents-using . ("test-vector-generator"))
       (maturity . "planned")
       (limitations . "Standards may be ambiguous or incomplete")))

    (human-agent-collaboration
      ((scenario . "implementing-new-algorithm")
       (human-role . "Understand specification, design algorithm structure, make security decisions")
       (agent-role . "Generate code skeleton, suggest optimizations, run tests, verify properties")
       (collaboration-pattern . "human-leads-agent-assists")
       (example . "Human designs Kyber KEM structure, agent generates NTT code, suggests CUDA optimization, runs test vectors, verifies correctness property in Idris"))

      ((scenario . "fixing-security-vulnerability")
       (human-role . "Understand vulnerability, design fix, approve changes")
       (agent-role . "Detect vulnerability, suggest fixes, verify fix effectiveness")
       (collaboration-pattern . "agent-detects-human-fixes")
       (example . "Agent detects timing leak in Dilithium signing, suggests constant-time alternative, human reviews and implements fix, agent verifies with timing analysis"))

      ((scenario . "optimizing-performance")
       (human-role . "Set performance goals, choose tradeoffs, approve changes")
       (agent-role . "Benchmark current performance, suggest optimizations, measure improvements")
       (collaboration-pattern . "agent-measures-human-decides")
       (example . "Agent benchmarks NTT on CPU/GPU, reports GPU is 10x faster, human approves GPU as default, agent updates configuration"))

      ((scenario . "formal-verification")
       (human-role . "Specify properties, provide mathematical insight, complete difficult proofs")
       (agent-role . "Generate proof skeletons, suggest tactics, check proof validity")
       (collaboration-pattern . "human-proves-agent-checks")
       (example . "Human specifies 'Kyber decapsulation recovers shared secret', agent generates Idris skeleton, human completes key lemmas, agent type-checks proof")))

    (safety-constraints
      (security-decisions-human-only
        "Agent cannot approve cryptographic algorithm changes without human review"
        "Agent cannot modify security policies without human approval"
        "Agent cannot disable security checks or verification steps"
        "Agent cannot push code to production without human sign-off")
      (agent-cannot-override
        "Humans always have final say on security tradeoffs"
        "Agents cannot bypass formal verification requirements"
        "Agents cannot relax container security policies"
        "Agents cannot disable constant-time checks")
      (transparency-requirements
        "Agents must explain all suggestions and recommendations"
        "Agents must show evidence for security vulnerability claims"
        "Agents must log all actions for audit trail"
        "Agents must disclose confidence levels (e.g., 'potential timing leak, 70% confidence')"))

    (integration-with-tools
      ((tool . "Idris 2")
       (agent-capability . "Generate proof skeletons, suggest tactics")
       (human-task . "Complete mathematical proofs, verify correctness"))
      ((tool . "SMT solvers")
       (agent-capability . "Encode properties, run solvers, parse results")
       (human-task . "Specify properties, interpret counterexamples"))
      ((tool . "svalinn/vordr")
       (agent-capability . "Validate security policies, suggest hardening")
       (human-task . "Approve policy changes, understand security implications"))
      ((tool . "CUDA.jl")
       (agent-capability . "Profile GPU performance, suggest optimizations")
       (human-task . "Decide GPU vs. CPU tradeoff, validate correctness"))
      ((tool . "BenchmarkTools.jl")
       (agent-capability . "Run benchmarks, detect regressions")
       (human-task . "Set performance goals, approve optimizations")))

    (future-agentic-capabilities
      (autonomous-proof-search
        "Agents that can complete simple proofs autonomously (e.g., arithmetic lemmas)"
        "Status: Research (GPT-f, COPRA, ProofGPT)")
      (adversarial-testing
        "Agents that generate adversarial inputs to find crypto bugs"
        "Status: Planned")
      (multi-agent-collaboration
        "Multiple agents collaborate (proof-assistant + side-channel-analyzer)"
        "Status: Long-term")
      (learning-from-feedback
        "Agents improve suggestions based on human acceptance/rejection"
        "Status: Research"))))

;; Helper functions
(define (get-agent name)
  (let ((agents (assoc-ref agentic 'agents)))
    (find (lambda (a) (equal? (assoc-ref a 'agent) name)) agents)))

(define (get-capability name)
  (let ((capabilities (assoc-ref agentic 'capabilities)))
    (find (lambda (c) (equal? (assoc-ref c 'capability) name)) capabilities)))
