module ClosedIntervals

import Base.show, Base.isempty, Base.in, Base.length
export ClosedInterval, EmptyInterval
export show, left, right


# Create the ClosedInterval type
immutable ClosedInterval{T}
    L::T       # left end point
    R::T       # right end point
    nil::Bool  # signal if this is an empty interval
end


# Construct from two distinct end points
function ClosedInterval{T}(l::T,r::T)
    if l>r
        (l,r) = (r,l)
    end
    return ClosedInterval(l,r,false)
end

# Construct from a 2-tuple
function ClosedInterval{T}(ab::(T,T))
    return ClosedInterval(ab[1],ab[2],false)
end

# Construct from one end point: assume L and R are the same
ClosedInterval{T}(a::T) = ClosedInterval(a,a)

# Construction with no specified end points: assume [0,1]
function ClosedInterval(T::DataType = Float64) 
    ClosedInterval(zero(T),one(T))
end

# Create an empty interval 
function EmptyInterval(T::DataType = Float64)
    return ClosedInterval(zero(T),zero(T), true)
end

# Fetch the left end point
function left(J::ClosedInterval)
    if isempty(J)
        error("An empty interval does not have a left end point")
    end
    return J.L
end

# Fetch the right end point
function right(J::ClosedInterval)
    if isempty(J)
        error("An empty interval does not have a right end point")
    end
    return J.R
end

# Is this an empty interval?
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
function length(J::ClosedInterval)
    if isempty(J)
        error("The length of an empty interval is undefined")
    end
    return J.R - J.L
end

# Test point for membership
function in{T}(x::T, J::ClosedInterval{T})
    return J.L <= x <= J.R
end

# The intersection of two intervals is the largest interval contained
# in both. If the intervals are disjoint, we return an empty interval.
function *{T}(J::ClosedInterval{T}, K::ClosedInterval{T})
    
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

end # module
