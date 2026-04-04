# SPDX-License-Identifier: MPL-2.0
# (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
# BenchmarkTools benchmarks for ProvenCrypto.jl

using BenchmarkTools
using ProvenCrypto

const SUITE = BenchmarkGroup()

SUITE["primitives"] = BenchmarkGroup()

SUITE["primitives"]["blake3_1kb"] = let
    data = rand(UInt8, 1024)
    @benchmarkable hash_blake3($data)
end

SUITE["primitives"]["blake3_1mb"] = let
    data = rand(UInt8, 1024 * 1024)
    @benchmarkable hash_blake3($data)
end

SUITE["primitives"]["aead_encrypt_256b"] = let
    key = rand(UInt8, 32)
    nonce = rand(UInt8, 12)
    pt = rand(UInt8, 256)
    @benchmarkable aead_encrypt($key, $nonce, $pt, UInt8[])
end

SUITE["primitives"]["aead_round_trip_1kb"] = let
    key = rand(UInt8, 32)
    nonce = rand(UInt8, 12)
    pt = rand(UInt8, 1024)
    ct = aead_encrypt(key, nonce, pt, UInt8[])
    @benchmarkable begin
        c = aead_encrypt($key, $nonce, $pt, UInt8[])
        aead_decrypt($key, $nonce, c, UInt8[])
    end
end

SUITE["pqc"] = BenchmarkGroup()

SUITE["pqc"]["kyber512_keygen"] = @benchmarkable kyber_keygen(512)
SUITE["pqc"]["kyber768_keygen"] = @benchmarkable kyber_keygen(768)

SUITE["pqc"]["kyber512_encapsulate"] = let
    (pk, _) = kyber_keygen(512)
    @benchmarkable kyber_encapsulate($pk)
end

SUITE["pqc"]["dilithium2_keygen"] = @benchmarkable dilithium_keygen(2)

SUITE["pqc"]["sphincs128s_keygen"] = @benchmarkable sphincs_keygen(128, :s)

SUITE["pqc"]["sphincs128s_sign"] = let
    (_, sk) = sphincs_keygen(128, :s)
    msg = rand(UInt8, 64)
    @benchmarkable sphincs_sign($sk, $msg)
end

SUITE["zk"] = BenchmarkGroup()

SUITE["zk"]["prove_256b"] = let
    circuit = rand(UInt8, 256)
    witness = rand(UInt8, 64)
    @benchmarkable zk_prove($circuit, $witness)
end

SUITE["zk"]["verify_256b"] = let
    circuit = rand(UInt8, 256)
    witness = rand(UInt8, 64)
    proof = zk_prove(circuit, witness)
    @benchmarkable zk_verify($proof, $circuit)
end

if abspath(PROGRAM_FILE) == @__FILE__
    tune!(SUITE)
    results = run(SUITE, verbose=true)
    BenchmarkTools.save("benchmarks_results.json", results)
end
