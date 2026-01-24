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

# Conditional backend availability (defined by package extensions)
function cuda_available() end
function rocm_available() end
function metal_available() end
function oneapi_available() end
function tpu_available() end

# Default implementations (overridden by extensions)
cuda_available() = false
rocm_available() = false
metal_available() = false
oneapi_available() = false
tpu_available() = false

"""
    detect_simd_level() -> Symbol

Detect CPU SIMD instruction set support.
Returns highest available: :avx512, :avx2, :avx, :sse, :neon, :sve, :none
"""
function detect_simd_level()
    # Platform-specific detection
    if Sys.isapple() && Sys.ARCH === :aarch64
        # Apple Silicon always has NEON
        return :neon
    elseif Sys.ARCH === :aarch64
        # Check for SVE on ARM
        if haskey(ENV, "JULIA_CPU_TARGET") && occursin("sve", ENV["JULIA_CPU_TARGET"])
            return :sve
        else
            return :neon
        end
    elseif Sys.ARCH === :x86_64
        # x86-64 detection via cpuid
        try
            # Julia's Sys.CPU_NAME contains flags
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

    # Try to detect via system_profiler
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
        # Fallback: assume M1 for Apple Silicon
        return 1
    end
    return 0
end

"""
    detect_hardware() -> AbstractCryptoBackend

Auto-detect best available hardware backend for cryptography.

Priority order:
1. TPU (best for large lattice operations)
2. CUDA with Tensor cores (NVIDIA A100, H100)
3. Metal with Neural Engine (Apple Silicon M2+)
4. oneAPI NPU (Intel Meteor Lake+)
5. ROCm with Matrix cores (AMD MI series)
6. CPU with highest SIMD level
"""
function detect_hardware()
    # Try TPU first (best for post-quantum lattice crypto)
    if tpu_available()
        try
            # TPU detection via environment or API
            if haskey(ENV, "TPU_NAME")
                return TPUBackend(4, ENV["TPU_NAME"])  # v4 TPU
            end
        catch
        end
    end

    # Try CUDA (NVIDIA GPUs)
    if cuda_available()
        try
            # Implemented in extension
            return create_cuda_backend()
        catch e
            @warn "CUDA detected but initialization failed" exception=e
        end
    end

    # Try Metal (Apple Silicon)
    if metal_available()
        try
            gen = detect_apple_silicon_generation()
            has_ne = gen >= 2  # Neural Engine improved in M2+
            return MetalBackend(0, has_ne, gen)
        catch e
            @warn "Metal detected but initialization failed" exception=e
        end
    end

    # Try oneAPI (Intel GPUs/NPUs)
    if oneapi_available()
        try
            return create_oneapi_backend()
        catch e
            @warn "oneAPI detected but initialization failed" exception=e
        end
    end

    # Try ROCm (AMD GPUs)
    if rocm_available()
        try
            return create_rocm_backend()
        catch e
            @warn "ROCm detected but initialization failed" exception=e
        end
    end

    # Fallback to CPU with SIMD detection
    simd = detect_simd_level()
    threads = Threads.nthreads()
    CPUBackend(simd, threads)
end

# Backend-specific operation dispatch (implemented in extensions or fallback to CPU)
function backend_lattice_multiply end
function backend_ntt_transform end  # Number Theoretic Transform for post-quantum
function backend_polynomial_multiply end
function backend_sampling end  # Cryptographic sampling

# CPU fallback implementations
backend_lattice_multiply(::CPUBackend, args...) = cpu_lattice_multiply(args...)
backend_ntt_transform(::CPUBackend, args...) = cpu_ntt_transform(args...)
backend_polynomial_multiply(::CPUBackend, args...) = cpu_polynomial_multiply(args...)
backend_sampling(::CPUBackend, args...) = cpu_sampling(args...)

# Placeholder CPU implementations (to be filled in)
function cpu_lattice_multiply(A::AbstractMatrix, x::AbstractVector)
    A * x  # Basic fallback
end

function cpu_ntt_transform(poly::AbstractVector, modulus::Integer)
    # Number Theoretic Transform - critical for post-quantum
    # TODO: Implement efficient NTT with SIMD
    poly  # Placeholder
end

function cpu_polynomial_multiply(a::AbstractVector, b::AbstractVector, modulus::Integer)
    # Polynomial multiplication in Z_q[x]
    # TODO: Use NTT for O(n log n) multiplication
    a  # Placeholder
end

function cpu_sampling(distribution::Symbol, params...)
    # Cryptographic sampling (discrete Gaussian, uniform, etc.)
    # TODO: Implement constant-time sampling
    randn()  # Placeholder
end

Base.show(io::IO, b::CPUBackend) = print(io, "CPUBackend($(b.simd_level), $(b.threads) threads)")
Base.show(io::IO, b::CUDABackend) = print(io, "CUDABackend(device=$(b.device), CC=$(b.compute_capability))")
Base.show(io::IO, b::ROCmBackend) = print(io, "ROCmBackend(device=$(b.device), arch=$(b.gcn_arch))")
Base.show(io::IO, b::MetalBackend) = print(io, "MetalBackend(M$(b.apple_silicon_generation)$(b.has_neural_engine ? " + Neural Engine" : ""))")
Base.show(io::IO, b::OneAPIBackend) = print(io, "OneAPIBackend($(b.device_type)$(b.has_npu ? " + NPU" : ""))")
Base.show(io::IO, b::TPUBackend) = print(io, "TPUBackend(v$(b.version), $(b.topology))")
