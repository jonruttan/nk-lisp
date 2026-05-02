[T-CATCH.L - catch and throw spec]
[Verifies the (catch tag body...) / (throw tag value) machinery.]
[Tags are matched by eq (pointer identity) - use interned symbols.]

<deftest test-catch-no-throw
    [body runs as implicit progn; last expression's value is returned]
    (assert 42 (catch 'tag 42))
    (assert 3 (catch 'tag 1 2 3))
    (assert nil (catch 'tag nil))>

<deftest test-catch-with-throw
    [throw value is returned by the catch]
    (assert 'caught (catch 'tag (throw 'tag 'caught)))
    (assert 99 (catch 'tag (throw 'tag 99)))
    (assert nil (catch 'tag (throw 'tag nil)))>

<deftest test-throw-short-circuits
    [expressions after the throw are not evaluated]
    (setq se nil)
    (assert 'thrown
        (catch 'tag
            (throw 'tag 'thrown)
            (setq se t)))
    (assert nil se)>

<deftest test-catch-nested-tags
    [throw bypasses inner catch when tags differ]
    (assert 'outer
        (catch 'a
            (catch 'b
                (throw 'a 'outer))))
    [throw to inner catch when tags match - inner catches first]
    (assert 'inner
        (catch 'a
            (catch 'a
                (throw 'a 'inner))))>

<deftest test-catch-t-tag
    [t works as a catch-all-style tag]
    (assert 'anything (catch t (throw t 'anything)))>

<deftest test-catch-through-function
    [throw works across function-call boundaries]
    (de catch-helper () (throw 'h 'from-helper))
    (assert 'from-helper (catch 'h (catch-helper)))>

<deftest test-catch-evaluates-body
    [body is implicit progn - all expressions evaluated, last returned]
    (setq i 0)
    (assert 3
        (catch 'tag
            (inc i) (inc i) (inc i)))
    (assert 3 i)>

t
