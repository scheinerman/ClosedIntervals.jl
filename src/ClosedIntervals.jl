module ClosedIntervals

import Base.show, Base.isempty, Base.in, Base.length, Base.<<, Base.>>
import Base.isequal, Base.isless
import Base.*, Base.+, Base.==
export ClosedInterval, EmptyInterval
export show, left, right

# Create the ClosedInterval type
immutable ClosedInterval{T}
    L::T       # left end point
    R::T       # right end point
    nil::Bool  # signal if this is an empty interval
end

# Construct from two distinct end points
function ClosedInterval(l,r)
    (a,b) = promote(l,r)
    if a>b
        a,b = b,a
    end
    return ClosedInterval(a,b,false)
end

# Construct from a 2-tuple
function ClosedInterval{S,T}(ab::Tuple{S,T})
    return ClosedInterval(ab[1],ab[2]) # use 2-arg to test order
end

# Construct from one end point: assume L and R are the same
ClosedInterval(a) = ClosedInterval(a,a,false)

# Construction with no specified end points: assume [0,1]
function ClosedInterval(T::DataType = Float64)
    ClosedInterval(zero(T),one(T),false)
end

# Create an empty interval
"""
`EmptyInterval(T::DataType = Float64)` creates an empty
`ClosedInterval` of a given type.
"""
function EmptyInterval(T::DataType = Float64)
    return ClosedInterval(zero(T),zero(T), true)
end

# Fetch the left end point
"""
For a `ClosedInterval` `I`, `left(I)` returns its left end point.
"""
function left(J::ClosedInterval)
    if isempty(J)
        error("An empty interval does not have a left end point")
    end
    return J.L
end

# Fetch the right end point
"""
For a `ClosedInterval` `I`, `right(I)` returns its right end point.
"""
function right(J::ClosedInterval)
    if isempty(J)
        error("An empty interval does not have a right end point")
    end
    return J.R
end

# Is this an empty interval?
"""
For a `ClosedInterval I`, `isempty(I)` tests if `I` is an empty interval.
"""
isempty(J::ClosedInterval) = J.nil

# Print as a closed interval should be printed
function show(io::IO, J::ClosedInterval)
    if J.nil
        print(io,"[]")
    else
        print(io,"[", J.L, ",", J.R, "]")
    end
end

# The length of an interval is R-L unless it's empty. In that case, we
# throw an error.
"""
`length(I)` is the length of the `ClosedInterval` `I`.
"""
function length{T}(J::ClosedInterval{T})
    if isempty(J)
      return zero(T)
    end
    return J.R - J.L
end

# Test point for membership
"""
For a number `x` and a `ClosedInterval` `I` (of the same type)
`in(x,I)` tests if `x` is contained in the interval `I`.
"""
function in(x, J::ClosedInterval)
    return J.L <= x <= J.R
end

# The intersection of two intervals is the largest interval contained
# in both. If the intervals are disjoint, we return an empty interval.
"""
For `ClosedInterval`s `I` and `J`, `I*J` is their intersection.
"""
function *{S,T}(J::ClosedInterval{S}, K::ClosedInterval{T})

    # if either interval is nil, so is their *
    if J.nil || K.nil
        return EmptyInterval(T)
    end

    a::T = max(J.L, K.L)   # left end point of result
    b::T = min(J.R, K.R)   # right end point of result

    if a>b  # uh oh, they're disjoint
        return EmptyInterval(T)
    end

    return ClosedInterval(a,b,false)
end

# The + of two intervals is the smallest interval containing them
# both. This is the same as their union if they overlap.

"""
For `ClosedInterval`s `I` and `J`, `I+J` is the smallest `ClosedInterval`
containing them both.
"""
function +{T}(J::ClosedInterval{T}, K::ClosedInterval{T})
    # The empty interval acts as an identity element for this
    # operation, so we check if either interval is empty first.
    if J.nil
        return K
    end
    if K.nil
        return J
    end

    a::T = min(J.L, K.L)   # left end point of result
    b::T = max(J.R, K.R)   # right end point of result

    return ClosedInterval(a,b,false)
end

# Compare intervals for equality
function isequal(I::ClosedInterval, J::ClosedInterval)
    return (I.nil && J.nil) || (I.L==J.L && I.R==J.R)
end

==(I::ClosedInterval, J::ClosedInterval) = isequal(I,J)

# Sort intervals lexicographically, but put empty intervals at the
# bottom of the order.
"""
Lexicographic ordering of `ClosedInterval`s.
"""
function isless(I::ClosedInterval, J::ClosedInterval)
    if J.nil
        return false
    end
    if I.nil
       return true
    end

    if I.L < J.L
        return true
    end

    if I.L > J.L
        return false
    end

    return I.R < J.R
end


# We use << to mean "completely to the left of"
"""
For `ClosedInterval`s `I` and `J`, `I<<J` tests if `I` is completely
to the left of `J`.
"""
function <<(I::ClosedInterval, J::ClosedInterval)
    if I.nil || J.nil
        return false
    end
    return I.R < J.L
end

# Likewise, >> means "completely to the right of"
"""
For `ClosedInterval`s `I` and `J`, `I>>J` tests if `I` is completely
to the right of `J`.
"""
>>(I::ClosedInterval, J::ClosedInterval) = J << I

end # module
