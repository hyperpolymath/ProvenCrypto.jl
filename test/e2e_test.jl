# SPDX-License-Identifier: MPL-2.0
# (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
# E2E pipeline tests for ProvenCrypto.jl

using Test
using ProvenCrypto
using Dates

@testset "E2E Pipeline Tests" begin

    @testset "Full AEAD encrypt/decrypt round-trip pipeline" begin
        key = rand(UInt8, 32)
        nonce = rand(UInt8, 12)
        plaintext = Vector{UInt8}("The quick brown fox jumps over the lazy dog")
        ad = Vector{UInt8}("context header")

        ciphertext = aead_encrypt(key, nonce, plaintext, ad)
        @test length(ciphertext) == length(plaintext) + 16

        recovered = aead_decrypt(key, nonce, ciphertext, ad)
        @test recovered == plaintext

        # Tampered ciphertext must fail authentication
        bad = copy(ciphertext)
        bad[end] ⊻= 0xFF
        @test aead_decrypt(key, nonce, bad, ad) === nothing
    end

    @testset "Full ZK-SNARK prove/verify pipeline" begin
        circuit = Vector{UInt8}("circuit: x + y = z")
        witness = Vector{UInt8}("x=3, y=4, z=7")

        proof = zk_prove(circuit, witness)
        @test proof isa ZKProof
        @test zk_verify(proof, circuit) == true
        @test zk_verify(proof, Vector{UInt8}("different circuit")) == false
    end

    @testset "Kyber KEM full pipeline" begin
        for level in [512, 768, 1024]
            (pk, sk) = kyber_keygen(level)
            (ct, ss1) = kyber_encapsulate(pk)
            @test length(ss1) == 32
            @test length(ct) > 0
            # Two encapsulations should differ (randomised)
            (ct2, ss2) = kyber_encapsulate(pk)
            @test ct != ct2
        end
    end

    @testset "Proof export pipeline" begin
        cert = ProofCertificate(
            "End-to-end property",
            "∀x ∈ ℤ. x + 0 = x",
            true,
            "test",
            now(),
            "by ring",
            Dict{String,Any}()
        )

        for (ext, check_str) in [(".idr", "module"), (".lean", "theorem"), (".v", "Theorem"), (".thy", "theory")]
            path = tempname() * ext
            if ext == ".idr"
                export_idris(cert, path)
            elseif ext == ".lean"
                export_lean(cert, path)
            elseif ext == ".v"
                export_coq(cert, path)
            else
                export_isabelle(cert, path)
            end
            @test isfile(path)
            content = read(path, String)
            @test occursin(check_str, content)
            rm(path, force=true)
        end
    end

end
