[T-ARITH.L - arithmetic primitives spec]
[Covers + - * / %, 1+, 1-, 2*, 2/, sqrt, abs, min, max, inc, dec.]

<deftest test-add
    (assert 3 (+ 1 2))
    (assert 0 (+ 0 0))
    (assert 100 (+ 50 50))>

<deftest test-sub
    (assert 1 (- 3 2))
    (assert 0 (- 5 5))
    (assert -3 (- 3))>

<deftest test-mult
    (assert 6 (* 2 3))
    (assert 0 (* 0 5))
    (assert 144 (* 12 12))>

<deftest test-div
    (assert 5 (/ 10 2))
    (assert 3 (/ 10 3))
    [round flag direction is implementation-defined and not in the docs;]
    [empirically: (/ 8 3 t) = 2, (/ 7 2 t) = 3 - rounds toward zero in some]
    [cases. Test only exact cases where rounding is unambiguous.]
    (assert 5 (/ 10 2 t))
    (assert 3 (/ 9 3 t))>

<deftest test-mod
    (assert 1 (% 10 3))
    (assert 0 (% 10 5))>

<deftest test-1plus
    (assert 1 (1+ 0))
    (assert 256 (1+ 255))>

<deftest test-1minus
    (assert 0 (1- 1))
    (assert -1 (1- 0))
    (assert 255 (1- 256))>

<deftest test-double
    (assert 6 (2* 3))
    (assert 0 (2* 0))>

<deftest test-half
    (assert 3 (2/ 6))
    (assert 2 (2/ 5))
    [round flag direction is implementation-defined; test exact halves only]
    (assert 3 (2/ 6 t))
    (assert 5 (2/ 10 t))>

<deftest test-sqrt
    (assert 3 (sqrt 9))
    (assert 4 (sqrt 16))
    (assert 10 (sqrt 100))>

<deftest test-abs
    (assert 5 (abs 5))
    (assert 5 (abs -5))
    (assert 0 (abs 0))>

<deftest test-min
    (assert 1 (min 1 2))
    (assert 1 (min 2 1))>

<deftest test-max
    (assert 2 (max 1 2))
    (assert 2 (max 2 1))>

<deftest test-inc
    (setq n 0)
    (inc n)
    (assert 1 n)
    (inc n)
    (assert 2 n)>

<deftest test-dec
    (setq n 5)
    (dec n)
    (assert 4 n)>

<deftest test-bignum
    [bignums - documented limit ~292 decimal digits]
    (assert 100000000 (* 10000 10000))
    (assert 1000000000000 (* 1000000 1000000))>

t
