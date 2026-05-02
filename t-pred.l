[T-PRED.L - predicate primitives spec]
[Covers eq, equal, pairp, atom, numberp, symbolp, boundp,]
[lessp, minusp, zerop, oddp, not.]

<deftest test-not
    (assert t (not nil))
    (assert nil (not t))
    (assert nil (not 1))
    (assert nil (not 'foo))>

<deftest test-eq
    (asserteq 'a 'a)
    (assert t (eq 'a 'a))
    (assert nil (eq 'a 'b))
    (assert t (eq nil nil))>

<deftest test-equal
    (assert t (equal 1 1))
    (assert t (equal 'a 'a))
    (assert t (equal '(1 2) '(1 2)))
    (assert nil (equal 1 2))
    (assert nil (equal '(1 2) '(1 3)))>

<deftest test-pairp
    (assert t (pairp '(1 2)))
    (assert t (pairp '(a . b)))
    (assert nil (pairp 'a))
    (assert nil (pairp 1))
    [from docs - (pairp nil) returns t]
    (assert t (pairp nil))>

<deftest test-atom
    (assert t (atom 'a))
    (assert t (atom 1))
    (assert nil (atom '(1 2)))
    [from docs - (atom nil) returns t]
    (assert t (atom nil))>

<deftest test-numberp
    (assert t (numberp 1))
    (assert t (numberp 0))
    (assert nil (numberp 'a))
    (assert nil (numberp '(1)))>

<deftest test-symbolp
    (assert t (symbolp 'a))
    (assert nil (symbolp 1))
    (assert nil (symbolp '(1 2)))>

<deftest test-boundp
    (setq bp-yes 1)
    (assert t (boundp 'bp-yes))
    (assert nil (boundp 'bp-never-set))>

<deftest test-lessp
    (assert t (lessp 1 2))
    (assert nil (lessp 2 1))
    (assert nil (lessp 1 1))>

<deftest test-minusp
    (assert t (minusp -1))
    (assert nil (minusp 0))
    (assert nil (minusp 1))>

<deftest test-zerop
    (assert t (zerop 0))
    (assert nil (zerop 1))
    (assert nil (zerop -1))>

<deftest test-oddp
    (assert t (oddp 1))
    (assert t (oddp 3))
    (assert nil (oddp 0))
    (assert nil (oddp 2))>

t
