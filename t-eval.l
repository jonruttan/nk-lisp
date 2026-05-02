[T-EVAL.L - evaluation and assignment primitives spec]
[Covers eval, quote, apply, setq, set, implied lambda.]

<deftest test-eval-self
    (assert t (eval t))
    (assert nil (eval nil))
    (assert 1 (eval 1))
    (assert 16777215 (eval 16777215))>

<deftest test-eval-symbol
    (setq x 42)
    (assert 42 (eval 'x))
    (assert 42 x)>

<deftest test-eval-form
    (assert 3 (eval '(+ 1 2)))
    (assert 1 (eval '(car '(1 2 3))))>

<deftest test-quote
    (assert 'a (quote a))
    (assert '(1 2) (quote (1 2)))
    [single-quote is shorthand for quote]
    (assert 'a 'a)>

<deftest test-apply
    (assert 7 (apply '+ '(3 4)))
    (assert 6 (apply '* '(2 3)))
    (assert 1 (apply 'car '((1 2 3))))
    [apply with implied lambda - from nk-lisp.md docs]
    (assert 14 (apply '((x y z) (* x (+ y z))) '(2 3 4)))>

<deftest test-setq
    (setq y 100)
    (assert 100 y)
    (setq y 200)
    (assert 200 y)>

<deftest test-set
    (setq sym 'z)
    (set sym 'foo)
    (assert 'foo z)>

<deftest test-implied-if
    [A list-headed form (cond X Y) is interpreted as IMPLIED IF, not as]
    [a function call. The car is the condition, the first cdr element is]
    [the true-branch, remaining elements are the false-branch. This explains]
    [the [TODO: Why is this 2?] in nk-lisp.md - the docs were wrong.]
    [See CARCELL in nklisp.mac.]
    (assert 2 ('((x y z) (* x (+ y z))) 2 3 4))
    [if cond (a list) evals non-nil, return eval of first cdr element]
    (assert 'true ('(t) 'true 'false))
    [implied-lambda still works through (apply) - APLCELL takes that path]
    (assert 14 (apply '((x y z) (* x (+ y z))) '(2 3 4)))>

[Implied-lambda direct call as documented does NOT work - kept here as
a known divergence so future maintainers can decide between fixing the
interpreter to match docs or fixing the docs to match impl.]
[<deftest test-implied-lambda-known-failing
    (assert 14 ('((x y z) (* x (+ y z))) 2 3 4))>]

t
