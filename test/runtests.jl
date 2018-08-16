using Test
using ClosedIntervals

A = ClosedInterval(1,5)
B = ClosedInterval(7,9)
C = ClosedInterval(9,1)

@test A+B == C
@test isempty(A*B)
@test A == ClosedInterval(right(A),left(A))
@test length(A) == 4

A = ClosedInterval(4.)
B = ClosedInterval(1.)
C = ClosedInterval(4.,1.)

@test A+B == C
@test length(A)==0
@test isempty(A*B)

A = ClosedInterval(1,6)
B = ClosedInterval(8,3)
C = ClosedInterval(3,6)

@test A*B == C
@test A+B == ClosedInterval(1,8)
