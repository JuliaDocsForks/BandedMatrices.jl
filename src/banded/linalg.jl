## Method definitions for generic eltypes - will make copies

# Direct and transposed algorithms

function ldiv!(A::BandedMatrix{T,Matrix{T}}, B::AbstractVecOrMat{S}) where {T<:Number, S<:Number}
    checksquare(A)
    AA, BB = _convert_to_blas_type(A, B)
    ldiv!(lu(AA), BB) # call BlasFloat versions
end

function ldiv!(At::Transpose{T,BandedMatrix{T,Matrix{T}}}, B::AbstractVecOrMat{S}) where {T<:Number, S<:Number}
    A = parent(At)
    checksquare(A)
    AA, BB = _convert_to_blas_type(A, B)
    ldiv!(transpose(lu(AA)), BB) # call BlasFloat versions
end

function ldiv!(Ac::Adjoint{T,BandedMatrix{T,Matrix{T}}}, B::AbstractVecOrMat{S}) where {T<:Number, S<:Number}
    A = parent(Ac)
    checksquare(A)
    AA, BB = _convert_to_blas_type(A, B)
    ldiv!(adjoint(lu(AA)), BB) # call BlasFloat versions
end

function ldiv!(A::BandedLU{T}, B::AbstractVecOrMat{S}) where {T<:Number, S<:Number}
    checksquare(A)
    AA, BB = _convert_to_blas_type(A, B)
    ldiv!(lu(AA), BB) # call BlasFloat versions
end

function ldiv!(At::Transpose{T,BandedLU{T}}, B::AbstractVecOrMat{S}) where {T<:Number, S<:Number}
    A = parent(At)
    checksquare(A)
    AA, BB = _convert_to_blas_type(A, B)
    ldiv!(transpose(lu(AA)), BB) # call BlasFloat versions
end

function ldiv!(Ac::Adjoint{T,BandedLU{T}}, B::AbstractVecOrMat{S}) where {T<:Number, S<:Number}
    A = parent(Ac)
    checksquare(A)
    AA, BB = _convert_to_blas_type(A, B)
    ldiv!(adjoint(lu(AA)), BB) # call BlasFloat versions
end



# \ is different because it needs a copy, but we have to avoid ambiguity
function \(A::BandedLU{T}, B::VecOrMat{Complex{T}}) where {T<:BlasReal}
    checksquare(A)
    ldiv!(convert(BandedLU{Complex{T}}, A), copy(B)) # goes to BlasFloat call
end
function \(A::BandedLU{T}, B::AbstractVecOrMat{S}) where {T<:Number, S<:Number}
    checksquare(A)
    TS = _promote_to_blas_type(T, S)
    ldiv!(convert(BandedLU{TS}, A), copy_oftype(B, TS)) # goes to BlasFloat call
end

# Method definitions for BlasFloat types - no copies
@eval function ldiv!(A::BandedMatrix{T,Matrix{T}}, B::AbstractVecOrMat{T}) where {T<:BlasFloat}
    checksquare(A)
    ldiv!(lu(A), B)
end
@eval function ldiv!(A::Transpose{T,BandedMatrix{T,Matrix{T}}}, B::AbstractVecOrMat{T}) where {T<:BlasFloat}
    checksquare(A)
    ldiv!(transpose(lu(parent(A))), B)
end
@eval function ldiv!(A::Adjoint{T,BandedMatrix{T,Matrix{T}}}, B::AbstractVecOrMat{T}) where {T<:BlasFloat}
    checksquare(A)
    ldiv!(adjoint(lu(parent(A))), B)
end



# Direct and transposed algorithms
function ldiv!(A::BandedLU{T}, B::AbstractVecOrMat{T}) where {T<:BlasFloat}
    checksquare(A)
    gbtrs!('N', A.m, A.l, A.u, A.data, A.ipiv, B)
end

function ldiv!(At::Transpose{T,BandedLU{T}}, B::AbstractVecOrMat{T}) where {T<:BlasFloat}
    A = parent(At)
    checksquare(A)
    gbtrs!('T', A.m, A.l, A.u, A.data, A.ipiv, B)
end
function ldiv!(Ac::Adjoint{T,BandedLU{T}}, B::AbstractVecOrMat{T}) where {T<:BlasReal}
    A = parent(Ac)
    checksquare(A)
    gbtrs!('T', A.m, A.l, A.u, A.data, A.ipiv, B)
end
function ldiv!(Ac::Adjoint{T,BandedLU{T}}, B::AbstractVecOrMat{T}) where {T<:BlasComplex}
    A = parent(Ac)
    checksquare(A)
    gbtrs!('C', A.m, A.l, A.u, A.data, A.ipiv, B)
end
