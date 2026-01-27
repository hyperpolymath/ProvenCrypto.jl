# SPDX-License-Identifier: PMPL-1.0-or-later
"""
Hardware acceleration backend detection and abstraction.

Supports:
- NVIDIA CUDA (Tensor cores for lattice crypto)
- AMD ROCm (Matrix cores)
- Apple Metal (Neural Engine for post-quantum)
- Intel oneAPI (NPU/GPU)
- Google TPU (via XLA)
- FPGA (OpenCL)
- CPU SIMD (AVX2, AVX-512, NEON, SVE)
"""

abstract type AbstractCryptoBackend end

struct CPUBackend <: AbstractCryptoBackend
    simd_level::Symbol  # :none, :sse, :avx, :avx2, :avx512, :neon, :sve
    threads::Int
end

struct CUDABackend <: AbstractCryptoBackend
    device::Int
    has_tensor_cores::Bool
    compute_capability::VersionNumber
end

struct ROCmBackend <: AbstractCryptoBackend
    device::Int
    has_matrix_cores::Bool
    gcn_arch::String
end

struct MetalBackend <: AbstractCryptoBackend
    device::Int
    has_neural_engine::Bool
    apple_silicon_generation::Int  # M1=1, M2=2, M3=3, M4=4
end

struct OneAPIBackend <: AbstractCryptoBackend
    device::Int
    has_npu::Bool
    device_type::Symbol  # :gpu, :cpu, :fpga
end

struct TPUBackend <: AbstractCryptoBackend
    version::Int
    topology::String
end

# --- Backend Availability Detection ---
# Default implementations (overridden by package extensions)
"""
    cuda_available() -> Bool

Check if CUDA is available. Override in extensions.
"""
cuda_available() = false

"""
    rocm_available() -> Bool

Check if ROCm is available. Override in extensions.
"""
rocm_available() = false

"""
    metal_available() -> Bool

Check if Metal is available. Override in extensions.
"""
metal_available() = false

"""
    oneapi_available() -> Bool

Check if oneAPI is available. Override in extensions.
"""
oneapi_available() = false

"""
    tpu_available() -> Bool

Check if TPU is available. Override in extensions.
"""
tpu_available() = false

# --- Hardware Detection Utilities ---
"""
    detect_simd_level() -> Symbol

Detect CPU SIMD instruction set support.
Returns highest available: :avx512, :avx2, :avx, :sse, :neon, :sve, :none
"""
function detect_simd_level()
    if Sys.isapple() && Sys.ARCH === :aarch64
        return :neon  # Apple Silicon always has NEON
    elseif Sys.ARCH === :aarch64
        if haskey(ENV, "JULIA_CPU_TARGET") && occursin("sve", ENV["JULIA_CPU_TARGET"])
            return :sve
        else
            return :neon
        end
    elseif Sys.ARCH === :x86_64
        try
            cpu_info = lowercase(Sys.CPU_NAME)
            if occursin("avx512", cpu_info)
                return :avx512
            elseif occursin("avx2", cpu_info)
                return :avx2
            elseif occursin("avx", cpu_info)
                return :avx
            else
                return :sse  # Baseline x86-64 has SSE2
            end
        catch
            return :sse
        end
    else
        return :none
    end
end

"""
    detect_apple_silicon_generation() -> Int

Detect Apple Silicon generation (M1=1, M2=2, M3=3, M4=4, etc.)
"""
function detect_apple_silicon_generation()
    if !Sys.isapple() || Sys.ARCH !== :aarch64
        return 0
    end
    try
        output = read(`system_profiler SPHardwareDataType`, String)
        if occursin("M4", output)
            return 4
        elseif occursin("M3", output)
            return 3
        elseif occursin("M2", output)
            return 2
        elseif occursin("M1", output)
            return 1
        end
    catch
        return 1  # Fallback: assume M1
    end
    return 0
end

"""
    detect_hardware() -> AbstractCryptoBackend

Auto-detect best available hardware backend for cryptography.
Priority order: TPU > CUDA > Metal > oneAPI > ROCm > CPU.
"""
function detect_hardware()
    # TPU (highest priority)
    if tpu_available()
        try
            if haskey(ENV, "TPU_NAME")
                return TPUBackend(4, ENV["TPU_NAME"])
            end
        catch e
            @warn "TPU detection failed" exception=e
        end
    end

    # CUDA
    if cuda_available()
        try
            return CUDABackend(0, true, v"8.0")  # Placeholder; override in extension
        catch e
            @warn "CUDA backend creation failed" exception=e
        end
    end

    # Metal
    if metal_available()
        try
            gen = detect_apple_silicon_generation()
            has_ne = gen >= 2  # Neural Engine improved in M2+
            return MetalBackend(0, has_ne, gen)
        catch e
            @warn "Metal backend creation failed" exception=e
        end
    end

    # oneAPI
    if oneapi_available()
        try
            return OneAPIBackend(0, false, :gpu)  # Placeholder; override in extension
        catch e
            @warn "oneAPI backend creation failed" exception=e
        end
    end

    # ROCm
    if rocm_available()
        try
            return ROCmBackend(0, false, "gfx900")  # Placeholder; override in extension
        catch e
            @warn "ROCm backend creation failed" exception=e
        end
    end

    # Fallback to CPU
    simd = detect_simd_level()
    threads = Threads.nthreads()
    return CPUBackend(simd, threads)
end

# --- Backend-Specific Operations ---
# Dispatch to backend-specific implementations (defined in extensions)
"""
    backend_lattice_multiply(backend::AbstractCryptoBackend, args...)
"""
function backend_lattice_multiply(backend::AbstractCryptoBackend, args...)
    throw(MethodError(backend_lattice_multiply, (backend, args...)))
end

"""
    backend_ntt_transform(backend::AbstractCryptoBackend, args...)
"""
function backend_ntt_transform(backend::AbstractCryptoBackend, args...)
    throw(MethodError(backend_ntt_transform, (backend, args...)))
end

"""
    backend_polynomial_multiply(backend::AbstractCryptoBackend, args...)
"""
function backend_polynomial_multiply(backend::AbstractCryptoBackend, args...)
    throw(MethodError(backend_polynomial_multiply, (backend, args...)))
end

"""
    backend_sampling(backend::AbstractCryptoBackend, args...)
"""
function backend_sampling(backend::AbstractCryptoBackend, args...)
    throw(MethodError(backend_sampling, (backend, args...)))
end

# CPU fallback implementations
function backend_lattice_multiply(::CPUBackend, A::AbstractMatrix, x::AbstractVector)
    return A * x  # Basic fallback
end

function backend_ntt_transform(::CPUBackend, poly::AbstractVector, modulus::Integer)
    return poly  # Placeholder: Implement efficient NTT with SIMD
end

function backend_polynomial_multiply(::CPUBackend, a::AbstractVector, b::AbstractVector, modulus::Integer)
    return a  # Placeholder: Use NTT for O(n log n) multiplication
end

function backend_sampling(::CPUBackend, distribution::Symbol, params...)
    return randn()  # Placeholder: Implement constant-time sampling
end

# --- Pretty Printing ---
Base.show(io::IO, b::CPUBackend) = print(io, "CPUBackend($(b.simd_level), $(b.threads) threads)")
Base.show(io::IO, b::CUDABackend) = print(io, "CUDABackend(device=$(b.device), CC=$(b.compute_capability))")
Base.show(io::IO, b::ROCmBackend) = print(io, "ROCmBackend(device=$(b.device), arch=$(b.gcn_arch))")
Base.show(io::IO, b::MetalBackend) = print(io, "MetalBackend(M$(b.apple_silicon_generation)$(b.has_neural_engine ? " + Neural Engine" : ""))")
Base.show(io::IO, b::OneAPIBackend) = print(io, "OneAPIBackend($(b.device_type)$(b.has_npu ? " + NPU" : ""))")
Base.show(io::IO, b::TPUBackend) = print(io, "TPUBackend(v$(b.version), $(b.topology))")

# --- Package Extensions ---
# Extensions should define:
# - `cuda_available()`, `create_cuda_backend()`, etc.
# - Backend-specific methods for `backend_lattice_multiply`, etc.
