**Note**: This type does not define interval arithmetic.

ClosedIntervals
===============

The `ClosedIntervals` module defines a data type `ClosedInterval` that
represents a set of the form `[a,b] = {x: a <= x <= b}`. Typically, a
`ClosedInterval` is created by specifying its end points:
```julia
julia> using ClosedIntervals

julia> ClosedInterval(3,7)
[3,7]

julia> ClosedInterval(8,2)
[2,8]

julia> a = (6,0)
(6,0)

julia> ClosedInterval(a)
[0,6]

julia> ClosedInterval(1, 2.3)
ERROR: no method ClosedInterval{T}(Int64,Float64)
```

This example illustrates a few points.

* First, interval is printed in standard mathematical notation using
square brackets.

* Second, the end points can be specified in either order.

* Third, the interval can be constructed from a tuple.

* Finally, the type of the two end points must be the same. The proper
way to create the interval from 1 to 2.3 is `ClosedInterval(1.,2.3)`.


The two end points of the interval may be the same, in which case
it is enough to name only one of the end points:
```julia
julia> ClosedInterval(5)
[5,5]
```

If no arguments are provided to `ClosedInterval` the result is the
unit interval [0,1] with `Float64` end points. Or, if we supply a
type `T`, then the result is again [0,1], but with type `T` end
points.
```julia
julia> ClosedInterval()
[0.0,1.0]

julia> ClosedInterval(Int)
[0,1]

julia> typeof(ans)
ClosedInterval{Int64} (constructor with 1 method)
```

We also provide an empty interval constructed with `EmptyInterval`,
like this:
```julia
julia> X = EmptyInterval()
[]

julia> typeof(X)
ClosedInterval{Float64} (constructor with 1 method)

julia> Y = EmptyInterval(Int)
[]

julia> typeof(Y)
ClosedInterval{Int64} (constructor with 1 method)
```
Notice that empty intervals are printed as a pair of square brackets
with nothing between.

Properties
----------

The functions `left` and `right` are used to retrieve the left and
right end points of an interval. Use `length` to get the length of the
interval (difference of the end points).
```julia
julia> A = ClosedInterval(6,2)
[2,6]

julia> left(A)
2

julia> right(A)
6

julia> length(A)
4
```

Applying any of these to an empty interval throws an error:
```julia
julia> left(X)
ERROR: An empty interval does not have a left end point
 in left at /home/..../ClosedIntervals.jl:45

julia> length(X)
ERROR: The length of an empty interval is undefined
 in length at /home/..../ClosedIntervals.jl:74
```

Use `isempty` to test if an interval is empty.
```julia
julia> isempty(A)
false

julia> isempty(X)
true
```

To test if a given value lies inside an interval, use `in`:
```
julia> A = ClosedInterval(3,10)
[3,10]

julia> in(5,A)
true

julia> in(1,A)
false

julia> X = EmptyInterval(Int)
[]

julia> in(0,A)
false
```
Notice that testing for membership in an empty interval does not
generate an error, but will always return `false`.


Operations
----------

Two operations are defined for intervals.

* The intersection `*` is the largest interval contained in both. If
  the intervals are disjoint, this returns an empty interval.

* The sum `+` is the smallest interval containing both. If the
  intervals overlap, then this is the same as their union. Note that
  the empty interval serves as an identity element for this operation.

```julia
julia> A = ClosedInterval(1,5)
[1,5]

julia> B = ClosedInterval(3,7)
[3,7]

julia> A*B
[3,5]

julia> A+B
[1,7]

julia> C = ClosedInterval(1,3)
[1,3]

julia> D = ClosedInterval(5,6)
[5,6]

julia> C*D
[]

julia> C+D
[1,6]
```

Infinite Intervals
------------------

When intervals have end points of type `Float64`, it is possible to
work with infinite intervals. Everything works as one
might expect.
```julia
julia> A = ClosedInterval(0., Inf)
[0.0,Inf]

julia> B = ClosedInterval(1., -Inf)
[-Inf,1.0]

julia> A*B
[0.0,1.0]

julia> A+B
[-Inf,Inf]

julia> length(A)
Inf

julia> in(2.,A)
true

julia> in(2.,B)
false
```

Comparison
----------

###Equality

The usual comparison operators may be applied to pairs of
intervals. As usual, equality may be checked with `==` (or
`isequal`).

###Lexicographic total order

We also define `isless` for intervals as follows. An empty interval is
defined to be less than all nonempty intervals. Otherwise, we sort
intervals lexicographically. That is, interval `[a,b]` is less than
`[c,d]` provided either (a) `a<c` or (b) `(a==c) && (b<d)`.

Intervals of mixed type may be compared. For example:
```julia
julia> A = ClosedInterval(1,2)
[1,2]

julia> B = ClosedInterval(1.,2.)
[1.0,2.0]

julia> A==B
true

julia> A = ClosedInterval(-Inf,3.)
[-Inf,3.0]

julia> B = ClosedInterval(3,5)
[3,5]

julia> A < B
true
```

###Completely-to-the-left-of partial order

We use `<<` to test if one interval is completely to the left of another.
That is `[a,b]<<[c,d]` exactly when `b<c`. In this case, comparing an
empty interval to any other yields `false`. Likewise, we use `>>`
to test if one interval is to the right of another.
```julia
julia> A = ClosedInterval(1,5);

julia> B = ClosedInterval(3,8);

julia> C = ClosedInterval(7,9);

julia> A<<B
false

julia> A<<C
true

julia> B<<C
false

julia> C>>A
true

```

## Non-numeric end points

Normally, the end points of a `ClosedInterval` are real numbers
(subtypes of `Real`).
However, we do permit the end point types to be any Julia objects
that can be compared with `<`. For example:
```julia
julia> J = ClosedInterval("charlie", "bravo")
[bravo,charlie]

julia> K = ClosedInterval("oscar", "yankee")
[oscar,yankee]

julia> J+K
[bravo,yankee]

julia> in("romeo", K)
true
```
However, some operations will fail if they rely on numeric
operations. For example:
```julia
julia> length(J)
ERROR: MethodError: `-` has no method matching -(::ASCIIString, ::ASCIIString)
 in length at /home/ers/.julia/v0.4/ClosedIntervals/src/ClosedIntervals.jl:92

julia> J*K
ERROR: MethodError: `zero` has no method matching zero(::Type{ASCIIString})
 in * at /home/ers/.julia/v0.4/ClosedIntervals/src/ClosedIntervals.jl:120
```
