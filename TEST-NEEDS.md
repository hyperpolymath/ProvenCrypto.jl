# TEST-NEEDS: ProvenCrypto.jl

## Current State

| Category | Count | Details |
|----------|-------|---------|
| **Source modules** | 15 | 3,208 lines |
| **Test files** | 1 | 416 lines, 141 @test/@testset |
| **Benchmarks** | 0 | None |
| **E2E tests** | 0 | None |

## What's Missing

### E2E Tests (CRITICAL)
- [ ] No end-to-end encrypt/decrypt/verify pipeline test
- [ ] No interoperability test with standard crypto libraries

### Aspect Tests
- [ ] **Security**: CRYPTO LIBRARY with only 141 tests for 15 modules = 9.4 tests/module. INADEQUATE for security-critical code
- [ ] **Performance**: Crypto operations are performance-sensitive, 0 benchmarks
- [ ] **Error handling**: No tests for padding oracle, timing attacks, malformed ciphertext

### Benchmarks Needed (CRITICAL)
- [ ] Encryption/decryption throughput
- [ ] Key generation time
- [ ] Signature verification latency
- [ ] Comparison with established libraries (OpenSSL, libsodium)

### Self-Tests
- [ ] No self-diagnostic mode
- [ ] No known-answer-test (KAT) suite

## FLAGGED ISSUES
- **Crypto library with 141 tests for 15 modules** -- crypto needs 50+ tests PER MODULE minimum
- **0 benchmarks for crypto** -- performance characteristics unknown
- **3,208 source lines with 416 test lines** = 0.13 test lines per source line. For crypto, this should be >1.0
- **No KAT vectors** -- standard crypto validation is missing

## Priority: P0 (CRITICAL) -- security-critical code with inadequate testing

## FAKE-FUZZ ALERT

- `tests/fuzz/placeholder.txt` is a scorecard placeholder inherited from rsr-template-repo — it does NOT provide real fuzz testing
- Replace with an actual fuzz harness (see rsr-template-repo/tests/fuzz/README.adoc) or remove the file
- Priority: P2 — creates false impression of fuzz coverage
