# SPDX-License-Identifier: MPL-2.0
# (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
# Property-based invariant tests for ProvenCrypto.jl

using Test
using ProvenCrypto

@testset "Property-Based Tests" begin

    @testset "Invariant: BLAKE3 hash is deterministic and 32 bytes" begin
        for _ in 1:50
            n = rand(1:200)
            data = rand(UInt8, n)
            h1 = hash_blake3(data)
            h2 = hash_blake3(data)
            @test length(h1) == 32
            @test h1 == h2
        end
    end

    @testset "Invariant: AEAD ciphertext length = plaintext + 16" begin
        for _ in 1:50
            n = rand(1:100)
            key = rand(UInt8, 32)
            nonce = rand(UInt8, 12)
            pt = rand(UInt8, n)
            ct = aead_encrypt(key, nonce, pt, UInt8[])
            @test length(ct) == n + 16
        end
    end

    @testset "Invariant: AEAD round-trip succeeds with matching key/nonce" begin
        for _ in 1:30
            key = rand(UInt8, 32)
            nonce = rand(UInt8, 12)
            pt = rand(UInt8, rand(1:50))
            ct = aead_encrypt(key, nonce, pt, UInt8[])
            recovered = aead_decrypt(key, nonce, ct, UInt8[])
            @test recovered == pt
        end
    end

    @testset "Invariant: Kyber shared secret is always 32 bytes" begin
        for level in [512, 768, 1024]
            (pk, _) = kyber_keygen(level)
            for _ in 1:10
                (_, ss) = kyber_encapsulate(pk)
                @test length(ss) == 32
            end
        end
    end

    @testset "Invariant: ZK proof verification fails on different circuit" begin
        for _ in 1:20
            circuit = rand(UInt8, rand(10:40))
            witness = rand(UInt8, rand(5:20))
            proof = zk_prove(circuit, witness)
            different = rand(UInt8, rand(10:40))
            if different != circuit
                @test zk_verify(proof, different) == false
            end
        end
    end

end
